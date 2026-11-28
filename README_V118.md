# V118 - Detalle de pedidos y fechas Amazon Easy Ship en Movimientos

Cambios de esta entrega:
- En BIKEBEAT, al consultar las salidas de la paquetería/cliente Amazon Easy, se muestra un detalle individual por pedido para las nuevas salidas automáticas Amazon Easy Ship.
- Cada pedido muestra número de pedido, estado, fecha de compra, fecha de creación del pedido, fecha de salida del inventario, fecha límite de envío y ventana estimada de entrega.
- Cada línea muestra producto BIKEBEAT, SKU BIKEBEAT, SKU Amazon, ASIN y cantidad descontada.
- El detalle es de solo lectura y se agrega debajo del resumen habitual de movimientos.

Protecciones:
- Solo incluye movimientos automáticos Easy Ship creados desde el 28/11/2026 02:50 UTC.
- No modifica, corrige, agrupa de nuevo ni vuelve a procesar movimientos históricos.
- No cambia existencias, asociaciones, notificaciones ni procesos de sincronización.
- La fecha de entrega se presenta como ventana estimada de Amazon, no como entrega confirmada.
- La consulta se limita a BIKEBEAT y a salidas de Amazon Easy Ship.

Publicación:
1. Descomprimir el ZIP.
2. En Vercel Drop, subir el contenido completo de la carpeta `v27` (no la carpeta contenedora) al proyecto `inventario_online_v4`.
3. Abrir https://inventarioonlinev4.vercel.app/ y recargar con Ctrl+F5.
4. Entrar a Movimientos → Salida → Amazon Easy Biker Beat y elegir la fecha de salida.
