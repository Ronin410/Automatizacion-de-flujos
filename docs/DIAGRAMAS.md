# Diagramas — Sistema completo (Basic + Standard + Premium)

> Rama `nivel-premium`: cubre las 11 piezas del repo (2 flujos Basic + 3 Standard + 6 Premium).
> Versión interactiva (con pestañas por nivel y navegación): **[Anatomía del Pipeline](https://claude.ai/code/artifact/7fbda57d-0aee-4dc9-82d1-dc943924b19c)**.
>
> Cómo leer los diagramas: `( )` disparador (webhook/cron) · `[ ]` paso de proceso · `{ }` decisión ·
> ⛁ base de datos · flecha continua = flujo normal · flecha punteada = manejo de error.

## 1. Diagrama de flujo (nivel técnico)

La lógica nodo por nodo de cada workflow de n8n.

### Nivel Basic — `flows/basic/`

```mermaid
flowchart TD
  subgraph F1["flows/basic/formulario-a-sheets.json"]
    B1(["POST /webhook/lead-form"]) --> B2["Normalizar datos"]
    B2 --> B3{"nombre + email válidos?"}
    B3 -->|no| B4(["400"])
    B3 -->|sí| B5["Guardar fila · Google Sheets"]
    B5 -->|ok| B6(["200"])
    B5 -.->|falla x3 reintentos| B7["Email de alerta al operador"]
    B7 -.-> B8(["500"])
  end
  subgraph F2["flows/basic/recordatorio-cita.json"]
    C1(["Cron · cada 3h"]) --> C2["Leer hoja Citas"]
    C2 --> C3{"cita en 24h y no recordada?"}
    C3 -->|sí| C4["Enviar email de recordatorio"]
    C4 --> C5["Marcar fila Recordado"]
    C4 -.->|falla| C6["Email de alerta al operador"]
  end
```

### Nivel Standard — `flows/standard/`

```mermaid
flowchart TD
  subgraph S1["1-captura-lead-crm.json"]
    D1(["POST /webhook/lead-standard"]) --> D2["Normalizar + validar"]
    D2 -->|inválido| D3(["400"])
    D2 -->|válido| D4["Crear lead · CRM_API_URL"]
    D4 -->|éxito| D5["POST interno → Flujo 2"]
    D5 --> D6(["200"])
    D4 -.->|falla x3| D7["POST interno → Flujo 3"]
  end
  subgraph S2["2-notificacion-whatsapp.json"]
    E1(["POST /webhook/whatsapp-notify-standard"]) --> E2["WhatsApp al operador"]
    E2 --> E3["WhatsApp de confirmación al lead"]
    E2 -.->|falla x3| E4["POST interno → Flujo 3"]
  end
  subgraph S3["3-manejo-errores-centralizado.json"]
    G1(["POST /webhook/error-alert-standard"]) --> G2["Formatear alerta"]
    G2 --> G3["Notificar · Slack"]
    G3 -.->|falla Slack| G4["Respaldo · WhatsApp"]
  end
  D5 --> E1
  D7 -.-> G1
  E4 -.-> G1
```

### Nivel Premium — `flows/premium/`

```mermaid
flowchart TD
  subgraph P1["1-captura-datos.json"]
    H1(["POST /webhook/captura-premium"]) --> H2["Valida + upsert ⛁ leads"]
    H2 --> H3["POST interno → Flujo 2"]
    H2 -.->|falla| H4["POST interno → Flujo 6"]
  end
  subgraph P2["2-procesamiento.json"]
    I1(["POST /webhook/procesamiento-premium"]) --> I2["Score + estado ⛁ leads"]
    I2 --> I3["POST interno → Flujo 3"]
    I2 -.->|falla| I4["POST interno → Flujo 6"]
  end
  subgraph P3["3-notificacion-accion.json"]
    J1(["POST /webhook/notificacion-accion-premium"]) --> J2["WhatsApp operador"]
    J2 --> J3["Email al cliente"]
    J3 --> J4["Sync CRM"]
    J2 -.->|falla| J5["POST interno → Flujo 6"]
  end
  subgraph P4["4-seguimiento-programado.json"]
    K1(["Cron · diario 9am"]) --> K2["Buscar leads sin contacto 3+ días"]
    K2 --> K3["WhatsApp de seguimiento"]
    K3 --> K4["Actualizar ⛁ leads / seguimiento"]
    K2 -.->|falla| K5["POST interno → Flujo 6"]
  end
  subgraph P5["5-integracion-custom-api.json"]
    L1(["POST /webhook/enriquecer-lead-premium"]) --> L2["HTTP Request · API externa"]
    L2 --> L3["Guardar ⛁ leads / seguimiento"]
    L2 -.->|falla| L4["POST interno → Flujo 6"]
  end
  subgraph P6["6-manejo-errores-centralizado.json"]
    M1(["POST /webhook/error-alert-premium"]) --> M2["Registrar ⛁ error_log"]
    M2 --> M3["Notificar Slack"]
    M3 -.->|falla Slack| M4["Respaldo WhatsApp"]
  end
  H3 --> I1
  I3 --> J1
  H4 -.-> M1
  I4 -.-> M1
  J5 -.-> M1
  K5 -.-> M1
  L4 -.-> M1
```

## 2. Diagrama de proceso (nivel de negocio)

El ciclo de vida de un lead en Premium, sin nodos de n8n de por medio — qué flujo implementa cada
etapa, y cómo el manejo de errores cruza todas las etapas en vez de vivir dentro de una sola.

```mermaid
flowchart LR
  P0(["Lead entra<br/>formulario / API"]) --> P1["Captura<br/>1-captura-datos.json"]
  P1 --> P2["Registro<br/>PostgreSQL · leads"]
  P2 --> P3["Procesamiento<br/>2-procesamiento.json<br/>scoring + dedup"]
  P3 --> P4["Notificación<br/>3-notificacion-accion.json<br/>WhatsApp + email + CRM"]
  P4 --> P5["Seguimiento<br/>4-seguimiento-programado.json<br/>cron diario"]
  ERR["Manejo de errores<br/>6-manejo-errores-centralizado.json<br/>Slack + WhatsApp + PostgreSQL"]
  P1 -.->|falla| ERR
  P2 -.->|falla| ERR
  P3 -.->|falla| ERR
  P4 -.->|falla| ERR
  P5 -.->|falla| ERR
```

> El Flujo 5 (`5-integracion-custom-api.json`, enriquecimiento vía API externa) no vive en esta
> cadena principal — se dispara aparte, normalmente llamado desde el paso de Procesamiento cuando
> el cliente lo necesita. Ver `flows/premium/README.md`.

En Basic y Standard el mismo proceso existe pero más corto — sin **Procesamiento** (scoring) ni
**Seguimiento a leads fríos** (Premium-only). Basic guarda en Sheets en vez de PostgreSQL y solo
notifica por email; Standard guarda en el CRM y notifica por WhatsApp.

| Etapa | Basic | Standard | Premium |
|---|---|---|---|
| Captura | Webhook + validación | igual | igual |
| Registro | Google Sheets | CRM del cliente | PostgreSQL |
| Procesamiento | — | — | Scoring + deduplicación |
| Notificación | Email (solo si falla) | WhatsApp + confirmación al lead | + sync automático con CRM |
| Seguimiento | Recordatorio de cita (flujo aparte) | — | Leads fríos cada 3 días (cron) |
| Manejo de errores | Reintento local + email | Flujo centralizado (Slack + WhatsApp) | + registro en `error_log` (Postgres) |

## 3. Diagrama de infraestructura (nivel de despliegue)

```mermaid
flowchart TD
  CLI(["Formulario / app del cliente"])
  subgraph LOCAL["Docker Compose · pruebas locales"]
    N8N["n8n<br/>:5678"]
    PG[("PostgreSQL 16<br/>:5432<br/>leads · seguimiento · error_log")]
    N8N -- "SQL" --> PG
  end
  CLI -- "HTTPS webhook" --> N8N
  N8N -- "HTTPS" --> SHEETS["Google Sheets API<br/>(Basic)"]
  N8N -- "SMTP" --> MAIL["SMTP / Resend<br/>(Basic+)"]
  N8N -- "HTTPS" --> WA["WhatsApp Cloud API<br/>(Standard+)"]
  N8N -- "HTTPS" --> CRM["CRM del cliente<br/>(Standard+)"]
  N8N -- "HTTPS" --> SLACK["Slack Incoming Webhook<br/>(Standard+)"]
  N8N -- "HTTPS" --> CUSTOM["API custom del cliente<br/>enriquecimiento · (Premium)"]

  subgraph PROD["Alternativa en producción"]
    CLOUD["n8n Cloud / Railway / Render"]
    PGCLOUD[("Postgres administrado<br/>Railway / Supabase")]
    CLOUD -- "SQL" --> PGCLOUD
  end
```

En local, `docker-compose.yml` levanta n8n + PostgreSQL en la misma red y aplica `db/schema.sql`
automáticamente. En producción, n8n corre en n8n Cloud o un servicio como Railway/Render, y la base
en un Postgres administrado — las integraciones externas (columna derecha) son las mismas en ambos
casos.

### Partes del sistema (infraestructura)

| Componente | Nivel | Variables de entorno |
|---|---|---|
| n8n (orquestador) | Basic+ | `N8N_HOST`, `N8N_API_KEY`, `N8N_INTERNAL_URL` |
| PostgreSQL | Premium | `DATABASE_URL` — ver `db/schema.sql` |
| Google Sheets API | Basic | `GOOGLE_SHEETS_DOCUMENT_ID`, `GOOGLE_SHEETS_CREDENTIALS` |
| SMTP | Basic+ | `ALERTS_FROM_EMAIL`, `ALERTS_TO_EMAIL` |
| WhatsApp Cloud API | Standard+ | `WHATSAPP_TOKEN`, `WHATSAPP_PHONE_ID`, `WHATSAPP_OPERATOR_NUMBER` |
| CRM del cliente | Standard+ | `CRM_API_URL`, `CRM_API_KEY` |
| Slack | Standard+ | `SLACK_WEBHOOK_URL` |
| API custom | Premium | `CUSTOM_API_URL`, `CUSTOM_API_KEY` |

---

Generado a partir del contenido real de `flows/`, `db/schema.sql`, `docker-compose.yml` y
`.env.example` de esta rama — nombres de nodo y rutas de webhook son los del código, no ilustrativos.
