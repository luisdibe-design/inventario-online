# V111 - Reserva de seguridad de una pieza para kits

- Todas las recetas activas de kits descuentan las reservas activas del componente y además 1 pieza de seguridad por componente.
- Regla: disponible = max(0, stock físico - reservas activas - 1).
- La regla se aplica a componentes de recetas y al cálculo de kits QTY:/SKU:.
- La vista de kits muestra stock físico, reservas activas, reserva de seguridad y disponible neto.
- La función mercadolibre-inventory-sync quedó desplegada en Supabase BIKEBEAT v41 y aplica la misma regla al stock combinado BIKEBEAT + ODKL.
- Full continúa excluido. No se cambian existencias ni reservas al consultar.

Publicar todo el contenido de v27 en Vercel Drop y recargar con Ctrl+F5.
