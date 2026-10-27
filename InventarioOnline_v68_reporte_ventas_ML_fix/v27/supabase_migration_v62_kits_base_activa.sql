
-- Inventario Online v62: consumo de componentes de Kits en la base activa.
-- Ejecutar por separado en Supabase Bikebeat y Supabase ODKL.
-- No modifica movimientos existentes ni el inventario actual.
CREATE OR REPLACE FUNCTION public.apply_movement_to_stock()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  kit public.products%ROWTYPE;
  component public.products%ROWTYPE;
  all_kit_text text;
  qty_match text[];
  sku_match text[];
  per_kit numeric;
  needed numeric;
  shortage numeric;
  is_kit boolean;
BEGIN
  IF NEW.type = 'salida' THEN
    SELECT * INTO kit FROM public.products WHERE id = NEW.product_id FOR UPDATE;
    IF FOUND THEN
      all_kit_text := concat_ws(' ', kit.name, kit.description, kit.sku, kit.barcode);
      is_kit := lower(left(trim(coalesce(kit.name,'')),3)) = 'kit'
                OR lower(left(trim(coalesce(kit.sku,'')),3)) = 'kit';
      qty_match := regexp_match(all_kit_text, 'QTY[[:space:]]*:[[:space:]]*([0-9]+([.,][0-9]+)?)', 'i');
      sku_match := regexp_match(all_kit_text, 'SKU[[:space:]]*:[[:space:]]*([^[:space:],;]+)', 'i');

      -- También reconoce el formato habitual "Kit N Piezas ... QTY:N SKU:COMPONENTE".
      IF NOT is_kit AND qty_match IS NOT NULL AND sku_match IS NOT NULL
         AND lower(coalesce(kit.name,'')) LIKE '%kit%piezas%' THEN
        is_kit := true;
      END IF;

      IF is_kit AND qty_match IS NOT NULL AND sku_match IS NOT NULL THEN
        per_kit := replace(qty_match[1], ',', '.')::numeric;
        IF per_kit <= 0 THEN
          RAISE EXCEPTION 'QTY inválido para Kit SKU %', kit.sku;
        END IF;

        SELECT * INTO component
        FROM public.products
        WHERE upper(sku) = upper(sku_match[1]) AND active = true
        FOR UPDATE;

        IF NOT FOUND THEN
          RAISE EXCEPTION 'No se encontró el SKU componente % para el Kit %', sku_match[1], kit.sku;
        END IF;
        IF lower(left(coalesce(component.name,''),3)) = 'kit'
           OR lower(left(coalesce(component.sku,''),3)) = 'kit' THEN
          RAISE EXCEPTION 'No se permite anidar Kits: el componente % también es un Kit', component.sku;
        END IF;

        -- Solo se consumen componentes para las unidades de Kit que faltan.
        shortage := greatest(0, NEW.quantity - coalesce(kit.stock,0));
        needed := shortage * per_kit;
        IF needed > 0 THEN
          IF coalesce(component.stock,0) < needed THEN
            RAISE EXCEPTION 'Stock insuficiente para Kit %: hay % Kit(s), faltan % y el componente % tiene %; se necesitan % unidades',
              kit.sku, coalesce(kit.stock,0), shortage, component.sku, coalesce(component.stock,0), needed;
          END IF;

          INSERT INTO public.movements(
            product_id,type,quantity,unit_price,reference,notes,movement_date,channel
          ) VALUES (
            component.id,'salida',needed,coalesce(component.purchase_price,0),
            'KIT-COMPONENTE-' || NEW.id::text,
            'Consumo automático de componente ' || component.sku || ' para completar Kit ' || kit.sku ||
              '; movimiento Kit ' || NEW.id::text,
            coalesce(NEW.movement_date,now()),'Consumo de Kit'
          );

          INSERT INTO public.movements(
            product_id,type,quantity,unit_price,reference,notes,movement_date,channel
          ) VALUES (
            kit.id,'entrada',shortage,coalesce(kit.purchase_price,0),
            'KIT-REPOSICION-' || NEW.id::text,
            'Reposición automática de ' || shortage || ' Kit(s) por consumo del componente ' || component.sku ||
              '; movimiento Kit ' || NEW.id::text,
            coalesce(NEW.movement_date,now()),'Armado de Kit'
          );
        END IF;
      END IF;
    END IF;
  END IF;

  IF NEW.type = 'entrada' THEN
    UPDATE public.products SET stock = stock + NEW.quantity WHERE id = NEW.product_id;
  ELSIF NEW.type = 'salida' THEN
    UPDATE public.products SET stock = stock - NEW.quantity WHERE id = NEW.product_id;
  ELSIF NEW.type = 'ajuste' THEN
    UPDATE public.products SET stock = NEW.quantity WHERE id = NEW.product_id;
  END IF;
  RETURN NEW;
END;
$function$;
