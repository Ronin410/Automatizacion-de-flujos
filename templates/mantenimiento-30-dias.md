# Documento de Mantenimiento — 30 días de soporte (Nivel Premium)

> Plantilla para el nivel **Premium**. Completar y entregar junto con el sistema. Cubre los 30 días
> de soporte post-entrega incluidos en este nivel.

## 1. Qué se entrega y qué cubre el soporte

- **Sistema:** `[nombre del proyecto]` — 6 flujos en n8n + base de datos PostgreSQL.
- **Periodo de soporte:** 30 días naturales a partir de `[fecha de entrega]`.
- **Incluido:** corrección de errores del sistema entregado, ajustes menores de configuración
  (credenciales, mensajes, umbrales del scoring), monitoreo del correcto funcionamiento.
- **No incluido (requiere cotización aparte):** flujos nuevos, integraciones adicionales no
  contempladas en el alcance original, cambios grandes de arquitectura.

## 2. Qué monitorear durante los 30 días

| Qué revisar | Cómo | Frecuencia sugerida |
|---|---|---|
| Ejecuciones fallidas | n8n → cada flujo → pestaña **Executions**, filtrar por `Error` | 2-3 veces por semana |
| Alertas del Flujo 6 (errores centralizados) | Canal de Slack / WhatsApp configurado | Inmediato (llegan solas) |
| Tabla `error_log` | `SELECT * FROM error_log ORDER BY creado_en DESC LIMIT 20;` | Semanal |
| Volumen de leads vs. capacidad del plan de n8n/WhatsApp/CRM | Dashboard del proveedor correspondiente | Semanal |
| Uso de disco/conexiones de la base de datos | Panel del proveedor (Railway/Render/Supabase/etc.) | Semanal |
| Créditos/rate limits de APIs externas (WhatsApp Cloud API, CRM, API custom del Flujo 5) | Panel de cada proveedor | Semanal |

## 3. Señales de que hay que escalar recursos

- Ejecuciones que empiezan a tardar notablemente más de lo normal.
- Errores de "rate limit" o "too many connections" recurrentes en `error_log`.
- El volumen de leads/día se acerca o supera lo estimado al diseñar el sistema.

**Acciones sugeridas al escalar:**
- Mover n8n a un plan/instancia con más recursos (o a n8n Cloud si estaba self-hosted).
- Agregar índices adicionales en PostgreSQL según los patrones de consulta reales (revisar
  `EXPLAIN ANALYZE` de las queries más lentas).
- Particionar o archivar históricos de `leads`/`seguimiento`/`error_log` más allá de cierta
  antigüedad (ej. 12 meses) si la tabla crece mucho.
- Revisar si conviene mover el Flujo 4 (seguimiento) a lotes más pequeños (`LIMIT`) si el volumen
  de leads sin contacto crece mucho.

## 4. Checklist semanal (marcar durante las 4 semanas de soporte)

- [ ] Semana 1 — revisado, sin incidentes / incidentes resueltos: `[detalle]`
- [ ] Semana 2 — revisado, sin incidentes / incidentes resueltos: `[detalle]`
- [ ] Semana 3 — revisado, sin incidentes / incidentes resueltos: `[detalle]`
- [ ] Semana 4 — revisado, cierre del periodo de soporte

## 5. Contacto y cierre del soporte

- **Contacto durante el soporte:** `[email / Fiverr / WhatsApp]`
- **Al finalizar los 30 días:** se envía un resumen de lo monitoreado y las recomendaciones
  pendientes (si las hay), y se ofrece un plan de mantenimiento continuo opcional si el cliente lo
  desea (fuera de este alcance).
