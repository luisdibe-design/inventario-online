# Inventario Online V100 · Pruebas controladas de sincronización ML

- La interfaz permite seleccionar dinámicamente únicamente dos pruebas autorizadas: `3DLLANTAMOT` / `MLM2983247363` y `CRCNGSILC` / `MLM1379058000`.
- La simulación y el procesamiento real usan el SKU seleccionado y sus credenciales de confirmación específicas.
- No habilita sincronización general, no activa cron y no modifica inventario interno.
- Full debe continuar excluido por la Edge Function.

## Publicación
Subir el contenido de la carpeta `v27` a Vercel reemplazando los archivos de la versión anterior. El service worker usa caché `inventario-online-v100`; después de publicar, abrir la app y hacer `Ctrl + F5`.

## Prueba
1. Mantener la base Bikebeat.
2. Consultar `CRCNGSILC` en la cola (la consulta puede mostrar cero eventos; es válido).
3. Ejecutar simulación controlada. Confirmar que la publicación devuelta sea `MLM1379058000`, logística `xd_drop_off` y que el objetivo se calcule con stock actual de ambas bases menos una reserva.
4. No procesar en real hasta revisar esa simulación.
5. La prueba real permanece limitada a las dos publicaciones indicadas.
