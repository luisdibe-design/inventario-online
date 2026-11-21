# V116 - Reporte histórico Amazon y preparación de sincronización

Cambios de esta entrega:
- El reporte Amazon conserva la clasificación y resumen de V115.
- La consulta de pedidos ahora pagina en bloques de 1,000 registros para no quedarse en el límite de una sola consulta.
- Se desplegó en Supabase la Edge Function `amazon-orders-sync-daily` (versión 1), diseñada para recuperar pedidos y partidas por paginación, con modo de carga inicial de hasta 120 días y modo incremental por `lastUpdatedAfter`.
- La función declara explícitamente `inventory_modified: false` y `movements_created: false`.

IMPORTANTE:
- La programación diaria y la ejecución de la carga inicial de 90 días todavía no están activadas. No considerar la sincronización automática operativa hasta configurar y verificar el disparador seguro.
- No se modificaron existencias, movimientos ni asociaciones.

Publicación de la interfaz: subir el contenido de `v27` a Vercel Drop y recargar con Ctrl+F5.
