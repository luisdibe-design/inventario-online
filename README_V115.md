# V115 - Clasificación y resumen de ventas enviadas Amazon BIKEBEAT

Se mejora el reporte Amazon — ventas históricas:
- Conserva todas las líneas originales de pedidos en el histórico.
- Agrega clasificación de línea: venta enviada, pendiente/no enviada, cancelada o línea sin unidades.
- Agrega el importe de unidades enviadas, calculado como cantidad enviada × precio unitario.
- Presenta un resumen de pedidos con envío, piezas enviadas e importe enviado.
- Las líneas pendientes, canceladas o con cantidad cero no suman al resumen de ventas.
- No elimina ni modifica registros de Amazon, existencias, movimientos, asociaciones ni procesos de sincronización.

Publicación: subir todo el contenido de la carpeta `v27` a Vercel Drop y recargar con Ctrl+F5.
