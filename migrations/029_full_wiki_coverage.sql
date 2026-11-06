-- Full wiki coverage: keep every infobox field, every infobox type and every page.

-- 1. Infobox fields the typed parsers do not map (renamed or new wiki fields)
ALTER TABLE creatures     ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE items         ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE spells        ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE npcs          ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE quests        ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE achievements  ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE mounts        ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE outfits       ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE imbuements    ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE hunts         ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE books         ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE buildings     ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE worlds        ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE runes         ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE world_quests  ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE world_changes ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE familiars     ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE tasks         ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE updates       ADD COLUMN IF NOT EXISTS extra_fields JSONB;
ALTER TABLE fansites      ADD COLUMN IF NOT EXISTS extra_fields JSONB;

-- Tables that never got a search vector (search() fell back to name ILIKE)
ALTER TABLE mounts     ADD COLUMN IF NOT EXISTS search_vector tsvector;
ALTER TABLE outfits    ADD COLUMN IF NOT EXISTS search_vector tsvector;
ALTER TABLE imbuements ADD COLUMN IF NOT EXISTS search_vector tsvector;
CREATE INDEX IF NOT EXISTS idx_mounts_search     ON mounts     USING GIN (search_vector);
CREATE INDEX IF NOT EXISTS idx_outfits_search    ON outfits    USING GIN (search_vector);
CREATE INDEX IF NOT EXISTS idx_imbuements_search ON imbuements USING GIN (search_vector);

-- 2. Infobox types without a dedicated parser (Infobox_Object, Infobox_Perk_Option, ...)
CREATE TABLE IF NOT EXISTS other_infoboxes (
    page_id       INTEGER NOT NULL REFERENCES raw_pages(page_id),
    template      TEXT NOT NULL,
    name          TEXT NOT NULL,
    fields        JSONB NOT NULL,
    search_vector tsvector,
    PRIMARY KEY (page_id, template)
);
CREATE INDEX IF NOT EXISTS idx_other_infoboxes_template ON other_infoboxes (template);
CREATE INDEX IF NOT EXISTS idx_other_infoboxes_name ON other_infoboxes (name);
CREATE INDEX IF NOT EXISTS idx_other_infoboxes_search ON other_infoboxes USING GIN (search_vector);

-- 3. Full-text search over every downloaded page (guides, cities, mechanics...)
ALTER TABLE raw_pages ADD COLUMN IF NOT EXISTS search_vector tsvector;
CREATE INDEX IF NOT EXISTS idx_raw_pages_search ON raw_pages USING GIN (search_vector);
