# Inventario Online V102 · Consulta de variantes de publicaciones ML

## Novedad
- Se agregó en **Sincronización de inventario ML · Vista previa (Bikebeat)** el bloque **Consulta de variantes por publicación · Solo lectura**.
- Permite consultar hasta 20 publicaciones mediante la Edge Function `mercadolibre-variants-preview` ya desplegada en Supabase BIKEBEAT.
- Presenta publicación, número de variantes, ID de variante, SKU, color/atributos, existencias BIKEBEAT y ODKL, stock combinado, disponible en Mercado Libre, objetivo calculado y elegibilidad logística.
- No realiza PUT a Mercado Libre, no modifica existencias internas, no crea movimientos ni consume eventos de la cola.
- Conserva los IDs ingresados que no tengan formato de publicación reconocido y los informa sin convertirlos. Para Mercado Libre México se espera normalmente `MLM` + 10 dígitos o el ID numérico de 10 dígitos.

## Publicaciones de prueba precargadas
- `6359717638534609` — formato no reconocido por la API de publicaciones; se muestra como no consultado.
- `3884587500969362` — formato no reconocido por la API de publicaciones; se muestra como no consultado.
- `1810283438` — se consulta como `MLM1810283438`.
- `3812977909314897` — formato no reconocido por la API de publicaciones; se muestra como no consultado.

Los IDs de 16 dígitos no se convierten ni se truncan. Si son realmente IDs de publicación principal, se debe confirmar el ID desde la URL de Mercado Libre; podrían corresponder a otro identificador.

## Despliegue
1. Descomprime el ZIP y sube **el contenido de la carpeta `v27`** a la raíz del proyecto en Vercel Drop, reemplazando los archivos actuales.
2. Abre Inventario Online y fuerza recarga con `Ctrl + F5`.
3. Cambia a la base BIKEBEAT.
4. Abre **Sincronización de inventario ML · Vista previa (Bikebeat)**.
5. En **Consulta de variantes por publicación · Solo lectura**, pulsa **Consultar variantes**.
6. Revisa la publicación `MLM1810283438` y confirma los tres IDs de 16 dígitos desde la URL pública de cada anuncio antes de volver a consultarlos.

**No ejecutar sincronización general ni activar cron.** La función de consulta requiere sesión de administrador y la conexión de Mercado Libre vigente.
