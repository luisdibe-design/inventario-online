# V110 - Lectura segura de reservas activas

Se corrige el acceso del navegador a `inventory_reservations`: la tabla tiene RLS sin políticas de lectura directa para el cliente, por lo que V109 recibía una lista vacía aunque existieran reservas.

La UI ahora consulta la función RPC `get_active_inventory_reservations(p_base_key, p_skus)`, instalada en Supabase BIKEBEAT y autorizada únicamente para administradores activos autenticados. La función solo lee reservas `status='reserved'`, agrega cantidades por SKU y admite BIKEBEAT/ODKL.

El módulo de Kits muestra la cantidad real de reservas y calcula disponibilidad neta. La consulta no cambia stock, reservas ni movimientos.

Publica todo el contenido de `v27` en Vercel Drop y recarga con Ctrl+F5.
