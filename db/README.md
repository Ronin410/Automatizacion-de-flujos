# Esquemas de Base de Datos (Nivel Premium)

`schema.sql` — esquema PostgreSQL usado por `flows/premium/`: tablas `leads`, `seguimiento` y
`error_log`, con sus índices y un trigger para mantener `actualizado_en` al día.

## Aplicarlo

```bash
psql "$DATABASE_URL" -f db/schema.sql
```

Es idempotente (`CREATE TABLE IF NOT EXISTS`), así que se puede volver a correr sin duplicar nada.

## Adaptarlo al cliente real

- Si el cliente prefiere **Airtable** en vez de PostgreSQL (opción mencionada en el spec para
  Premium), replica estas 3 tablas como 3 tablas de Airtable con los mismos campos, y cambia los
  nodos `Postgres` de los flujos por nodos `Airtable` (misma lógica, distinto nodo).
- Los campos `estado` (leads) y `tipo` (seguimiento) son texto libre por simplicidad — si el
  cliente tiene un catálogo fijo de estados, puedes migrarlos a un `ENUM` de Postgres.
- Ver `flows/premium/README.md` para cómo cada flujo usa estas tablas.
