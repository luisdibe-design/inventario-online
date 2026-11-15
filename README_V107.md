# V107 - Auditoria de SKU Drop Off faltantes (solo lectura)

- Agrega al modulo Publicaciones ML el boton "Diagnosticar SKU faltantes (solo lectura)".
- Compara todas las publicaciones del catalogo del vendedor BIKEBEAT contra el catalogo completo de productos, incluyendo productos inactivos.
- Incluye publicaciones activas y pausadas; excluye Full.
- Desglosa variantes por SKU individual.
- Clasifica: SKU no existe en inventario, sin SKU en ML, SKU duplicado en inventario y SKU existente.
- Muestra ID de publicacion, variante, estado, SKU ML, titulo, cantidad, SKU/producto inventario y si hay relacion registrada.
- Permite exportar a Excel.
- No crea/actualiza productos, relaciones, existencias, publicaciones, movimientos ni reportes.

## Despliegue
1. La Edge Function `mercadolibre-dropoff-audit` v1 ya fue desplegada en Supabase BIKEBEAT (`iavhoqezxcfdefbyspmq`).
2. Publica el contenido de `v27` en Vercel Drop para actualizar la interfaz.
3. En BIKEBEAT, abre Publicaciones ML y pulsa el nuevo boton de diagnostico.
4. Exporta el resultado a Excel si lo necesitas.

La funcion es independiente de `mercadolibre-listing-manager`; no llama al modo `list` que realiza conciliacion automatica.
