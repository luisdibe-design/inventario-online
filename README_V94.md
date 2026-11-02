# V94 – Pausa y reactivación por grupos

Esta versión parte de V93 y conserva sus módulos y migraciones.

## Cambio
- El módulo de administración de publicaciones Mercado Libre divide las selecciones en grupos de hasta 50 publicaciones.
- Procesa cada grupo secuencialmente mediante la Edge Function existente `mercadolibre-listing-manager` (que admite hasta 100 IDs por llamada).
- Aplica la misma lógica a pausar y reactivar.
- Muestra progreso y resumen por publicación.
- Si una llamada de grupo falla sin confirmación, continúa con los demás grupos, marca ese grupo como no confirmado y advierte que se verifique en Mercado Libre antes de reintentar.
- No modifica inventario, movimientos ni reportes.

## Instalación
Subir el contenido de la carpeta `v27` a Vercel como en las versiones anteriores. No requiere migración SQL ni despliegue de Edge Function para este ajuste.
