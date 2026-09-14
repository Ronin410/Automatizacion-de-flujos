-- Esquema PostgreSQL — Nivel Premium
-- Leads + seguimiento + log de errores. Ejecutar contra la base indicada en DATABASE_URL.

CREATE TABLE IF NOT EXISTS leads (
    id                SERIAL PRIMARY KEY,
    nombre            TEXT NOT NULL,
    email             TEXT NOT NULL,
    telefono          TEXT,
    empresa           TEXT,
    mensaje           TEXT,
    origen            TEXT NOT NULL DEFAULT 'sitio-web',
    score             INTEGER NOT NULL DEFAULT 0,
    estado            TEXT NOT NULL DEFAULT 'nuevo', -- nuevo | contactado | calificado | cerrado | perdido
    interacciones     INTEGER NOT NULL DEFAULT 1,
    ultimo_contacto   TIMESTAMPTZ,
    creado_en         TIMESTAMPTZ NOT NULL DEFAULT now(),
    actualizado_en    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS seguimiento (
    id          SERIAL PRIMARY KEY,
    lead_id     INTEGER NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
    tipo        TEXT NOT NULL, -- whatsapp | email | llamada | crm
    nota        TEXT,
    creado_en   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS error_log (
    id          SERIAL PRIMARY KEY,
    flujo       TEXT NOT NULL,
    nodo        TEXT,
    mensaje     TEXT,
    payload     JSONB,
    creado_en   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_leads_email ON leads (email);
CREATE INDEX IF NOT EXISTS idx_leads_estado ON leads (estado);
CREATE INDEX IF NOT EXISTS idx_leads_ultimo_contacto ON leads (ultimo_contacto);
CREATE INDEX IF NOT EXISTS idx_seguimiento_lead_id ON seguimiento (lead_id);
CREATE INDEX IF NOT EXISTS idx_error_log_creado_en ON error_log (creado_en);

-- Trigger simple para mantener actualizado_en al día en cada UPDATE
CREATE OR REPLACE FUNCTION set_actualizado_en()
RETURNS TRIGGER AS $$
BEGIN
    NEW.actualizado_en = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_leads_actualizado_en ON leads;
CREATE TRIGGER trg_leads_actualizado_en
    BEFORE UPDATE ON leads
    FOR EACH ROW
    EXECUTE FUNCTION set_actualizado_en();
