# Flujos — Nivel Premium

Rama `nivel-premium`: incluye **todo Basic + Standard** (`flows/basic/`, `flows/standard/`) **más**
esta arquitectura modular de 6 flujos, para un pedido de nivel **Premium** ($300, entrega 10 días).

## Arquitectura modular

Separada en 3 capas (captura / procesamiento / notificación-acción), más seguimiento programado,
integración custom y manejo de errores — 6 flujos conectados por webhooks internos, igual que en
Standard:

```
Cliente/Formulario
      │ POST /webhook/captura-premium
      ▼
┌───────────────────────────┐
│ 1 - Captura de Datos       │──► INSERT/UPSERT en PostgreSQL (leads)
└──────────────┬─────────────┘
               │ POST interno /webhook/procesamiento-premium
               ▼
┌───────────────────────────┐
│ 2 - Procesamiento           │──► score + estado en PostgreSQL
│   (scoring / deduplicación) │
└──────────────┬─────────────┘
               │ POST interno /webhook/notificacion-accion-premium
               ▼
┌───────────────────────────┐
│ 3 - Notificación y Acción   │──► WhatsApp operador + Email cliente + CRM
└───────────────────────────┘

┌───────────────────────────┐        ┌───────────────────────────┐
│ 4 - Seguimiento Programado  │        │ 5 - Integración Custom API │
│   (cron diario)             │        │   (enriquecimiento, HTTP)  │
└──────────────┬─────────────┘        └──────────────┬─────────────┘
               │                                      │
               └──────────────┬───────────────────────┘
                               │ POST /webhook/error-alert-premium (cualquier flujo, si falla)
                               ▼
                  ┌───────────────────────────┐
                  │ 6 - Manejo de Errores       │──► Postgres (error_log) + Slack + WhatsApp
                  │     Centralizado             │
                  └───────────────────────────┘
```

1. **`1-captura-datos.json`** — Webhook público → valida → upsert en `leads` (PostgreSQL) → dispara
   el Flujo 2.
2. **`2-procesamiento.json`** — Lo dispara el Flujo 1. Calcula un score simple (ajustar la regla al
   negocio real) y actualiza el lead → dispara el Flujo 3.
3. **`3-notificacion-accion.json`** — Lo dispara el Flujo 2. WhatsApp al operador + email de
   confirmación al cliente + sincronización con el CRM.
4. **`4-seguimiento-programado.json`** — Cron diario. Busca leads sin contacto en 3+ días y les
   manda seguimiento por WhatsApp, dejando registro en `seguimiento`.
5. **`5-integracion-custom-api.json`** — Ejemplo de "capa de integración custom" (nodo HTTP Request
   bien configurado: headers, auth, timeout, reintentos) para conectar cualquier API que n8n no
   soporte nativamente — p. ej. enriquecimiento de datos del lead.
6. **`6-manejo-errores-centralizado.json`** — Punto único de errores para los 5 flujos anteriores.
   Registra el error en `error_log` (PostgreSQL) y notifica por Slack, con respaldo por WhatsApp.

Como en Standard, la conexión entre flujos es por **webhook interno** (no por ID de sub-workflow):
se importa cada JSON por separado y no hace falta re-enlazar nada más que credenciales/variables.

## Base de datos

Aplica `db/schema.sql` contra la base indicada en `DATABASE_URL` antes de usar estos flujos —
crea las tablas `leads`, `seguimiento` y `error_log` con sus índices.

```bash
psql "$DATABASE_URL" -f db/schema.sql
```

## Cómo importar en n8n

1. Aplica `db/schema.sql`.
2. Importa los 6 archivos de `flows/premium/` (**Workflows → Import from File**).
3. Configura credenciales: PostgreSQL, CRM, WhatsApp Cloud API, SMTP.
4. Define las variables de entorno nuevas de Premium (ver `.env.example`): `DATABASE_URL`,
   `CUSTOM_API_URL`, `CUSTOM_API_KEY` (además de las que ya usa Standard).
5. Activa los 6 flujos.
6. Prueba con el flujo feliz y revisa las tablas `leads`/`seguimiento`/`error_log` en la base.

## Cómo adaptar al cliente real

- **Scoring (Flujo 2):** la regla actual es un ejemplo simple — reemplázala por el criterio real
  de calificación de leads del cliente.
- **Integración custom (Flujo 5):** cambia `CUSTOM_API_URL`/`CUSTOM_API_KEY` y el cuerpo del
  request por la API específica del cliente. Si esa API requiere una firma/auth muy fuera de lo
  estándar que el nodo HTTP Request no cubre, ahí sí se justifica un nodo custom en
  `custom-nodes/` (ver su README).
- **Seguimiento (Flujo 4):** ajusta el intervalo (`daysInterval`) y el mensaje según la cadencia de
  seguimiento acordada con el cliente.

## Documentación de entrega

- `flows/standard/casos-de-prueba.md` y `flows/standard/guia-capacitacion.md` siguen aplicando (el
  alcance Premium hereda las pruebas y capacitación de Standard, ampliadas a los nuevos flujos).
- `templates/mantenimiento-30-dias.md` — plantilla del documento de mantenimiento para los 30 días
  de soporte post-entrega incluidos en este nivel.
