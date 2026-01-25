-- =====================================================================
-- PRISMA 2020 Flow Diagram Tracking
-- =====================================================================
-- This table captures the quantitative flow data for systematic reviews
-- following the PRISMA 2020 statement guidelines.
--
-- Key JSONB columns:
--   - records_identified: {database_name: count} format
--     Example: {"pubmed": 1234, "embase": 567, "cochrane": 89}
--   - reports_excluded: [{reason, count}] format
--     Example: [{"reason": "wrong intervention", "count": 45},
--               {"reason": "wrong outcome", "count": 32}]
-- =====================================================================

CREATE TABLE prisma_flow (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
    flow_version INTEGER DEFAULT 1,

    -- Identification phase
    records_identified JSONB,                -- {database_name: count} format

    -- Screening phase
    duplicates_removed INTEGER,
    records_screened INTEGER,
    records_excluded_screening INTEGER,

    -- Retrieval phase
    reports_sought INTEGER,
    reports_not_retrieved INTEGER,

    -- Assessment phase
    reports_assessed INTEGER,
    reports_excluded JSONB,                  -- [{reason, count}] format

    -- Included phase
    studies_included INTEGER,
    reports_of_included INTEGER,

    -- Metadata
    generated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for efficient review lookups
CREATE INDEX idx_prisma_flow_review ON prisma_flow(review_id);

-- Comments for clarity
COMMENT ON TABLE prisma_flow IS 'Tracks PRISMA 2020 flow diagram quantitative data for systematic reviews';
COMMENT ON COLUMN prisma_flow.records_identified IS 'JSONB object mapping database names to record counts: {database_name: count}';
COMMENT ON COLUMN prisma_flow.reports_excluded IS 'JSONB array of exclusion reasons with counts: [{reason, count}]';
COMMENT ON COLUMN prisma_flow.flow_version IS 'Version number to track updates to the flow diagram data';
