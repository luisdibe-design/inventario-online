V96 - Prueba controlada de sincronización Drop Off (una publicación)

Basada en V95.
- Conserva la vista previa existente.
- Muestra una acción de prueba real únicamente cuando la vista previa confirma el caso esperado para MLM2983247363, SKU 3DLLANTAMOT, logística xd_drop_off, cantidad actual 0 y objetivo 2.
- La acción solicita una segunda confirmación explícita y llama a mercadolibre-inventory-sync con mode=apply_single.
- La Edge Function v14 limita el modo apply_single a MLM2983247363 y a la confirmación APPLY_ONE_MLM2983247363.
- No ofrece ejecución masiva ni modifica inventarios internos, movimientos o reportes.

Requiere Edge Function mercadolibre-inventory-sync version 14 activa.
