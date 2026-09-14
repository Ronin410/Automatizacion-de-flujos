# Diagramas — Nivel Basic

> Esta rama solo trae el nivel Basic (2 flujos). Standard y Premium viven en las ramas
> `nivel-standard` y `nivel-premium` — cada una tiene su propio `docs/DIAGRAMAS.md` con el alcance
> correspondiente. Versión interactiva del sistema completo (con pestañas por nivel):
> **[Anatomía del Pipeline](https://claude.ai/code/artifact/7fbda57d-0aee-4dc9-82d1-dc943924b19c)**.
>
> Cómo leer los diagramas: `( )` disparador (webhook/cron) · `[ ]` paso de proceso · `{ }` decisión ·
> flecha continua = flujo normal · flecha punteada = manejo de error.

## 1. Diagrama de flujo (nivel técnico)

La lógica nodo por nodo de los 2 workflows de `flows/basic/`.

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

Los 2 flujos son independientes entre sí — cada uno con su propio disparador y su propio manejo de
error local (reintento + email), sin un canal de errores centralizado (eso llega en Standard).

## 2. Diagrama de proceso (nivel de negocio)

```mermaid
flowchart LR
  A0(["Formulario enviado"]) --> A1["Captura + validación"]
  A1 --> A2["Registro en Google Sheets"]
  A2 -.->|falla x3 reintentos| AERR["Alerta por email al operador"]

  B0(["Cron cada 3h"]) --> B1["Buscar citas en próximas 24h"]
  B1 --> B2["Recordatorio por email"]
  B2 -.->|falla| BERR["Alerta por email al operador"]
```

Dos procesos cortos y paralelos, sin scoring, sin CRM y sin seguimiento automático a leads fríos
— esas piezas aparecen en Standard y Premium respectivamente (ver `nivel-standard` /
`nivel-premium`).

## 3. Diagrama de infraestructura (nivel de despliegue)

```mermaid
flowchart TD
  CLI(["Formulario del cliente"])
  subgraph LOCAL["Docker Compose · pruebas locales"]
    N8N["n8n<br/>:5678"]
  end
  CLI -- "HTTPS webhook" --> N8N
  N8N -- "HTTPS" --> SHEETS["Google Sheets API"]
  N8N -- "SMTP" --> MAIL["SMTP / Resend"]

  subgraph PROD["Alternativa en producción"]
    CLOUD["n8n Cloud / Railway / Render"]
  end
```

Un solo contenedor (n8n) y dos integraciones externas — nada de base de datos propia, CRM,
WhatsApp ni Slack todavía.

### Partes del sistema (infraestructura)

| Componente | Variables de entorno |
|---|---|
| n8n (orquestador) | `N8N_HOST`, `N8N_API_KEY` |
| Google Sheets API | `GOOGLE_SHEETS_DOCUMENT_ID`, `GOOGLE_SHEETS_CREDENTIALS` |
| SMTP | `ALERTS_FROM_EMAIL`, `ALERTS_TO_EMAIL` |

---

Generado a partir del contenido real de `flows/basic/`, `docker-compose.yml` y `.env.example` de
esta rama — nombres de nodo y rutas de webhook son los del código, no ilustrativos.
