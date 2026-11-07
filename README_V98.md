# Inventario Online V98 · Trabajador de sincronización en simulación

Basada en V97.

## Incluye
- Nueva sección **Trabajador de sincronización · Prueba controlada** dentro de Sincronización de inventario ML.
- Llama a la Edge Function `inventory-sync-worker`.
- Limitada al SKU `3DLLANTAMOT` y publicación autorizada `MLM2983247363`.
- Cruza lectura de eventos pendientes BIKEBEAT + ODKL con la vista previa vigente de Mercado Libre.
- Muestra cantidad actual, cantidad objetivo, logística y decisión.

## Seguridad de esta versión
- Solo simulación / preview.
- No consume ni modifica eventos de las colas.
- No modifica existencias internas.
- No crea movimientos ni reportes.
- No ejecuta PUT a Mercado Libre.
- No activa cron ni sincronización general.

La Edge Function `inventory-sync-worker` debe estar desplegada en Supabase BIKEBEAT (versión 1, verify_jwt habilitado). La vista previa `inventory-sync-event-preview` y el RPC lector de BIKEBEAT/ODKL deben estar desplegados.
