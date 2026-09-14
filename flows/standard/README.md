# Flujos — Nivel Standard

Rama `nivel-standard`: incluye **todo el nivel Basic** (`flows/basic/`) **más** estos 3 flujos
encadenados, listos para adaptar a un pedido de nivel **Standard** ($150, entrega 5 días).

## Los 3 flujos y cómo se conectan

```
Cliente/Formulario
      │  POST /webhook/lead-standard
      ▼
┌─────────────────────────────┐
│ 1 - Captura de Lead → CRM    │
└──────────────┬───────────────┘
               │ POST interno /webhook/whatsapp-notify-standard
               ▼
┌─────────────────────────────┐        errores de 1 o 2
│ 2 - Notificación WhatsApp    │───┐    POST /webhook/error-alert-standard
└─────────────────────────────┘   │              │
                                   └──────────────▼
                                      ┌─────────────────────────────┐
                                      │ 3 - Manejo de Errores        │
                                      │     Centralizado             │
                                      └─────────────────────────────┘
```

1. **`1-captura-lead-crm.json`** — Webhook público → valida datos → crea el lead en el CRM del
   cliente (nodo HTTP Request genérico, configurable a cualquier API REST) → si tiene éxito, dispara
   el Flujo 2 llamando a su webhook interno; responde `200`/`400`/`500` al que llamó el webhook.
2. **`2-notificacion-whatsapp.json`** — Lo dispara el Flujo 1. Envía WhatsApp al operador con los
   datos del lead (WhatsApp Business Cloud API) y un mensaje de confirmación al lead.
3. **`3-manejo-errores-centralizado.json`** — Punto único de manejo de errores. Los Flujos 1 y 2 le
   reportan cualquier fallo (tras agotar sus reintentos automáticos) vía su webhook interno.
   Notifica al operador por Slack y, si Slack falla también, respalda por WhatsApp — nunca falla en
   silencio.

Este diseño (flujos conectados por webhooks internos, en vez de por ID de sub-workflow) es
intencional: **no requiere volver a enlazar nada después de importar** cada JSON por separado, más
allá de credenciales y variables de entorno.

## Cómo importar en n8n

1. Importa los 3 archivos (**Workflows → Import from File**), en cualquier orden.
2. Configura las credenciales referenciadas: CRM (header auth con `CRM_API_KEY`) y WhatsApp Cloud
   API (header auth con `WHATSAPP_TOKEN`).
3. Define las variables de entorno (ver `.env.example`): `CRM_API_URL`, `CRM_API_KEY`,
   `WHATSAPP_TOKEN`, `WHATSAPP_PHONE_ID`, `WHATSAPP_OPERATOR_NUMBER`, `SLACK_WEBHOOK_URL` y
   `N8N_INTERNAL_URL` (URL con la que un flujo llama a otro dentro de la misma instancia n8n — en
   local normalmente `http://localhost:5678`).
4. Activa los 3 flujos.
5. Prueba enviando un request al webhook del Flujo 1 (ver `casos-de-prueba.md`).

## Cómo adaptar al cliente real

- **CRM:** cambia la URL/headers del nodo **Crear Lead en CRM** al API real del cliente (HubSpot,
  Pipedrive, uno propio, etc.). Si el CRM tiene nodo nativo en n8n, puedes reemplazar el HTTP
  Request por ese nodo directamente.
- **WhatsApp:** si el cliente no usa WhatsApp Business API todavía, este flujo también sirve de
  base para Slack/Telegram — solo cambia el nodo de envío.
- **Errores:** el Flujo 3 es reutilizable tal cual para cualquier proyecto Standard — solo apunta
  ahí los nuevos flujos que agregues.

## Documentación de entrega

- `casos-de-prueba.md` — casos ejecutados antes de entregar (parte del alcance Standard).
- `guia-capacitacion.md` — mini-guía para la sesión de capacitación con el cliente.
- También aplica `templates/docs-basico.md` de la raíz, para el resumen ejecutivo del flujo.
