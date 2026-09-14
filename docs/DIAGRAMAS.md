# Diagramas — Basic + Standard

> Rama `nivel-standard`: cubre las 5 piezas del repo (2 flujos Basic + 3 Standard). El nivel Premium
> (PostgreSQL, arquitectura de 6 flujos) no existe en esta rama — ver `nivel-premium` para el sistema
> completo, incluida la versión interactiva con pestañas por nivel:
> **[Anatomía del Pipeline](https://claude.ai/code/artifact/7fbda57d-0aee-4dc9-82d1-dc943924b19c)**.
>
> Cómo leer los diagramas: `( )` disparador (webhook/cron) · `[ ]` paso de proceso · `{ }` decisión ·
> flecha continua = flujo normal · flecha punteada = manejo de error.

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

## 2. Diagrama de proceso (nivel de negocio)

El ciclo de vida de un lead en esta rama, sin nodos de n8n de por medio.

```mermaid
flowchart LR
  P0(["Lead entra<br/>formulario"]) --> P1["Captura<br/>webhook + validación"]
  P1 --> P2["Registro<br/>CRM del cliente"]
  P2 --> P3["Notificación<br/>WhatsApp al operador<br/>+ confirmación al lead"]
  ERR["Manejo de errores centralizado<br/>3-manejo-errores-centralizado.json<br/>Slack + respaldo WhatsApp"]
  P1 -.->|falla| ERR
  P2 -.->|falla| ERR
  P3 -.->|falla| ERR
```

Aparte de esta cadena, `flows/basic/recordatorio-cita.json` corre su propio ciclo independiente
(cron → buscar citas próximas → recordatorio por email → falla → alerta por email) — no está
conectado al Flujo 3 de Standard, tiene su propio manejo de error local.

| Etapa | Basic | Standard |
|---|---|---|
| Captura | Webhook + validación | igual |
| Registro | Google Sheets | CRM del cliente |
| Procesamiento (scoring) | — | — *(solo Premium)* |
| Notificación | Email (solo si falla) | WhatsApp + confirmación al lead |
| Seguimiento | Recordatorio de cita (flujo aparte) | — *(seguimiento a leads fríos es Premium)* |
| Manejo de errores | Reintento local + email | Flujo centralizado (Slack + WhatsApp) |

## 3. Diagrama de infraestructura (nivel de despliegue)

```mermaid
flowchart TD
  CLI(["Formulario / app del cliente"])
  subgraph LOCAL["Docker Compose · pruebas locales"]
    N8N["n8n<br/>:5678"]
  end
  CLI -- "HTTPS webhook" --> N8N
  N8N -- "HTTPS" --> SHEETS["Google Sheets API<br/>(Basic)"]
  N8N -- "SMTP" --> MAIL["SMTP / Resend<br/>(Basic+)"]
  N8N -- "HTTPS" --> WA["WhatsApp Cloud API<br/>(Standard)"]
  N8N -- "HTTPS" --> CRM["CRM del cliente<br/>(Standard)"]
  N8N -- "HTTPS" --> SLACK["Slack Incoming Webhook<br/>(Standard)"]

  subgraph PROD["Alternativa en producción"]
    CLOUD["n8n Cloud / Railway / Render"]
  end
```

Sin base de datos propia en este nivel: Basic escribe en Google Sheets y Standard en el CRM del
cliente. PostgreSQL entra recién en Premium (ver `nivel-premium`).

### Partes del sistema (infraestructura)

| Componente | Nivel | Variables de entorno |
|---|---|---|
| n8n (orquestador) | Basic+ | `N8N_HOST`, `N8N_API_KEY`, `N8N_INTERNAL_URL` |
| Google Sheets API | Basic | `GOOGLE_SHEETS_DOCUMENT_ID`, `GOOGLE_SHEETS_CREDENTIALS` |
| SMTP | Basic+ | `ALERTS_FROM_EMAIL`, `ALERTS_TO_EMAIL` |
| WhatsApp Cloud API | Standard | `WHATSAPP_TOKEN`, `WHATSAPP_PHONE_ID`, `WHATSAPP_OPERATOR_NUMBER` |
| CRM del cliente | Standard | `CRM_API_URL`, `CRM_API_KEY` |
| Slack | Standard | `SLACK_WEBHOOK_URL` |

---

Generado a partir del contenido real de `flows/`, `docker-compose.yml` y `.env.example` de esta
rama — nombres de nodo y rutas de webhook son los del código, no ilustrativos.
