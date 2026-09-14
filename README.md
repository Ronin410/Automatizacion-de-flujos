# Automatización de Procesos (n8n/Make) — Gig de Fiverr

Base reutilizable de flujos de automatización de negocio (leads, notificaciones, sincronización
entre apps) para el servicio ofrecido en Fiverr en 3 niveles: **Basic**, **Standard** y **Premium**.
No hay conversación con un usuario final: son procesos que corren en segundo plano cuando ocurre un
evento (formulario enviado, pedido creado, fecha próxima, etc.).

El objetivo es que, al llegar un pedido real, solo haya que **adaptar** un flujo existente en vez de
armarlo desde cero.

## Stack

- **Orquestador principal:** n8n (self-hosted en Railway/Render, o n8n cloud)
- **Alternativa mencionada en el gig:** Make (Integromat) — mismo concepto, sin código aparte
- **Apoyo (nodos custom/webhooks):** Node.js/TypeScript
- **Base de datos ligera:** Google Sheets (Basic/Standard) o PostgreSQL/Airtable (Premium)
- **Notificaciones:** WhatsApp Business API, email (SMTP/Resend), Slack

## 🗺️ Diagramas

`docs/DIAGRAMAS.md` — diagrama de flujo (nodo por nodo), diagrama de proceso (ciclo de vida del
lead) y diagrama de infraestructura, en Mermaid (se ven directo en GitHub). Versión interactiva del
sistema completo (con pestañas Basic/Standard/Premium):
[Anatomía del Pipeline](https://claude.ai/code/artifact/7fbda57d-0aee-4dc9-82d1-dc943924b19c).

## Estructura del repositorio

```
.
├── flows/
│   ├── basic/            # ✅ flujos de ejemplo nivel Basic (implementado)
│   ├── standard/         # 🚧 pendiente
│   └── premium/          # 🚧 pendiente
├── custom-nodes/         # 🚧 pendiente — nodos/integraciones custom (Premium)
├── templates/
│   ├── docs-basico.md    # plantilla de documentación para el cliente
│   └── test-cases.md     # plantilla de casos de prueba (Standard+)
├── db/                    # 🚧 pendiente — esquemas de base de datos (Premium)
├── docs/
│   └── DIAGRAMAS.md      # diagramas de flujo, proceso e infraestructura (Mermaid)
├── .env.example
└── README.md
```

## Nivel Basic — $60 (entrega 3 días)

**Alcance:** 1 flujo automatizado simple, 2 apps conectadas, documentación básica de uso.

Incluido en este scaffold (`flows/basic/`):

- **`formulario-a-sheets.json`** — Webhook → validación/transformación → Google Sheets, con
  reintentos automáticos y notificación por email si falla el guardado tras los reintentos.
- **`recordatorio-cita.json`** — Sheets → filtro de citas próximas (24h) → email de recordatorio,
  con notificación de fallo al operador.

Ambos ya incluyen manejo básico de errores (reintento + notificación de fallo), tal como pide el
alcance de este nivel. Ver `flows/basic/README.md` para el detalle de cada nodo y cómo adaptarlos.

Para la entrega al cliente, usa `templates/docs-basico.md` como plantilla de la documentación de
1 página (qué hace el flujo y cómo revisarlo).

## Probar localmente con Docker

Hay un `Dockerfile` (imagen oficial de n8n) y un `docker-compose.yml` para levantar una instancia
local. **Importante:** levantar el contenedor tal cual no importa los flujos automáticamente — la
instancia arranca vacía. Ver `INSTRUCCIONES_LOCAL.md` para el paso a paso completo (incluye qué
verás exactamente en cada paso y cómo importar y probar `flows/basic/`).

## Niveles Standard y Premium

Aún no scaffoldeados — quedan carpetas placeholder (`flows/standard/`, `flows/premium/`,
`custom-nodes/`, `db/`) con una nota de qué falta, listas para completarse cuando se aborde ese
nivel. El alcance completo de los tres niveles está documentado en `gig2-automatizacion-spec.md`.

## Cómo empezar (Basic)

1. Levanta n8n (self-hosted o cloud) y copia `.env.example` a `.env` con tus credenciales reales.
2. Importa los flujos de `flows/basic/` (ver `flows/basic/README.md` para el paso a paso).
3. Configura las credenciales de Google Sheets y SMTP en n8n.
4. Prueba el webhook y confirma la escritura en Sheets / el envío del recordatorio.
5. Adapta los campos/hoja de destino al caso real del cliente.
6. Completa `templates/docs-basico.md` y entrégalo junto con el flujo.

## Variables de entorno

Ver `.env.example` para la lista completa (`N8N_HOST`, `N8N_API_KEY`, `WHATSAPP_TOKEN`,
`GOOGLE_SHEETS_CREDENTIALS`, `DATABASE_URL`, `CRM_API_KEY`, etc.). Nunca subir el archivo `.env`
real al repositorio.
