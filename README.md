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

**Esta rama (`nivel-standard`) trae Basic + Standard.** Al llegar un pedido Standard, haz checkout
de esta rama (o mergea/cherry-pickea `flows/standard/` a donde trabajes) y sigue `flows/standard/README.md`.

## 🗺️ Diagramas

`docs/DIAGRAMAS.md` — diagrama de flujo (nodo por nodo), diagrama de proceso (ciclo de vida del
lead) y diagrama de infraestructura, en Mermaid (se ven directo en GitHub). Versión interactiva del
sistema completo (con pestañas Basic/Standard/Premium):
[Anatomía del Pipeline](https://claude.ai/code/artifact/7fbda57d-0aee-4dc9-82d1-dc943924b19c).

## Stack

- **Orquestador principal:** n8n (self-hosted en Railway/Render, o n8n cloud)
- **Alternativa mencionada en el gig:** Make (Integromat) — mismo concepto, sin código aparte
- **Apoyo (nodos custom/webhooks):** Node.js/TypeScript
- **Base de datos ligera:** Google Sheets (Basic/Standard) o PostgreSQL/Airtable (Premium)
- **Notificaciones:** WhatsApp Business API, email (SMTP/Resend), Slack

## Estructura del repositorio (esta rama)

```
.
├── flows/
│   ├── basic/            # ✅ nivel Basic — 2 flujos de ejemplo
│   ├── standard/         # ✅ nivel Standard — 3 flujos encadenados
│   └── premium/          # 🚧 pendiente (ver rama nivel-premium)
├── custom-nodes/         # 🚧 pendiente — nodos/integraciones custom (Premium)
├── templates/
│   ├── docs-basico.md    # plantilla de documentación para el cliente
│   └── test-cases.md     # plantilla de casos de prueba (Standard+)
├── db/                    # 🚧 pendiente — esquemas de base de datos (Premium)
├── docs/
│   └── DIAGRAMAS.md      # diagramas de flujo, proceso e infraestructura (Mermaid)
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

Ver `flows/basic/README.md` para el detalle y `templates/docs-basico.md` para la documentación de
entrega (1 página).

## Nivel Standard — $150 (entrega 5 días)

**Alcance:** 3 flujos conectados entre sí, pruebas documentadas, integración con CRM/WhatsApp,
capacitación breve al cliente.

- **`flows/standard/1-captura-lead-crm.json`** — Webhook → valida → crea el lead en el CRM del
  cliente → dispara el Flujo 2.
- **`flows/standard/2-notificacion-whatsapp.json`** — Lo dispara el Flujo 1. Notifica al operador
  por WhatsApp Business Cloud API y confirma al lead.
- **`flows/standard/3-manejo-errores-centralizado.json`** — Punto único de errores: si 1 o 2 fallan
  (tras sus reintentos), les reporta aquí; notifica por Slack y respalda por WhatsApp si Slack falla.

Los 3 se conectan entre sí por **webhooks internos** (no por ID de sub-workflow), así que no hace
falta re-enlazar nada después de importar cada JSON — ver `flows/standard/README.md` para el detalle,
`flows/standard/casos-de-prueba.md` para las pruebas ya documentadas, y
`flows/standard/guia-capacitacion.md` para la sesión con el cliente.

## Probar localmente con Docker

Hay un `Dockerfile` (imagen oficial de n8n) y un `docker-compose.yml` para levantar una instancia
local. **Importante:** levantar el contenedor tal cual no importa los flujos automáticamente — la
instancia arranca vacía. Ver `INSTRUCCIONES_LOCAL.md` para el paso a paso completo (incluye qué
verás exactamente en cada paso, cómo importar y probar los flujos de `flows/basic/` y
`flows/standard/`).

## Nivel Premium

Pendiente en esta rama — ver la rama `nivel-premium`, que incluye todo lo de aquí más el nivel
Premium completo (arquitectura modular, base de datos, integraciones custom, soporte 30 días).

## Cómo empezar

1. Levanta n8n (self-hosted, n8n cloud, o el Docker local de este repo) y copia `.env.example` a
   `.env` con tus credenciales/variables reales.
2. **Basic:** importa `flows/basic/` (ver `flows/basic/README.md`).
3. **Standard:** importa además `flows/standard/` (ver `flows/standard/README.md`), configura
   credenciales de CRM y WhatsApp, y ejecuta `flows/standard/casos-de-prueba.md` antes de entregar.
4. Adapta los campos/hoja/CRM al caso real del cliente.
5. Entrega con `templates/docs-basico.md` (Basic) y, si aplica, `flows/standard/guia-capacitacion.md`
   (Standard).

## Variables de entorno

Ver `.env.example` para la lista completa (`N8N_HOST`, `N8N_INTERNAL_URL`, `WHATSAPP_TOKEN`,
`WHATSAPP_PHONE_ID`, `WHATSAPP_OPERATOR_NUMBER`, `GOOGLE_SHEETS_CREDENTIALS`, `CRM_API_URL`,
`CRM_API_KEY`, `SLACK_WEBHOOK_URL`, `DATABASE_URL`, etc.). Nunca subir el archivo `.env` real al
repositorio.
