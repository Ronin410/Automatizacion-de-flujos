# Casos de Prueba — Nivel Standard

> Basado en `templates/test-cases.md`. Completar la columna **Resultado real** y **Estado** antes
> de entregar al cliente (requisito del alcance Standard).

## Flujo 1 → 2 → 3 (Captura de Lead → CRM → WhatsApp → Errores)

| # | Caso | Input | Output esperado | Resultado real | Estado |
|---|------|-------|------------------|-----------------|--------|
| 1 | Lead válido, flujo feliz completo | `POST /webhook/lead-standard` con nombre, email y teléfono válidos | Lead creado en CRM, WhatsApp enviado al operador y confirmación al lead, respuesta `200` | | ⬜ |
| 2 | Email inválido | `{"nombre":"Ana","email":"no-es-email"}` | No llega al CRM, respuesta `400` | | ⬜ |
| 3 | Campos vacíos | `{}` | Respuesta `400`, sin llamadas a CRM ni WhatsApp | | ⬜ |
| 4 | CRM caído / credencial inválida | Lead válido, credencial de CRM incorrecta a propósito | Reintenta 3 veces, luego el Flujo 1 llama al Flujo 3, llega alerta a Slack (o WhatsApp de respaldo si Slack falla), respuesta `500` | | ⬜ |
| 5 | WhatsApp Cloud API caído/token inválido | Lead válido, CRM ok, token de WhatsApp incorrecto | Lead sí se crea en el CRM; el Flujo 2 reintenta 3 veces y reporta el fallo al Flujo 3 | | ⬜ |
| 6 | Slack Webhook inválido (probar el respaldo del Flujo 3) | Forzar un error (caso 4) con `SLACK_WEBHOOK_URL` inválida | Falla la notificación a Slack pero sí llega la notificación de respaldo por WhatsApp | | ⬜ |
| 7 | Lead sin teléfono | Input sin campo `telefono` | Se crea en CRM y se notifica al operador; el mensaje de confirmación al lead falla o se omite sin tumbar el flujo | | ⬜ |

## Cómo ejecutar las pruebas

```bash
# Caso 1 — flujo feliz
curl -X POST http://localhost:5678/webhook/lead-standard \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Ana Test","email":"ana@test.com","telefono":"+521234567890","empresa":"ACME","mensaje":"Quiero cotizar"}'

# Caso 2 — email inválido
curl -X POST http://localhost:5678/webhook/lead-standard \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Ana Test","email":"no-es-email"}'
```

Para los casos de fallo forzado (4, 5, 6), cambia temporalmente la credencial/URL correspondiente
por un valor inválido, ejecuta el caso, y revisa la pestaña **Executions** de cada flujo involucrado
para confirmar el comportamiento esperado. No olvides restaurar la credencial correcta después.
