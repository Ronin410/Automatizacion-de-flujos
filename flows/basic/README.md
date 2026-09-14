# Flujos — Nivel Basic

Flujos de ejemplo listos para adaptar a un pedido real de nivel **Basic** ($60, entrega 3 días).

## Flujos incluidos

### 1. `formulario-a-sheets.json`
**Formulario (Webhook) → validación → Google Sheets, con manejo de errores.**

- **Trigger:** Webhook (`POST /webhook/lead-form`).
- **Transformación:** normaliza nombre, email, teléfono, mensaje y agrega fecha de recepción.
- **Validación:** nombre no vacío + email con formato válido. Si falla, responde `400` sin escribir en Sheets.
- **Acción principal:** agrega una fila en Google Sheets (hoja `Leads`).
- **Manejo de errores:** si Google Sheets falla, reintenta automáticamente 3 veces (cada 5s). Si aun así falla, envía un email de alerta al operador con los datos del lead y responde `500` al cliente para que sepa que algo salió mal (sin perder los datos, ya que van en el correo).
- **2 apps conectadas:** el formulario/origen del webhook + Google Sheets (+ Email para alertas).

### 2. `recordatorio-cita.json`
**Recordatorio automático de cita: Google Sheets → Email, 24h antes.**

- **Trigger:** Schedule (corre cada 3 horas).
- **Lógica:** lee la hoja `Citas` (columnas `Nombre`, `Email`, `FechaCita`, `Estado`), filtra las citas dentro de las próximas 24h que no han sido recordadas.
- **Acción principal:** envía email de recordatorio y marca la fila como `Recordado` para no duplicar envíos.
- **Manejo de errores:** si el envío de email falla, notifica al operador para seguimiento manual.

## Cómo importar en n8n

1. En n8n: **Workflows → Import from File** y selecciona el `.json` del flujo.
2. Configura las credenciales referenciadas (`Google Sheets - Cliente`, `SMTP - Alertas`) en **Credentials**.
3. Reemplaza las variables de entorno usadas (`GOOGLE_SHEETS_DOCUMENT_ID`, `ALERTS_FROM_EMAIL`, `ALERTS_TO_EMAIL`) — ver `.env.example` en la raíz del repo.
4. Activa el flujo (`Active`) y prueba con una ejecución manual o un request real al webhook.

## Cómo adaptar al cliente real

- Cambia los campos del formulario en el nodo **Normalizar Datos** según lo que el cliente capture.
- Cambia el nombre/columnas de la hoja de Sheets en el nodo **Guardar en Sheets**.
- Si el cliente usa otro canal de notificación de fallos (WhatsApp/Slack) en vez de email, reemplaza el nodo **Notificar Fallo (Email)** — la lógica de reintento/error no cambia.
- Usa `templates/docs-basico.md` para generar la documentación de entrega.
