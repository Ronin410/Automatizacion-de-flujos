# Cómo levantar esto localmente para pruebas

Este documento explica cómo correr el `Dockerfile` en tu máquina para probar los flujos de esta
rama (**Basic + Standard + Premium**), y **qué vas a ver exactamente** si lo levantas tal como está
el repo hoy (sin tocar nada más).

## Requisitos

- Docker y Docker Compose instalados. `docker-compose.yml` ya incluye un contenedor de PostgreSQL
  (necesario para el nivel Premium) — no necesitas instalar Postgres aparte.
- (Opcional, para que los flujos hagan algo real) una hoja de Google Sheets propia y credenciales
  SMTP/CRM/WhatsApp de prueba.

## 1. Preparar variables de entorno

```bash
cp .env.example .env
```

Puedes dejar `.env` vacío/con placeholders si solo quieres explorar la interfaz de n8n. Para que
los flujos Basic realmente escriban en Sheets o manden correos necesitas completar al menos
`GOOGLE_SHEETS_DOCUMENT_ID`, `ALERTS_FROM_EMAIL` y `ALERTS_TO_EMAIL`. Para los flujos Standard,
además `CRM_API_URL`, `CRM_API_KEY`, `WHATSAPP_TOKEN`, `WHATSAPP_PHONE_ID`,
`WHATSAPP_OPERATOR_NUMBER`, `SLACK_WEBHOOK_URL` y `N8N_INTERNAL_URL`. Para los flujos Premium,
además `CUSTOM_API_URL`/`CUSTOM_API_KEY` (ver README raíz). `DATABASE_URL` puedes dejarla vacía: si
usas `docker-compose.yml` tal cual, ya apunta por defecto al Postgres local incluido.

## 2. Levantar el contenedor

```bash
docker compose up --build -d
```

Equivalente sin compose:

```bash
docker build -t automatizacion-n8n .
docker run -it --rm -p 5678:5678 --env-file .env automatizacion-n8n
```

## 3. Abrir n8n

Ve a **http://localhost:5678**.

## ⚠️ Qué vas a ver si lo levantas tal como está el repo ahora mismo

Importante para no llevarte una sorpresa: **el repo no incluye ningún paso de auto-importación de
flujos ni credenciales reales** (a propósito — no queremos secretos en el repo, y n8n no permite
"precargar" credenciales OAuth/SMTP de forma segura vía Docker). Entonces, tal cual:

1. **Primer arranque:** n8n te va a pedir crear una cuenta "owner" local (nombre, email, password).
   Es solo para tu instancia local, no manda nada a internet — puedes poner datos ficticios.
2. **Después de crear la cuenta:** vas a caer en el editor de n8n **completamente vacío** —
   pantalla de "Workflows" sin ningún flujo listado. Los JSON de `flows/basic/`, `flows/standard/`
   y `flows/premium/` **no se importan solos**, aunque ya están copiados dentro de la imagen en
   `/flows` (y también montados en `./flows` si usas `docker-compose.yml`).
3. **La base de datos PostgreSQL sí se crea con las tablas** (`leads`, `seguimiento`, `error_log`)
   porque `docker-compose.yml` aplica `db/schema.sql` automáticamente al arrancar por primera vez —
   pero va a estar **vacía**, sin ningún lead, hasta que actives y uses los flujos de Premium.
4. **No vas a ver** datos en ninguna hoja de Sheets, ningún WhatsApp, correo o lead en el CRM,
   porque no hay ningún flujo activo todavía y no hay credenciales configuradas.

Es decir: levantar el contenedor por sí solo **solo te da una instancia de n8n en blanco lista
para usar** — el "producto" (los flujos) hay que importarlo manualmente, como se explica abajo.

## 4. Importar los flujos de ejemplo

**Opción A — desde la interfaz (más simple):**
En el editor de n8n → **Workflows → Import from File** → selecciona en tu explorador de archivos
del sistema (no dentro del contenedor) cualquiera de los `.json` de `flows/basic/`,
`flows/standard/` o `flows/premium/` de este repo. El navegador sube el archivo directo a n8n.
Repite por cada flujo que quieras probar (cada uno se importa por separado, un archivo a la vez).

**Opción B — desde la línea de comandos, dentro del contenedor:**

```bash
for f in /flows/basic/*.json /flows/standard/*.json /flows/premium/*.json; do
  docker compose exec n8n n8n import:workflow --input="$f"
done
```

Después de importar, refresca la lista de **Workflows** en la UI y ahí sí vas a verlos, pero:

- Aparecen **inactivos** (toggle "Active" apagado) — actívalos todos si vas a probar un nivel
  completo, ya que sus flujos se llaman entre sí por webhook.
