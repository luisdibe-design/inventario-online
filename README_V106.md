# V106 - conciliación automática de SKU al guardar productos

- Al crear un producto en la base BIKEBEAT, la aplicación ejecuta la conciliación de publicaciones Drop Off de Mercado Libre.
- Al editar un producto BIKEBEAT y cambiar su SKU, vuelve a ejecutar la conciliación.
- Muestra cuántas relaciones nuevas y actualizadas reporta la función; si falla, conserva el producto guardado e informa que la conciliación quedó pendiente.
- En ODKL no ejecuta la conciliación de Mercado Libre.
- La conciliación usa `mercadolibre-listing-manager` (versión 20 o posterior) y solo relaciona SKU exactos y únicos.
- No modifica inventario, movimientos, precios ni cantidades de publicaciones.

Despliegue: publicar el contenido de la carpeta `v27` mediante Vercel Drop, reemplazando la versión anterior.
