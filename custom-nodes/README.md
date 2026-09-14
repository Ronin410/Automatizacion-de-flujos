# Custom Nodes / Integraciones (Nivel Premium)

El alcance Premium pide una "capa de integración custom" para APIs que n8n no soporta
nativamente. En la gran mayoría de los casos **eso no requiere programar un nodo custom en
Node.js/TypeScript** — basta con un nodo **HTTP Request** bien configurado (headers, auth, query
params, timeout, reintentos). Ese es el patrón que se entrega en
`flows/premium/5-integracion-custom-api.json`.

Reserva un nodo custom real en esta carpeta solo cuando el HTTP Request no alcance, por ejemplo:

- Auth con firma/HMAC compleja que cambia por request (ej. AWS SigV4, ciertos webhooks bancarios).
- Un protocolo que no es REST/HTTP simple (streaming largo, XML-RPC con estado, SOAP con WSDL
  pesado que conviene resolver con una librería).
- Paginación/transformación tan específica que conviene encapsularla como un nodo reutilizable en
  varios flujos del mismo cliente.

## Cómo agregar un nodo custom cuando sí se justifique

1. Crear un subproyecto Node.js/TypeScript siguiendo la
   [guía oficial de nodos custom de n8n](https://docs.n8n.io/integrations/creating-nodes/).
2. Documentar aquí, por proyecto, qué integración cubre el nodo y por qué no bastó un HTTP Request.
3. Publicarlo como paquete npm privado o instalarlo localmente en la instancia de n8n del cliente
   (`~/.n8n/custom` o `N8N_CUSTOM_EXTENSIONS`).

Por ahora esta carpeta no tiene nodos custom propios — el patrón HTTP Request configurado cubre los
casos típicos de los pedidos de Fiverr.
