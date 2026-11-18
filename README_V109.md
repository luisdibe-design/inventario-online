# V109 - Disponibilidad de kits considerando reservas activas

- El módulo Kits consulta `inventory_reservations` de la base activa y suma únicamente registros con `status = reserved`.
- La disponibilidad se calcula por componente: `max(0, stock físico - reservas activas)`.
- La columna de componentes muestra stock físico, reservado y disponible.
- Kits posibles ahora utiliza el disponible neto, no el stock físico bruto.
- La consulta falla visiblemente si no puede leer reservas; no presenta cantidades optimistas sin verificar.
- La validación de salidas manuales de kits con receta también descuenta reservas activas.
- No modifica existencias, reservas ni movimientos al consultar.

## Despliegue
1. Publica el contenido de `v27` en Vercel Drop.
2. Actualiza el navegador con Ctrl+F5.
3. Abre Kits y pulsa Actualizar.
4. Para `VERTUBCEM10`, con 10 físicos y 1 reservado de `VERTUBCEM`, debe mostrar 9 disponibles y 0 kits posibles.
