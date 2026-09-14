# Documentación del Flujo — [Nombre del Cliente]

> Plantilla de entrega para el nivel **Basic**. Copiar y completar los campos entre `[ ]` para cada proyecto.

## 1. ¿Qué hace este flujo?

[Ej: Cuando alguien envía el formulario de contacto del sitio web, sus datos se guardan automáticamente en una hoja de Google Sheets y quedan listos para dar seguimiento.]

- **Dispara cuando:** [ej. se envía el formulario / llega un webhook]
- **Apps conectadas:** [ej. Formulario del sitio ↔ Google Sheets]
- **Resultado esperado:** [ej. una nueva fila en la hoja "Leads" con nombre, email, mensaje y fecha]

## 2. Cómo revisar que el flujo corrió bien

1. Entra a n8n: `[URL_N8N]`
2. Ve a **Workflows → [Nombre del flujo]**
3. Abre la pestaña **Executions**:
   - ✅ **Success** (verde): el flujo corrió correctamente.
   - ❌ **Error** (rojo): algo falló — revisa el paso 3.
4. Para confirmar el resultado final, revisa directamente en [Google Sheets / bandeja de email]: `[enlace o ubicación]`.

## 3. Qué pasa si algo falla

- El flujo reintenta automáticamente hasta 3 veces antes de darse por vencido.
- Si después de los reintentos sigue fallando, se envía un correo de alerta a `[email del operador]` con los datos que no se pudieron guardar, para que se puedan agregar manualmente.
- Causas comunes de fallo: credenciales vencidas, cambios en la estructura de la hoja de cálculo, o el servicio externo caído temporalmente.

## 4. Datos de contacto / soporte

- **Desarrollado por:** [Tu nombre / marca del gig]
- **Fecha de entrega:** [fecha]
- **Soporte incluido:** [ej. 7 días de ajustes menores post-entrega, según lo pactado en el pedido]
- **Contacto:** [email / Fiverr]

## 5. Notas para futuras modificaciones

[Ej: para cambiar la hoja de destino, edita el nodo "Guardar en Sheets" → Document ID. Para agregar un campo nuevo al formulario, agrégalo también en el nodo "Normalizar Datos".]
