# V117 - Alertas y revisión de pedidos Amazon

Cambios de esta entrega:
- Indicador en el Dashboard con el número de pedidos Amazon que requieren revisión.
- Nuevo módulo **Alertas pedidos Amazon**, con lectura de notificaciones `ORDER_CHANGE` que quedaron en `review` o `error`.
- Muestra número de pedido, SKU, cantidad, modalidad, estado y motivo detectado.
- Permite a perfiles Administrador y Almacén confirmar la relación SKU Amazon → producto BIKEBEAT para Easy Ship. La asociación queda registrada en `amazon_sku_mappings` como `easy_ship`.
- Después de confirmar el SKU, permite volver a consultar el pedido en Amazon y reintentar el procesamiento. También permite reintentar después de corregir existencias.
- El reintento usa la Edge Function existente `amazon-order-review-retry` (que valida el perfil Administrador/Almacén y después llama a `amazon-order-event-process`), que vuelve a consultar Amazon y llama al procesador idempotente de inventario. Si el movimiento ya existe, no debe duplicarlo.
- Los pedidos FBA/AFN no se muestran como pendientes de descuento. Seller Flex o modalidades no confirmadas no se descuentan desde este módulo.
- Los perfiles Ventas y Consulta pueden ver las alertas, pero no editar asociaciones ni reintentar.
- Se agregó permiso SELECT de solo lectura a `amazon_notification_events` para roles de la aplicación, protegido por RLS.

Protecciones:
- El reintento requiere confirmación del usuario.
- El módulo no modifica movimientos históricos ni hace ajustes manuales de inventario.
- No cambia Mercado Libre, sus funciones ni sus programaciones.
- No fuerza la modalidad Easy Ship: la vuelve a consultar con Amazon y el procesador solo descuenta si la modalidad queda confirmada.
- Si el problema es falta de stock, no modifica cantidades; el usuario debe corregir la existencia y pulsar Reintentar.

Publicación:
1. Descomprimir el ZIP.
2. En Vercel Drop, subir el contenido de la carpeta `v27` (no la carpeta contenedora).
3. Abrir Inventario Online y recargar con Ctrl+F5.
4. Entrar a **Alertas pedidos Amazon** desde el Dashboard, usando la base BIKEBEAT.

Nota: la política de lectura de `amazon_notification_events` ya se aplicó en Supabase. No se modificaron pedidos ni movimientos existentes durante la preparación de esta interfaz.