- Los nodos de Google Sheets, Email, CRM, WhatsApp y Postgres van a mostrar un ⚠️ de "credenciales
  faltantes" hasta que entres a **Credentials** y configures las tuyas (Google Sheets OAuth2, SMTP,
  CRM por header auth, WhatsApp Cloud API por header auth, y Postgres — con este compose, host
  `postgres`, usuario/clave/DB `n8n`/`n8n`/`automatizacion`).

## 5. Probar el flujo `formulario-a-sheets`

1. Configura la credencial de Google Sheets y activa el flujo.
2. Copia la URL del nodo **Webhook - Recibir Formulario** (botón "Test URL" o "Production URL").
3. Envía un request de prueba:

```bash
curl -X POST http://localhost:5678/webhook/lead-form \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Ana Test","email":"ana@test.com","mensaje":"Hola, quiero info"}'
```

4. Revisa la pestaña **Executions** del flujo (debería verse en verde) y la hoja de Sheets
   configurada (debería tener una fila nueva).
5. Para probar el manejo de errores, pon una credencial de Sheets inválida a propósito y repite el
   request: debería reintentar 3 veces y, si sigue fallando, llegar el correo de alerta a
   `ALERTS_TO_EMAIL`.

## 5b. Probar el nivel Standard (los 3 flujos encadenados)

1. Configura `CRM_API_URL`/`CRM_API_KEY` (puede ser cualquier endpoint de prueba tipo
   `https://webhook.site/...` para ver que llega el POST) y las credenciales de WhatsApp.
2. Asegúrate de que `N8N_INTERNAL_URL=http://localhost:5678` esté seteada (así el Flujo 1 puede
   llamar al Flujo 2, y ambos al Flujo 3).
3. Activa los 3 flujos de `flows/standard/`.
4. Envía un lead de prueba:

```bash
curl -X POST http://localhost:5678/webhook/lead-standard \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Ana Test","email":"ana@test.com","telefono":"+521234567890","empresa":"ACME","mensaje":"Quiero cotizar"}'
```

5. Revisa **Executions** en los 3 flujos: el 1 debería mostrar la llamada al CRM y al Flujo 2; el 2
   debería mostrar el envío de WhatsApp.
6. Para probar el Flujo 3, invalida a propósito la credencial del CRM o de WhatsApp, repite el
   request, y confirma que llega la alerta (Slack o, si `SLACK_WEBHOOK_URL` también es inválida, el
   respaldo por WhatsApp). Ver `flows/standard/casos-de-prueba.md` para el resto de los casos.

## 5c. Probar el nivel Premium (arquitectura de 6 flujos + PostgreSQL)

1. La base ya tiene las tablas creadas (`docker-compose.yml` aplica `db/schema.sql`
   automáticamente). Confírmalo si quieres:

```bash
docker compose exec postgres psql -U n8n -d automatizacion -c "\dt"
```

2. Configura la credencial de Postgres en n8n con host `postgres`, puerto `5432`, DB
   `automatizacion`, usuario/clave `n8n`/`n8n` (o los que hayas puesto en `.env`/`docker-compose.yml`).
3. Activa los 6 flujos de `flows/premium/`.
4. Envía un lead de prueba:

```bash
curl -X POST http://localhost:5678/webhook/captura-premium \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Ana Test","email":"ana@test.com","telefono":"+521234567890","empresa":"ACME","mensaje":"Quiero cotizar, esto es una prueba con mensaje largo"}'
```

5. Revisa el resultado directo en la base:

```bash
docker compose exec postgres psql -U n8n -d automatizacion -c "SELECT id, nombre, email, score, estado FROM leads ORDER BY id DESC LIMIT 5;"
```

6. Para probar el seguimiento programado (Flujo 4) sin esperar un día, ábrelo en el editor de n8n
   y usa **Execute Workflow** (ejecución manual) — va a buscar leads sin contacto en 3+ días; con
   datos recién insertados no encontrará ninguno todavía, lo cual es el comportamiento esperado.
7. Para probar el manejo de errores (Flujo 6), invalida a propósito alguna credencial (Postgres,
   CRM o WhatsApp), repite el request del paso 4, y confirma que:
   - Llega la alerta a Slack (o WhatsApp de respaldo si Slack también falla).
   - Queda un registro nuevo en `error_log`:

```bash
docker compose exec postgres psql -U n8n -d automatizacion -c "SELECT * FROM error_log ORDER BY creado_en DESC LIMIT 5;"
```

## 6. Detener y limpiar

```bash
docker compose down        # detiene los contenedores, conserva los datos (n8n_data, postgres_data)
docker compose down -v     # además borra los volúmenes (vuelves a estado "recién levantado")
```

## Notas

- Esta imagen es solo para **pruebas locales**, no para producción (sin HTTPS, sin autenticación
  básica activada, `N8N_HOST=localhost`).
- Ninguna de las credenciales reales (Google, SMTP, WhatsApp) va en el `Dockerfile` ni en el repo —
  siempre se cargan vía `.env` o se configuran manualmente dentro de n8n.
