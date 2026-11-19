# V113 - Asociaciones de SKU Amazon

Se agrega el módulo **Asociaciones Amazon** (solo visible para administradores) en la base BIKEBEAT.

Permite:
- Registrar SKU de Amazon, ASIN opcional y modalidad: Easy Ship, FBA, Flex, envío por vendedor o general.
- Buscar y vincular un producto existente de BIKEBEAT por SKU o descripción.
- Consultar, filtrar, editar y activar/desactivar asociaciones.

Importante:
- Guardar o editar una asociación NO modifica existencias, NO crea movimientos y NO activa sincronización con Amazon.
- El módulo consulta la tabla `public.amazon_sku_mappings` ya preparada en Supabase.
- La administración de asociaciones se limita a BIKEBEAT; ODKL no se modifica.
- No se modifican las funciones ni los procesos de Mercado Libre.

Publicación: subir el contenido completo de la carpeta `v27` a Vercel Drop. Después, recargar la aplicación con Ctrl+F5 e ingresar con un usuario administrador en la base BIKEBEAT.
