Inventario Online — Corrección de importes en Movimientos

Correcciones:
- En la lista inferior de productos ya registrados, los administradores ven el valor unitario promedio y el total calculado según las piezas registradas por producto.
- El encabezado de la lista de movimientos registrados también muestra el monto total del movimiento consultado para administradores.
- Los importes permanecen ocultos para los demás roles.
- Se actualizó la versión de caché del service worker para forzar la carga de los cambios al desplegar.

Despliegue: sube el contenido de este ZIP al proyecto de Vercel. Descargar el archivo no actualiza automáticamente la aplicación publicada.


## Prueba de Mercado Libre (solo lectura)
Esta versión añade en el Dashboard un botón de administrador para consultar hasta 10 pedidos recientes de la cuenta Bikebeat. Requiere que la Edge Function `mercadolibre-orders-test` esté publicada en Supabase Bikebeat y que la sesión actual tenga rol `admin`. No modifica inventario ni publicaciones. Para publicar, descomprime este ZIP y sube la carpeta/archivos al mismo proyecto mediante Vercel Drop, conservando los archivos del proyecto.


## Diagnósticos de conciliación Mercado Libre
- La tabla de historial muestra los códigos HTTP de ambas consultas de relación, origen de la relación, mensajes de error y los identificadores de pedido/paquete que el procesador guardó.
- El cambio es solo de interfaz y diagnóstico; no habilita descuentos automáticos ni crea movimientos de inventario.
- Para que aparezca en el sitio publicado, hay que desplegar estos archivos en el proyecto correcto de Vercel.


## Consulta directa de Mercado Libre (solo lectura)
- Se agregó un panel para consultar por pedido API, paquete o envío específico.
- Muestra estados/subestados, fechas, artículos, códigos HTTP y errores; no cambia existencias ni movimientos.
- Requiere la Edge Function `mercadolibre-orders-test` versión 6, que acepta `direct_lookup` para las consultas específicas.


## Diagnóstico visible del historial v22
- El historial de conciliación ahora muestra el número de paquete, subestado de envío, fecha de última consulta y diagnóstico de actualización guardados por Supabase.
- No modifica inventario ni registra movimientos.
- Para publicar, despliega el contenido completo del ZIP en el mismo proyecto de Vercel.


## Visualización de estado y subestado de envío
- En la tabla de "Probar conexión Mercado Libre" se muestran los campos de estado y subestado del envío cuando la función los devuelve.
- La interfaz mantiene la consulta en solo lectura y no modifica stock.
- La función de backend debe devolver `shipment_substatus` para mostrar el subestado real; si no lo devuelve, se verá `—`.


## Diagnóstico visible v25
- La consulta reciente de pedidos ahora permite expandir la respuesta JSON completa recibida de `mercadolibre-orders-test`.
- Si falla la consulta o la simulación de notificaciones, la pantalla muestra el mensaje y contexto técnico disponible.
- Se mantiene el modo de solo lectura: no se crean movimientos ni se descuenta inventario.
- Importante: este ZIP no contiene el código de las Edge Functions de Supabase. El reintento real de notificaciones `processing_error` requiere actualizar y desplegar la función backend correspondiente; el botón existente continúa siendo simulación y no debe confundirse con un reintento.


## Historial de pedidos Drop Off v27
- Se agregó una consulta de solo lectura para el historial guardado en `mercadolibre_bikebeat_dropoff_history`, con filtros por fecha y resultado, contadores y detalle técnico por pedido.
- Incluye estados de pedido/envío, paquete, envío, artículos/SKU/cantidad, resultado de inventario y observaciones.
- No ejecuta descuentos, reintentos ni devoluciones de stock. La publicación requiere desplegar el contenido del ZIP en el proyecto correcto de Vercel.


## v29 — Ajuste de movimientos
- Mejora los mensajes de error del botón Ajustar para que se vean en el panel del producto.
- Al quitar piezas de una salida, devuelve la cantidad al stock; al quitar piezas de una entrada, descuenta del stock.
- Evita dejar el stock en negativo al ajustar entradas.
- No altera automáticamente pedidos de Mercado Libre ni crea descuentos duplicados.


