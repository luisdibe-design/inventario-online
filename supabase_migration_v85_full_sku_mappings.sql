-- V85: relaciones manuales de Código ML a SKU interno para embarques Full.
-- Ejecutar en el proyecto Bikebeat (base central de las relaciones).
-- No modifica productos, existencias, movimientos ni publicaciones.
CREATE TABLE IF NOT EXISTS public.full_inbound_sku_mappings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ml_code text NOT NULL UNIQUE,
  product_base_key text NOT NULL CHECK (product_base_key IN ('bikebeat','odkl')),
  product_sku text NOT NULL,
  source_description text,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS full_inbound_sku_mappings_product_idx
  ON public.full_inbound_sku_mappings(product_base_key, product_sku);
ALTER TABLE public.full_inbound_sku_mappings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS full_inbound_sku_mappings_select_authenticated ON public.full_inbound_sku_mappings;
CREATE POLICY full_inbound_sku_mappings_select_authenticated
  ON public.full_inbound_sku_mappings FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS full_inbound_sku_mappings_admin_write ON public.full_inbound_sku_mappings;
CREATE POLICY full_inbound_sku_mappings_admin_write
  ON public.full_inbound_sku_mappings FOR ALL TO authenticated
  USING (private.current_app_role() = 'admin')
  WITH CHECK (private.current_app_role() = 'admin');
GRANT SELECT, INSERT, UPDATE, DELETE ON public.full_inbound_sku_mappings TO authenticated;
NOTIFY pgrst, 'reload schema';
