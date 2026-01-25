-- Migration: Create search_executions table
-- Purpose: Track database searches performed for systematic reviews (PubMed, Cochrane, Embase, CINAHL, etc.)
-- Date: 2026-01-25

-- Create search_executions table
CREATE TABLE search_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
    database_name VARCHAR(100) NOT NULL,
    search_query TEXT NOT NULL,
    query_syntax TEXT,
    date_executed DATE NOT NULL,
    date_range_start DATE,
    date_range_end DATE,
    results_count INTEGER,
    filters_applied JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comment explaining this table's purpose
COMMENT ON TABLE search_executions IS 'Records search executions across medical literature databases including PubMed, Cochrane Library, Embase, and CINAHL';

-- Add helpful column comments
COMMENT ON COLUMN search_executions.database_name IS 'Name of the database searched (e.g., PubMed, Cochrane, Embase, CINAHL)';
COMMENT ON COLUMN search_executions.query_syntax IS 'Database-specific query syntax used (e.g., MeSH terms, Boolean operators)';
COMMENT ON COLUMN search_executions.filters_applied IS 'JSON object storing applied filters such as publication type, language, study design';
