# Inventario Online V101 · Sincronización de variante ML Negro

## Corrección
- `CRCNGSILC` se dirige a la publicación padre `MLM1345474530`, variante Negro.
- La Edge Function `mercadolibre-variant-stock-sync` (BIKEBEAT) consulta el recurso actual de Mercado Libre y busca una coincidencia única del SKU entre las variantes.
- La vista previa muestra ID de variante, SKU detectado, stock actual, objetivo y estado de publicación.
- El procesamiento real envía únicamente `variations: [{ id, available_quantity }]` para esa variante. No envía `status`, no reactiva la publicación, no cambia otras variantes ni modifica inventario interno.
- Logística debe confirmarse como Drop Off; Full y logística desconocida quedan bloqueadas.
- Stock objetivo: `floor(stock activo BIKEBEAT + stock activo ODKL) - 1` (reserva de una pieza).
- Los eventos de cola, si existen, solo se cierran después de verificar el stock de la variante. La operación de stock no depende de que existan eventos pendientes.
- `3DLLANTAMOT` conserva su flujo previo de prueba controlada.

## Despliegue
1. La Edge Function `mercadolibre-variant-stock-sync` ya está desplegada en Supabase BIKEBEAT, versión 1, con JWT obligatorio.
2. Sube el contenido de esta carpeta `v27` a la raíz del proyecto Vercel existente, reemplazando los archivos.
3. Abre la app y pulsa `Ctrl + F5`.
4. En BIKEBEAT, escribe `CRCNGSILC` en “SKU a consultar”.
5. Pulsa “Ejecutar simulación controlada”. Revisa que el SKU detectado sea `CRCNGSILC`, el item `MLM1345474530`, la logística sea `xd_drop_off`, el objetivo sea 53 y se muestre el estado pausado.
6. Si el preview identifica una sola variante Negro y los valores son correctos, pulsa “Procesar prueba real del SKU seleccionado” y confirma.

**No ejecutar sincronización general ni activar cron.** Si el preview indica `variant_sku_not_found` o `variant_sku_ambiguous`, no procesar: revisar el detalle de variantes y su SKU antes de cambiar nada.
