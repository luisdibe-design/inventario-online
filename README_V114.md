# V114 - Reporte histórico de ventas Amazon BIKEBEAT

Se agrega al módulo Reportes la opción **Amazon — ventas históricas (Bikebeat)**.

Incluye por línea de pedido: fecha, número de pedido, estado, programa logístico, canal, tipo de envío, SKU Amazon, ASIN, SKU BIKEBEAT, descripción, cantidad pedida/enviada, precio unitario, importe, moneda y estado de inventario.

Características:
- Consulta `public.amazon_orders` y `public.amazon_order_items` filtrando `inventory_base='BIKEBEAT'` y el periodo elegido.
- Relaciona el producto BIKEBEAT mediante `product_id` y muestra SKU/nombre cuando existe.
- Incluye estados de pedido (enviado, pendiente, cancelado, etc.) para que el histórico sea transparente.
- Permite ordenar en pantalla y exportar a Excel o PDF usando los controles existentes.
- Es de solo lectura: no descuenta existencias, no crea movimientos y no ejecuta recuperación ni sincronización.

Nota sobre futuras ventas: aparecerán en este reporte cuando el proceso de integración Amazon que esté activo siga insertando/actualizando los registros en `amazon_orders` y `amazon_order_items`. Este cambio agrega la consulta y presentación; no modifica ni activa el proceso de captura de pedidos.

Publicación: subir todo el contenido de la carpeta `v27` a Vercel Drop. Después, recargar la aplicación con Ctrl+F5 y entrar a Reportes en la base Bikebeat.
