# Inventario Online V104 – corrección del botón de conciliación ML

- Se incorpora la función `reconcileMlDeliveredReport` directamente en el script que carga `index.html` (V103 la tenía en `inline.js`, archivo que no se carga en esta versión).
- El botón ahora muestra estados y errores detallados de autenticación, conexión/CORS y respuesta HTTP.
- La conciliación sigue siendo exclusivamente de reportes: no descuenta inventario ni crea movimientos.

Despliegue: publicar el contenido de la carpeta `v27` mediante Vercel Drop, reemplazando la versión anterior.
