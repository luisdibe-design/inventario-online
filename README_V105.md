# V105 - Conciliación de Mercado Libre por bloques diarios

- La recuperación divide el periodo seleccionado en solicitudes independientes de un día.
- Muestra el avance por fecha y se detiene al primer error, indicando desde qué día continuar.
- Mantiene la conciliación exclusivamente de reportes; no procesa notificaciones, inventario ni movimientos.
- Requiere que la función Supabase `mercadolibre-report-reconcile` ya esté desplegada (versión 1 o posterior).

Publicar el contenido de `v27` mediante Vercel Drop. Para continuar después de un error, seleccionar como fecha inicial el día indicado por el mensaje.
