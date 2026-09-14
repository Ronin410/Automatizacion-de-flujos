# Casos de Prueba — [Nombre del Cliente / Proyecto]

> Plantilla principal para niveles **Standard** y **Premium** (pruebas documentadas antes de entregar).
> En nivel **Basic** es opcional, pero se recomienda al menos probar el caso feliz y un caso de error antes de entregar.

| # | Caso | Input | Output esperado | Resultado real | Estado |
|---|------|-------|------------------|-----------------|--------|
| 1 | Envío válido | `{"nombre":"Ana","email":"ana@test.com","mensaje":"Hola"}` | Nueva fila en Sheets + respuesta `200 ok:true` | | ⬜ |
| 2 | Email inválido | `{"nombre":"Ana","email":"no-es-email"}` | No se escribe en Sheets, respuesta `400` | | ⬜ |
| 3 | Falla temporal del servicio destino (ej. Sheets caído) | Envío válido con credencial inválida a propósito | Reintenta 3 veces, luego envía alerta por email al operador, respuesta `500` | | ⬜ |
| 4 | Campos vacíos | `{}` | Respuesta `400`, sin escritura | | ⬜ |

## Cómo usar esta plantilla

1. Completa la columna **Resultado real** ejecutando el flujo manualmente en n8n (`Execute Workflow` o enviando un request de prueba al webhook con `curl`/Postman).
2. Marca **Estado**: ✅ pasa / ❌ falla / ⬜ pendiente.
3. Adjunta este documento (o su versión completada) en la entrega al cliente.
4. Agrega filas según los flujos específicos del proyecto (ej. integración con CRM, WhatsApp, etc.).
