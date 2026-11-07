# Inventario Online V99 — procesamiento controlado de sincronización

## Cambios
- Agrega acción explícita para procesar únicamente SKU `3DLLANTAMOT` y publicación `MLM2983247363`.
- Requiere confirmación del administrador en pantalla.
- El trabajador consulta eventos pendientes y la vista vigente de Mercado Libre.
- Si la publicación ya coincide, no envía PUT; si requiere cambio, usa el modo individual ya protegido de `mercadolibre-inventory-sync`.
- Marca como procesados únicamente los IDs exactos de eventos del SKU y de cada base, después de confirmar el resultado.
- Los errores dejan los eventos pendientes.
- No modifica inventario interno, movimientos ni reportes. No activa cron ni sincronización general.

## Despliegue
Subir el contenido de `v27` a Vercel reemplazando los archivos de la versión anterior. La función Edge `inventory-sync-worker` versión 3 y las funciones SQL de finalización ya están desplegadas en Supabase; no hay que activar cron.

## Prueba
1. Entrar en Sincronización de inventario ML desde la base Bikebeat.
2. Mantener SKU `3DLLANTAMOT`.
3. Ejecutar primero la simulación.
4. Solo si los datos muestran 4 eventos y la publicación `MLM2983247363` con logística Drop Off, pulsar `Procesar prueba real de 3DLLANTAMOT` y confirmar el cuadro.
5. Consultar de nuevo la cola. Debe mostrar 0 pendientes de ese SKU si la finalización fue exitosa.

No usar este botón para otros SKU. Full permanece excluido.
