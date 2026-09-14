# Automatización de Procesos (n8n/Make) — Gig de Fiverr

Base reutilizable de flujos de automatización de negocio (leads, notificaciones, sincronización
entre apps) para el servicio ofrecido en Fiverr en 3 niveles: **Basic**, **Standard** y **Premium**.
No hay conversación con un usuario final: son procesos que corren en segundo plano cuando ocurre un
evento (formulario enviado, pedido creado, fecha próxima, etc.).

El objetivo es que, al llegar un pedido real, solo haya que **adaptar** un flujo existente en vez de
armarlo desde cero.

## 📦 Ramas del repo = paquetes por nivel

Cada rama es un paquete completo, listo para usar en cuanto llegue un pedido de ese nivel:

| Rama | Contiene |
|------|----------|
| `claude/sharp-edison-a5wvfq` (o `main`) | Solo nivel **Basic** |
| `nivel-standard` | Basic **+** Standard |
| `nivel-premium` | Basic **+** Standard **+** Premium |

**Esta rama (`nivel-premium`) trae el paquete completo: Basic + Standard + Premium.** Al llegar un
pedido Premium, haz checkout de esta rama y sigue `flows/premium/README.md`.

## Stack

- **Orquestador principal:** n8n (self-hosted en Railway/Render, o n8n cloud)
- **Alternativa mencionada en el gig:** Make (Integromat) — mismo concepto, sin código aparte
- **Apoyo (nodos custom/webhooks):** Node.js/TypeScript
- **Base de datos:** Google Sheets (Basic/Standard) o PostgreSQL/Airtable (Premium)
- **Notificaciones:** WhatsApp Business API, email (SMTP/Resend), Slack

## Estructura del repositorio (esta rama)

```
.
├── flows/
│   ├── basic/            # ✅ nivel Basic — 2 flujos de ejemplo
│   ├── standard/         # ✅ nivel Standard — 3 flujos encadenados
│   └── premium/          # ✅ nivel Premium — arquitectura modular de 6 flujos
├── custom-nodes/         # guía de cuándo sí hace falta un nodo custom real (Premium)
├── templates/
│   ├── docs-basico.md              # plantilla de documentación para el cliente (Basic)
│   ├── test-cases.md               # plantilla genérica de casos de prueba
│   └── mantenimiento-30-dias.md    # plantilla de soporte post-entrega (Premium)
├── db/
│   ├── schema.sql         # esquema PostgreSQL (leads, seguimiento, error_log)
│   └── README.md
├── Dockerfile / docker-compose.yml / INSTRUCCIONES_LOCAL.md
├── .env.example
└── README.md
```

## Nivel Basic — $60 (entrega 3 días)

**Alcance:** 1 flujo automatizado simple, 2 apps conectadas, documentación básica de uso.

- **`flows/basic/formulario-a-sheets.json`** — Webhook → validación/transformación → Google Sheets,
  con reintentos automáticos y notificación por email si falla el guardado tras los reintentos.
- **`flows/basic/recordatorio-cita.json`** — Sheets → filtro de citas próximas (24h) → email de
  recordatorio, con notificación de fallo al operador.

Ver `flows/basic/README.md` y `templates/docs-basico.md` (documentación de entrega, 1 página).

## Nivel Standard — $150 (entrega 5 días)

**Alcance:** 3 flujos conectados entre sí, pruebas documentadas, integración con CRM/WhatsApp,
capacitación breve al cliente.

- **`flows/standard/1-captura-lead-crm.json`** — Webhook → valida → crea el lead en el CRM del
  cliente → dispara el Flujo 2.
- **`flows/standard/2-notificacion-whatsapp.json`** — Lo dispara el Flujo 1. Notifica al operador
  por WhatsApp Business Cloud API y confirma al lead.
- **`flows/standard/3-manejo-errores-centralizado.json`** — Punto único de errores: si 1 o 2 fallan
  (tras sus reintentos), les reporta aquí; notifica por Slack y respalda por WhatsApp si Slack falla.

Ver `flows/standard/README.md`, `flows/standard/casos-de-prueba.md` y
`flows/standard/guia-capacitacion.md`.

## Nivel Premium — $300 (entrega 10 días)

**Alcance:** sistema completo (6+ flujos/apps conectadas), base de datos/CRM real, integraciones
API custom, 30 días de soporte post-entrega.

Arquitectura modular — captura / procesamiento / notificación-acción, más seguimiento y manejo de
errores, todos conectados por webhooks internos:

- **`flows/premium/1-captura-datos.json`** — Webhook → valida → guarda el lead en **PostgreSQL**
  → dispara el Flujo 2.
- **`flows/premium/2-procesamiento.json`** — Scoring y deduplicación del lead → dispara el Flujo 3.
- **`flows/premium/3-notificacion-accion.json`** — WhatsApp al operador + email al cliente +
  sincronización con el CRM.
- **`flows/premium/4-seguimiento-programado.json`** — Cron diario: seguimiento automático a leads
  sin contacto en 3+ días.
- **`flows/premium/5-integracion-custom-api.json`** — Capa de integración custom (HTTP Request
  configurado) para APIs que n8n no soporta nativamente, p. ej. enriquecimiento de datos.
- **`flows/premium/6-manejo-errores-centralizado.json`** — Registra cada error en PostgreSQL
  (`error_log`) y notifica por Slack, con respaldo por WhatsApp.

Incluye `db/schema.sql` (esquema de leads/seguimiento/errores) y
`templates/mantenimiento-30-dias.md` (documento de soporte post-entrega). Ver
`flows/premium/README.md` para el diagrama completo y el detalle de cada flujo.

## Probar localmente con Docker

Hay un `Dockerfile` (imagen oficial de n8n) y un `docker-compose.yml` para levantar una instancia
local (además de n8n, el nivel Premium necesita una base PostgreSQL — ver
`INSTRUCCIONES_LOCAL.md`). **Importante:** levantar el contenedor tal cual no importa los flujos
automáticamente — la instancia arranca vacía. `INSTRUCCIONES_LOCAL.md` explica qué verás en cada
paso y cómo importar/probar los flujos de los 3 niveles.

## Cómo empezar

1. Levanta n8n (self-hosted, n8n cloud, o el Docker local de este repo) y copia `.env.example` a
   `.env` con tus credenciales/variables reales.
2. **Basic:** importa `flows/basic/` (ver `flows/basic/README.md`).
3. **Standard:** importa además `flows/standard/` (ver `flows/standard/README.md`), configura
   credenciales de CRM y WhatsApp, y ejecuta `flows/standard/casos-de-prueba.md` antes de entregar.
4. **Premium:** aplica `db/schema.sql`, importa `flows/premium/` (ver `flows/premium/README.md`),
   configura PostgreSQL/CRM/WhatsApp/API custom.
5. Adapta campos/hoja/CRM/scoring al caso real del cliente.
6. Entrega con `templates/docs-basico.md`, `flows/standard/guia-capacitacion.md` y, en Premium,
   `templates/mantenimiento-30-dias.md`.

## Variables de entorno

Ver `.env.example` para la lista completa (`N8N_HOST`, `N8N_INTERNAL_URL`, `WHATSAPP_TOKEN`,
`WHATSAPP_PHONE_ID`, `WHATSAPP_OPERATOR_NUMBER`, `GOOGLE_SHEETS_CREDENTIALS`, `CRM_API_URL`,
`CRM_API_KEY`, `SLACK_WEBHOOK_URL`, `DATABASE_URL`, `CUSTOM_API_URL`, `CUSTOM_API_KEY`, etc.). Nunca
subir el archivo `.env` real al repositorio.