## v42 — Diagnóstico Mercado Libre seguro y de solo lectura
- Las herramientas de Mercado Libre quedan agrupadas en un panel secundario plegable: “Diagnóstico de Mercado Libre · Bikebeat”.
- “Probar conexión” y “Analizar pedidos” consultan únicamente `mercadolibre-orders-test`. La simulación ya no invoca `mercadolibre-notification-processor`.
- Se quitó de la interfaz el botón de sincronización/reproceso del historial, porque invocaba el procesador real y podía registrar salidas.
- “Historial de pedidos Drop Off · Bikebeat” solo consulta el historial guardado mediante “Consultar historial”; no sincroniza, reintenta ni cambia stock.
- La automatización real configurada en Supabase continúa por separado en segundo plano; estos cambios solo afectan la interfaz.
- Despliega el contenido completo de este ZIP en el proyecto correcto de Vercel para publicar los cambios.


## Indicadores de productos v51
- La etiqueta TRELLO aparece solo cuando el producto no está marcado para excluirlo de Trello. Si la casilla de exclusión está marcada, no se muestra esa etiqueta.
- Se conservan los colores de estado activo/inactivo y el resto de la interfaz.


## v54 — Sincronización de SKU entre Bikebeat y ODKL
- Al cambiar el SKU de un producto, se busca la contraparte en la otra base por el código de barras original y, si no tiene, por el SKU anterior.
- Si el SKU nuevo ya pertenece a otro producto en cualquiera de las dos bases, se rechaza el cambio y se muestra una advertencia.
- Si no se encuentra una contraparte inequívoca, no se permite cambiar el SKU, para evitar que las bases queden desincronizadas.
- Se actualiza únicamente el SKU en la otra base; stock, precios, movimientos y otros campos no se modifican.
- Se incrementó la caché del service worker para que la actualización se cargue tras desplegar.
- La sincronización requiere que la sesión tenga permisos de edición en ambas bases. La actualización entre dos proyectos Supabase no es una transacción única; si falla el guardado en la base actual, el sistema intenta revertir el SKU de la contraparte y muestra un aviso si la reversión también falla.


## v58 — Transferencia automática en ambos sentidos
- Si Bikebeat no tiene stock suficiente al registrar una salida, transfiere solo el faltante desde ODKL.
- Si ODKL no tiene stock suficiente al registrar una salida, transfiere solo el faltante desde Bikebeat.
- La transferencia registra salida en la base que aporta inventario y entrada en la base que recibe, con contraparte como cliente/proveedor, para consultar movimientos y reportes.
- Este ZIP modifica el frontend; no actualiza automáticamente el sitio publicado ni modifica existencias hasta que se registre un movimiento.


## v62 — Kits en base activa y salidas Mercado Libre Drop Off

- `inline.js` detecta Kits con los marcadores `QTY:` y `SKU:` en nombre, descripción, título o SKU.
- En salidas manuales, los Kits configurados no pasan por la transferencia automática entre Bikebeat y ODKL.
- La salida del Kit debe completarse mediante el trigger de Supabase en la base activa: primero descuenta el stock disponible del Kit y consume del componente solo las piezas correspondientes a la cantidad faltante.
- Se actualizó el nombre de caché del service worker a v62.
- Se incluye `supabase_migration_v62_kits_base_activa.sql` para ejecutar por separado en Bikebeat y ODKL. La migración reemplaza la función del trigger, no borra movimientos ni actualiza stock por sí sola.
- Mercado Libre Drop Off: el procesador de servidor `process_ml_outbound` vive en Supabase y no se publica con los archivos de Vercel. La función de Bikebeat ya calcula disponibilidad de Kits usando stock del Kit más unidades armables con el componente; el trigger de esta migración es el que realiza el consumo del componente cuando el procesador inserta la salida. No se debe afirmar que la lógica de servidor fue desplegada por subir este ZIP.
- Después de desplegar y aplicar la migración, probar primero con una cantidad controlada y verificar los movimientos del Kit y componente antes de procesar pedidos reales.

