-- Inventario Online V80: administración de recetas de kits virtuales.
-- Ejecutar en Supabase de Bikebeat y en Supabase de ODKL antes de usar el módulo en ambas bases.
-- No modifica productos, existencias, movimientos ni publicaciones de Mercado Libre.

CREATE TABLE IF NOT EXISTS public.kit_recipes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  base_key text NOT NULL,
  kit_product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  active boolean NOT NULL DEFAULT true,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.kit_recipe_components (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id uuid NOT NULL REFERENCES public.kit_recipes(id) ON DELETE CASCADE,
  component_product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
  quantity integer NOT NULL CHECK (quantity >= 1),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT kit_recipe_components_unique_product UNIQUE (recipe_id, component_product_id)
);

CREATE UNIQUE INDEX IF NOT EXISTS kit_recipes_base_kit_unique
  ON public.kit_recipes(base_key, kit_product_id);
CREATE INDEX IF NOT EXISTS kit_recipe_components_recipe_idx
  ON public.kit_recipe_components(recipe_id);

ALTER TABLE public.kit_recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.kit_recipe_components ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS kit_recipes_select_authenticated ON public.kit_recipes;
CREATE POLICY kit_recipes_select_authenticated ON public.kit_recipes
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS kit_recipes_admin_write ON public.kit_recipes;
CREATE POLICY kit_recipes_admin_write ON public.kit_recipes
  FOR ALL TO authenticated
  USING (private.current_app_role() = 'admin')
  WITH CHECK (private.current_app_role() = 'admin');

DROP POLICY IF EXISTS kit_recipe_components_select_authenticated ON public.kit_recipe_components;
CREATE POLICY kit_recipe_components_select_authenticated ON public.kit_recipe_components
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS kit_recipe_components_admin_write ON public.kit_recipe_components;
CREATE POLICY kit_recipe_components_admin_write ON public.kit_recipe_components
  FOR ALL TO authenticated
  USING (private.current_app_role() = 'admin')
  WITH CHECK (private.current_app_role() = 'admin');
