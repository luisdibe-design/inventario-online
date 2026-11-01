-- Aplicada y verificada en los proyectos Supabase Bikebeat y ODKL.
-- Re-ejecutable: no modifica existencias al instalarse.
create table if not exists public.full_inbound_deduction_batches (
  shipment_id text primary key,
  payload jsonb not null,
  status text not null default 'completed' check (status in ('completed')),
  movement_ids uuid[] not null default '{}',
  created_by uuid,
  created_at timestamptz not null default now()
);
alter table public.full_inbound_deduction_batches enable row level security;
drop policy if exists full_inbound_deduction_batches_admin_select on public.full_inbound_deduction_batches;
create policy full_inbound_deduction_batches_admin_select on public.full_inbound_deduction_batches
for select to authenticated using (private.current_app_role() = 'admin');
drop policy if exists full_inbound_deduction_batches_admin_insert on public.full_inbound_deduction_batches;
create policy full_inbound_deduction_batches_admin_insert on public.full_inbound_deduction_batches
for insert to authenticated with check (private.current_app_role() = 'admin');
drop policy if exists full_inbound_deduction_batches_admin_update on public.full_inbound_deduction_batches;
create policy full_inbound_deduction_batches_admin_update on public.full_inbound_deduction_batches
for update to authenticated using (private.current_app_role() = 'admin') with check (private.current_app_role() = 'admin');
grant select, insert, update on public.full_inbound_deduction_batches to authenticated;

create or replace function public.apply_full_inbound_deduction_batch(p_shipment_id text, p_items jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = public, private, pg_temp
as $$
declare
  v_existing public.full_inbound_deduction_batches%rowtype;
  v_inserted integer := 0;
  v_item record;
  v_product public.products%rowtype;
  v_movement_ids uuid[] := '{}';
  v_mid uuid;
begin
  if private.current_app_role() <> 'admin' then
    raise exception 'Solo un administrador puede confirmar descuentos de envíos Full.';
  end if;
  if coalesce(trim(p_shipment_id),'') = '' then raise exception 'Falta el número de envío.'; end if;
  if jsonb_typeof(p_items) <> 'array' then raise exception 'El detalle de descuentos no es válido.'; end if;
  if jsonb_array_length(p_items) = 0 then return jsonb_build_object('ok',true,'status','no_items','processed',0); end if;
  insert into public.full_inbound_deduction_batches(shipment_id,payload,created_by)
  values (p_shipment_id,p_items,auth.uid())
  on conflict (shipment_id) do nothing;
  get diagnostics v_inserted = row_count;
  if v_inserted = 0 then
    select * into v_existing from public.full_inbound_deduction_batches
    where shipment_id=p_shipment_id for update;
    if v_existing.status='completed' and v_existing.payload=p_items then
      return jsonb_build_object('ok',true,'status','already_applied','processed',cardinality(v_existing.movement_ids));
    end if;
    raise exception 'El envío % ya tiene un proceso registrado con otro detalle. No se aplicaron descuentos.', p_shipment_id;
  end if;
  for v_item in
    select product_id, max(sku) as sku, sum(quantity::numeric) as quantity
    from jsonb_to_recordset(p_items) as x(product_id uuid, sku text, quantity numeric)
    group by product_id order by product_id
  loop
    if v_item.quantity <= 0 then raise exception 'Cantidad inválida para SKU %.', v_item.sku; end if;
    select * into v_product from public.products where id=v_item.product_id for update;
    if not found then raise exception 'No existe el producto % en esta base.', v_item.sku; end if;
    if coalesce(v_product.stock,0) < v_item.quantity then
      raise exception 'Stock insuficiente para %: disponible %, solicitado %.', v_item.sku, coalesce(v_product.stock,0), v_item.quantity;
    end if;
    insert into public.movements(product_id,type,quantity,unit_price,reference,notes,movement_date,user_id,channel)
    values (v_product.id,'salida',v_item.quantity,coalesce(v_product.purchase_price,0),
      'FULL-'||p_shipment_id,
      'Descuento confirmado de envío Mercado Libre Full #'||p_shipment_id||' · SKU '||coalesce(v_product.sku,v_item.sku),
      now(),auth.uid(),'Mercado Libre Full')
    returning id into v_mid;
    v_movement_ids := array_append(v_movement_ids,v_mid);
  end loop;
  update public.full_inbound_deduction_batches set movement_ids=v_movement_ids where shipment_id=p_shipment_id;
  return jsonb_build_object('ok',true,'status','applied','processed',cardinality(v_movement_ids),'movement_ids',to_jsonb(v_movement_ids));
end;
$$;
revoke all on function public.apply_full_inbound_deduction_batch(text,jsonb) from public, anon;
grant execute on function public.apply_full_inbound_deduction_batch(text,jsonb) to authenticated;
