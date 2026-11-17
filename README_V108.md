# V108 - Módulo de cancelaciones

- Agrega al Dashboard el indicador **Cancelados hoy**, junto a **Salidas hoy**.
- El contador consulta cancelaciones únicas de Mercado Libre BIKEBEAT con logística `xd_drop_off`, usando el estado cancelado y la fecha de última actualización/cancelación en horario de Ciudad de México.
- Agrega la pantalla **Cancelaciones** con filtros de plataforma, rango de fechas y búsqueda por pedido, envío, paquete, SKU o producto.
- Permite exportar los resultados consultados a Excel.
- La pantalla es de solo lectura: no crea salidas, no descuenta inventario y no ejecuta devoluciones.
- El registro del envío `48547641367` / pedido `2000019599255860` aparece como una cancelación Drop Off del 16-11-2026.

## Alcance actual
- Mercado Libre Drop Off: conectado al historial `mercadolibre_bikebeat_dropoff_history` de BIKEBEAT.
- Amazon, TikTok y Shein: aparecen como opciones de filtro y se identifican como **Sin conexión**. Para contabilizarlas será necesario conectar sus fuentes de pedidos/notificaciones y alimentar el mismo módulo; no se muestran ceros falsos.
- No se importan cancelaciones históricas anteriores; los filtros permiten consultar fechas disponibles en el historial, pero el Dashboard cuenta solo el día actual.

## Despliegue
1. Publica el contenido de `v27` en Vercel Drop.
2. Inicia sesión y revisa el indicador **Cancelados hoy**.
3. Abre **Cancelaciones** para consultar y exportar el detalle.

No requiere migración SQL adicional. Utiliza la tabla existente de historial Drop Off.