Despliegue: subir el contenido de `v27` a la raíz del proyecto Vercel. Ejecutar el SQL por separado en cada proyecto Supabase antes de probar Kits en esa base.


## v63 — Corrección de detección de Kits y exclusión de transferencia
- Corrige las expresiones regulares JavaScript para detectar QTY y SKU sin doble escape.
- Omite Kits configurados antes de preparar transferencias entre Bikebeat y ODKL.
- Conserva el trigger SQL de consumo de componentes de v62; la migración debe seguir aplicada en ambas bases.


## v64 — Kits en base activa
- Detección de Kits ampliada a todos los campos escalares del producto para localizar QTY y SKU aunque cambie la forma del resultado.
- La confirmación de cantidad no muestra advertencias de transferencia entre bases para Kits configurados.
- La validación final de stock de salida deja que el trigger de Supabase complete el faltante del Kit con el componente en la base activa.
- Caché del service worker actualizada a inventario-online-v464.


## v67 — Reporte de ventas entregadas de Mercado Libre
- Se añadió en Reportes el tipo “Mercado Libre — ventas entregadas (Bikebeat)”.
- Permite filtrar por fecha y logística (Full, Drop Off o ambas) y exportar a Excel o PDF con los controles existentes.
- Incluye pedido, envío, fecha, logística, SKU, código de barras, descripción, cantidad, precio unitario, importe de línea, moneda y referencia al movimiento de inventario.
- Consulta en solo lectura la vista `mercadolibre_bikebeat_delivered_sales`; solo está disponible al seleccionar la base Bikebeat. No registra movimientos ni cambia existencias.
- Si la vista aún no tiene precios recuperados para pedidos históricos, esos importes quedan en blanco y no se inventan.

Despliegue: descomprime el ZIP y sube el contenido de `v27` a la raíz del mismo proyecto de Vercel. Esta publicación de frontend no cambia las Edge Functions ni la base de datos.


## Corrección del reporte de ventas ML (v68)
- Se corrigió el nombre del campo de moneda para consultar `currency_id`, que es el campo real expuesto por la vista `mercadolibre_bikebeat_delivered_sales`.
- Se actualizó el identificador de caché para forzar la carga de los archivos nuevos.

## Módulo de publicaciones Mercado Libre Drop Off (V76)
- Se agregó la pantalla administrativa `Publicaciones ML`, con búsqueda por nombre/SKU/ID, filtro de estado, orden alfabético y selección masiva.
- El módulo invoca la Edge Function `mercadolibre-listing-manager` para consultar, pausar y reactivar publicaciones `xd_drop_off` de Bikebeat.
- Las publicaciones Full u otras logísticas quedan excluidas.
- Pausar/reactivar publicaciones no modifica existencias, movimientos ni reportes.
- La Edge Function `mercadolibre-inventory-sync` v6 sigue en modo solo vista previa y omite publicaciones pausadas.
- Antes de usar las acciones de pausa/reactivación, debe existir una conexión válida con permisos de lectura y escritura en Mercado Libre. Cada operación requiere confirmación explícita en pantalla.


## Manejo de kits virtuales con receta de varios SKU (v79)
- Al registrar una salida manual de un kit con receta activa en la base seleccionada, la app consulta `kit_recipes` y `kit_recipe_components`.
- Calcula los kits disponibles con el componente más limitado (`floor(stock / cantidad requerida)`).
- Antes de guardar, valida que haya existencias suficientes de todos los componentes.
- Registra salidas de los SKU componentes, no del SKU virtual del kit, para evitar dejar el kit con inventario negativo.
- Las salidas de componentes incluyen en notas el nombre y SKU del kit. El precio de venta del kit se distribuye proporcionalmente entre componentes para conservar el importe total del kit en el movimiento.
- No cambia publicaciones de Mercado Libre ni toca existencias al sincronizar; este cambio afecta únicamente las salidas manuales capturadas desde Movimientos.
- La app requiere que la receta ya exista en Supabase en la base correspondiente. Si la consulta de receta falla, la app muestra un error y no registra la salida del kit.

