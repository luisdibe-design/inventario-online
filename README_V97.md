V97 - Consulta de cola de sincronización BIKEBEAT + ODKL

Basada en V96.
- Agrega en la sección "Sincronización de inventario ML" una consulta de eventos pendientes por SKU.
- Invoca inventory-sync-event-preview (versión 5 activa en Supabase).
- Muestra conteos separados de BIKEBEAT y ODKL, eventos agrupados, existencias actuales combinadas y publicaciones relacionadas.
- Consulta de solo lectura: no consume ni marca eventos, no modifica inventario, movimientos, reportes ni publicaciones de Mercado Libre.
- Mantiene intacta la prueba individual existente para MLM2983247363 / 3DLLANTAMOT.

Requisitos:
- Publicar este contenido web en Vercel.
- Edge Function inventory-sync-event-preview versión 5 activa en BIKEBEAT.
- Secrets de conexión ODKL configurados en la Edge Function.
