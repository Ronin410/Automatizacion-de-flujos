# Dockerfile de desarrollo/pruebas locales.
# Usa la imagen oficial de n8n (no reinventamos el orquestador) y solo agrega
# los flujos de este repo dentro de la imagen para poder importarlos fácilmente
# desde el propio contenedor con la CLI de n8n.
#
# Esto NO es una imagen de producción: no trae credenciales, no activa flujos
# automáticamente y usa autenticación básica desactivada por defecto (nivel dev).

FROM docker.n8n.io/n8nio/n8n:latest

# Configuración por defecto para uso local. Puede sobreescribirse con --env-file .env
# (ver .env.example) o las variables del docker-compose.yml.
ENV N8N_PORT=5678 \
    N8N_PROTOCOL=http \
    N8N_HOST=localhost \
    WEBHOOK_URL=http://localhost:5678/ \
    GENERIC_TIMEZONE=UTC

USER root
# Copiamos los flujos de ejemplo dentro de la imagen para poder importarlos
# desde dentro del contenedor con `n8n import:workflow` sin depender de un
# volumen montado (ver INSTRUCCIONES_LOCAL.md).
COPY flows /flows
RUN chown -R node:node /flows
USER node

EXPOSE 5678

# La imagen base ya define ENTRYPOINT/CMD para arrancar n8n; no los sobreescribimos.
