# Mini-guía de Capacitación — Nivel Standard

> Para la sesión breve de capacitación incluida en el nivel Standard. Completar los campos entre
> `[ ]` y recorrerla en vivo con el cliente (15-20 min sugeridos).

## 1. Qué automatizamos

Tres flujos conectados: cuando llega un lead (`[origen: formulario del sitio / landing / etc.]`),
se guarda automáticamente en tu CRM y tu equipo recibe un WhatsApp al instante. Si algo falla en el
camino, el equipo se entera solo, sin que se pierda ningún lead.

## 2. Cómo revisar que todo corrió bien

1. Entra a n8n: `[URL_N8N]`
2. **Workflows** → abre cualquiera de los 3 flujos → pestaña **Executions**.
3. ✅ verde = corrió bien. ❌ rojo = falló (y ya debería haber llegado una alerta a Slack/WhatsApp).
4. Confirma también directamente en tu CRM: `[enlace al CRM]`.

## 3. Cómo modificar lo más común

- **Cambiar el mensaje de WhatsApp:** abre el Flujo 2 (`Notificación WhatsApp`) → nodo
  **Enviar WhatsApp al Operador** → edita el texto dentro de `text.body`.
- **Agregar/quitar un campo del formulario:** Flujo 1 → nodo **Normalizar Datos** → agrega el
  campo nuevo ahí y en el nodo **Crear Lead en CRM** (`jsonBody`).
- **Cambiar a quién le llega la alerta de error:** Flujo 3 → variables `SLACK_WEBHOOK_URL` /
  `WHATSAPP_OPERATOR_NUMBER` (en la configuración de entorno, no dentro del flujo).
- **Pausar un flujo temporalmente:** toggle **Active** arriba a la derecha del editor — no borres
  el flujo, solo desactívalo.

## 4. Qué NO tocar sin avisar

- Los nodos de tipo **Webhook** (cambiar su `path` rompe la integración con el formulario/origen).
- Las credenciales guardadas en **Credentials** (si expiran, avisa antes de regenerarlas).

## 5. Soporte

- **Incluido en esta entrega:** `[ej. 7 días de ajustes menores]`
- **Contacto:** `[email / Fiverr]`
- Para cambios más grandes (nuevos flujos, otra integración), es un pedido nuevo — con gusto se
  cotiza aparte.
