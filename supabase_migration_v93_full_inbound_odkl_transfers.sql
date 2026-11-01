-- V93: documentar automáticamente transferencias ODKL -> Bikebeat al confirmar un Full.
-- Ejecutar SOLO en Supabase Bikebeat. No ejecutar en ODKL.
-- La entrada y salida en Bikebeat se insertan juntas en una transacción:
-- incrementan y descuentan la misma cantidad, por lo que el stock neto no cambia.
create table if not exists public.full_inbound_odkl_transfer_batches (
  shipment_id text primary key,
  payload jsonb not null,
  movement_ids uuid[] not null default '{}',
  created_by uuid,
  created_at timestamptz not null default now()
);

alter table public.full_inbound_odkl_transfer_batches enable row level security;
drop policy if exists full_inbound_odkl_transfer_batches_admin_select on public.full_inbound_odkl_transfer_batches;
create policy full_inbound_odkl_transfer_batches_admin_select
on public.full_inbound_odkl_transfer_batches for select to authenticated
using (private.current_app_role() = 'admin');
drop policy if exists full_inbound_odkl_transfer_batches_admin_insert on public.full_inbound_odkl_transfer_batches;
create policy full_inbound_odkl_transfer_batches_admin_insert
on public.full_inbound_odkl_transfer_batches for insert to authenticated
with check (private.current_app_role() = 'admin');
drop policy if exists full_inbound_odkl_transfer_batches_admin_update on public.full_inbound_odkl_transfer_batches;
create policy full_inbound_odkl_transfer_batches_admin_update
on public.full_inbound_odkl_transfer_batches for update to authenticated
using (private.current_app_role() = 'admin')
with check (private.current_app_role() = 'admin');
grant select, insert, update on public.full_inbound_odkl_transfer_batches to authenticated;

create or replace function public.record_full_inbound_odkl_transfer(
  p_shipment_id text,
  p_items jsonb
)
returns jsonb
language plpgsql
security invoker
set search_path = public, private, pg_temp
as $$
declare
  v_existing public.full_inbound_odkl_transfer_batches%rowtype;
  v_inserted integer := 0;
  v_item record;
  v_product public.products%rowtype;
  v_entry_id uuid;
  v_exit_id uuid;
  v_ids uuid[] := '{}';
begin
  if private.current_app_role() <> 'admin' then
    raise exception 'Solo un administrador puede registrar transferencias de envíos Full.';
  end if;
  if coalesce(trim(p_shipment_id),'') = '' then
    raise exception 'Falta el número de envío.';
  end if;
  if jsonb_typeof(p_items) <> 'array' then
    raise exception 'El detalle de transferencias no es válido.';
  end if;

  insert into public.full_inbound_odkl_transfer_batches(shipment_id,payload,created_by)
  values (p_shipment_id,p_items,auth.uid())
  on conflict (shipment_id) do nothing;
  get diagnostics v_inserted = row_count;

  if v_inserted = 0 then
    select * into v_existing
    from public.full_inbound_odkl_transfer_batches
    where shipment_id = p_shipment_id
    for update;
    if v_existing.payload = p_items then
      return jsonb_build_object(
        'ok',true,'status','already_recorded',
        'processed',cardinality(v_existing.movement_ids)
      );
    end if;
    raise exception 'El envío % ya tiene una transferencia registrada con otro detalle.', p_shipment_id;
  end if;

  for v_item in
    select upper(trim(sku)) as sku, sum(quantity::numeric) as quantity
    from jsonb_to_recordset(p_items) as x(sku text, quantity numeric)
    group by upper(trim(sku))
    order by upper(trim(sku))
  loop
    if coalesce(v_item.sku,'') = '' or v_item.quantity <= 0 then
      raise exception 'SKU o cantidad inválida en la transferencia Full.';
    end if;

    select * into v_product
    from public.products
    where upper(trim(sku)) = v_item.sku and active = true
    order by id
    limit 1
    for update;

    if not found then
      raise exception 'No existe en Bikebeat el SKU componente % requerido para documentar la transferencia.', v_item.sku;
    end if;

    -- La transferencia debe apuntar a componentes físicos, nunca a un kit virtual.
    if lower(left(trim(coalesce(v_product.name,'')),3)) = 'kit'
       or lower(left(trim(coalesce(v_product.sku,'')),3)) = 'kit' then
      raise exception 'El SKU % parece ser un Kit. La transferencia debe registrarse sobre su componente físico.', v_item.sku;
    end if;

    insert into public.movements(
      product_id,type,quantity,unit_price,reference,notes,movement_date,user_id,channel
    ) values (
      v_product.id,'entrada',v_item.quantity,coalesce(v_product.purchase_price,0),
      'FULL-'||p_shipment_id,
      'Entrada documental desde ODKL para surtir envío Mercado Libre Full #'||p_shipment_id||
        ' · SKU '||v_product.sku||'. Se compensa con la salida Full del mismo envío.',
      now(),auth.uid(),'Entrada de ODKL'
    ) returning id into v_entry_id;
    v_ids := array_append(v_ids,v_entry_id);

    insert into public.movements(
      product_id,type,quantity,unit_price,reference,notes,movement_date,user_id,channel
    ) values (
      v_product.id,'salida',v_item.quantity,coalesce(v_product.purchase_price,0),
      'FULL-'||p_shipment_id,
      'Salida Mercado Libre Full surtida mediante transferencia desde ODKL #'||p_shipment_id||
        ' · SKU '||v_product.sku||'. El stock neto de Bikebeat no cambia por esta pareja documental.',
      now(),auth.uid(),'Mercado Libre Full'
    ) returning id into v_exit_id;
    v_ids := array_append(v_ids,v_exit_id);
  end loop;

  update public.full_inbound_odkl_transfer_batches
  set movement_ids = v_ids
  where shipment_id = p_shipment_id;

  return jsonb_build_object(
    'ok',true,'status','recorded',
    'processed',cardinality(v_ids),
    'movement_ids',to_jsonb(v_ids)
  );
end;
$$;

revoke all on function public.record_full_inbound_odkl_transfer(text,jsonb) from public, anon;
grant execute on function public.record_full_inbound_odkl_transfer(text,jsonb) to authenticated;
