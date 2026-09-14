# Proyecto: Automatización de Procesos (n8n/Make) — Gig de Fiverr

## Contexto para Claude Code
Este documento describe la base de un proyecto de automatización de flujos de negocio (leads, notificaciones, sincronización entre apps) que se vende como servicio en Fiverr, en 3 niveles (Basic, Standard, Premium). A diferencia del chatbot, aquí no hay conversación con el usuario final: son procesos que corren en segundo plano cuando ocurre un evento (formulario enviado, pedido creado, fecha próxima, etc.).

**Objetivo de esta sesión con Claude Code:** dejar una base de flujos y utilidades reutilizables en n8n, más scripts de apoyo, para que al llegar un pedido real solo se necesite adaptar el flujo específico del cliente en vez de armar todo desde cero.

---

## Stack sugerido
- **Orquestador principal:** n8n (self-hosted en Railway/Render, o n8n cloud)
- **Alternativa/mención en el gig:** Make (Integromat) — mismo concepto, otra herramienta, no requiere código aparte
- **Lenguaje de apoyo (para nodos custom o webhooks):** Node.js/TypeScript
- **Base de datos ligera (cuando se necesite):** Google Sheets (Basic/Standard) o PostgreSQL/Airtable (Premium)
- **Notificaciones:** WhatsApp Business API, email (SMTP o servicio como Resend), Slack

---

## Nivel Basic — $60 (entrega 3 días)
**Alcance:**
- 1 flujo automatizado simple (ej. formulario → email o Google Sheets).
- Documentación básica de uso (cómo revisar que el flujo corrió bien).
- 2 apps conectadas.

**Tareas para Claude Code / n8n:**
- [ ] Flujo base: Webhook o trigger de formulario → transformación simple de datos → escritura en Sheets/email.
- [ ] Manejo básico de errores (si falla el envío, reintento o notificación de fallo).
- [ ] Plantilla de documentación (1 página) explicando qué hace el flujo y cómo revisarlo.

---

## Nivel Standard — $150 (entrega 5 días)
**Alcance:**
- 3 flujos conectados entre sí (ej. formulario → CRM → notificación WhatsApp).
- Pruebas incluidas (casos de prueba documentados y ejecutados antes de entregar).
- Integración con al menos una app adicional tipo CRM/WhatsApp/redes sociales.
- Capacitación breve incluida para el cliente.

**Tareas para Claude Code / n8n:**
- [ ] Encadenar 3 flujos con dependencias claras (ej. flujo A dispara flujo B).
- [ ] Nodo de manejo de errores centralizado (notificación a Slack/WhatsApp del operador si algo falla).
- [ ] Documento de pruebas: lista de casos (input esperado → output esperado) y resultado real.
- [ ] Mini-guía de "cómo usar y modificar este flujo" para la sesión de capacitación.

---

## Nivel Premium — $300 (entrega 10 días)
**Alcance:**
- Sistema completo de automatización (leads, seguimiento, notificaciones) — 6+ flujos o apps conectadas.
- Integración con base de datos/CRM real.
- Integraciones API custom si el cliente lo requiere.
- 30 días de soporte post-entrega.

**Tareas para Claude Code / n8n:**
- [ ] Arquitectura de flujos modular: separar "captura de datos", "procesamiento", "notificación/acción" en flujos independientes pero conectados.
- [ ] Conexión a base de datos real (PostgreSQL/Airtable) con esquema de leads/seguimiento.
- [ ] Capa de integración custom (nodo HTTP Request configurado) para APIs que n8n no soporta nativamente.
- [ ] Documento de mantenimiento para los 30 días de soporte (qué monitorear, cómo escalar si crece el volumen).

---

## Estructura de carpetas sugerida
```
automatizacion-n8n/
├── flows/
│   ├── basic/            # export JSON de flujos nivel basic
│   ├── standard/         # export JSON de flujos nivel standard
│   └── premium/          # export JSON de flujos nivel premium
├── custom-nodes/         # código de nodos/integraciones custom (Premium)
├── templates/
│   ├── docs-basico.md    # plantilla de documentación para el cliente
│   └── test-cases.md     # plantilla de casos de prueba (Standard+)
├── db/                    # esquemas de base de datos (Premium)
├── .env.example
└── README.md
```

## Variables de entorno esperadas
```
N8N_HOST=
N8N_API_KEY=
WHATSAPP_TOKEN=
GOOGLE_SHEETS_CREDENTIALS=
DATABASE_URL=
CRM_API_KEY=
```

## Nota para Claude Code
Priorizar dejar 2-3 flujos de ejemplo genéricos y bien documentados (formulario→Sheets, WhatsApp→notificación, recordatorio de cita) que sirvan como punto de partida para adaptar rápido al caso real de cada cliente, en vez de intentar cubrir todos los escenarios posibles de antemano.
