# V112 - Consistencia del detalle de disponibilidad de kits

Se corrige el detalle visual de componentes en el módulo Kits para mostrar el mismo stock neto usado por el cálculo de kits posibles.

Por componente:
disponible = max(0, stock físico - reservas activas - 1 pieza de seguridad).

No modifica existencias, reservas, recetas ni movimientos.

Publicar todo el contenido de v27 en Vercel Drop y recargar con Ctrl+F5.
