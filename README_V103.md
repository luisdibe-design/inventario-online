# V103 — Recuperación segura de reportes de ventas Mercado Libre

- Añade en Reportes un botón administrativo para ejecutar `mercadolibre-report-reconcile` con la sesión JWT del administrador.
- Permite reconstruir ventas entregadas Full y Drop Off desde el rango seleccionado (por defecto, el rango actual del reporte).
- La función remota es independiente del procesador habitual de notificaciones.
- La conciliación solo actualiza/crea registros de control y datos de reporte; no descuenta inventario ni crea movimientos.
- Después de terminar, actualiza automáticamente la consulta del reporte si está seleccionado Mercado Libre — ventas entregadas.

Antes de usar: confirmar que la Edge Function `mercadolibre-report-reconcile` versión 1 esté activa en Supabase y que la sesión corresponda a un administrador de BIKEBEAT.