Prueba previa recomendada: en Bikebeat, el kit `MTKITPRESPMP` usa `VERPARCH24`, `FIXESPT` y `FIXCAL1` (1 unidad de cada uno). Con existencias 320, 31 y 9, la disponibilidad teórica debe ser 9 kits. No hagas una salida real de prueba si no quieres modificar inventario.


## Módulo administrativo de Kits virtuales (V80)
- Agrega el botón `Kits virtuales` al menú del Dashboard, disponible para administradores.
- Permite seleccionar el producto que representa el kit y agregar cualquier número de SKU componentes.
- Cada componente tiene su propia cantidad entera de piezas por kit (por ejemplo, SKU A × 2, SKU B × 1 y SKU C × 1). La cantidad por defecto es 1 y puede editarse.
- Permite guardar, editar, activar/desactivar recetas y consultar cuántos kits podrían prepararse según las existencias actuales del componente más limitado.
- Guardar una receta no modifica stock, movimientos ni publicaciones. Las salidas manuales de kits con receta activa usan las cantidades configuradas para calcular el consumo de cada SKU componente.
- Incluye `supabase_migration_v80_kits_virtuales.sql`. Ejecutar ese SQL en los proyectos Supabase de Bikebeat y ODKL si las tablas/políticas no existen aún en ambas bases. No es necesario ejecutar una migración de interfaz en Vercel; sí hay que desplegar el contenido del ZIP.
- El módulo no debe considerarse validado para ventas reales hasta probar con una receta de prueba y confirmar los movimientos generados.

## Kits virtuales: precios dinámicos (v81)
- El módulo de Kits virtuales consulta el precio de compra y el precio de venta vigentes de cada SKU componente.
- Calcula ambos importes multiplicando cada precio por las piezas requeridas por kit y sumando los componentes.
- Los importes se recalculan al cargar/actualizar el módulo, por lo que un cambio posterior en el precio de un componente se refleja sin editar el SKU virtual del kit.
- En las salidas de kits virtuales, los movimientos de los componentes conservan su precio de venta unitario vigente; no se usa el precio guardado en el SKU virtual.
- No se sobrescriben los precios de compra/venta guardados en los SKU componentes ni en el SKU virtual, y no se actualizan publicaciones de Mercado Libre.
- La consulta de precios no modifica existencias. El descuento de inventario sigue realizándose únicamente al registrar la salida del kit.


V84: Correccion de lectura PDF Full. Agrupa elementos de texto por cercania vertical y toma la cantidad desde la columna UNIDADES. Validado contra el PDF de envio 79907961: 163 productos y 2313 unidades. Sin cambios de inventario.


V85: Asignacion manual y permanente de SKU para productos Full sin SKU de origen. Busca productos en Bikebeat u ODKL, guarda la relacion por codigo ML en Bikebeat y vuelve a calcular existencias. Incluye migracion supabase_migration_v85_full_sku_mappings.sql. No modifica inventario ni movimientos al guardar una relacion.


## V89 — Kits virtuales desglosados en Consulta Full
- La consulta Full identifica SKU con receta virtual activa en Bikebeat u ODKL.
- Cada kit se expande a sus componentes según las cantidades configuradas en `kit_recipe_components`; por ejemplo, `VERTUBCMCJ40` requiere 40 piezas de `VERTUBCEM` por kit.
- La asignación de existencias prioriza Bikebeat y utiliza ODKL solo para cubrir faltantes de cada componente.
- La tabla y Excel muestran SKU del kit, componente, cantidad por kit, piezas requeridas, stock inicial, descuento propuesto, stock final y faltante por base.
- Los componentes compartidos entre distintos kits o renglones acumulan el consumo para evitar contar dos veces el mismo stock.
- La consulta sigue siendo de solo lectura: no crea movimientos ni modifica existencias.
- Requiere que las recetas de kits estén activas y que las tablas `kit_recipes` y `kit_recipe_components` existan en ambas bases.
