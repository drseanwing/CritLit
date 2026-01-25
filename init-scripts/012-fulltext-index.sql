-- Full-text search index on documents table
-- Created: 2026-01-25
-- Description: Creates a GIN index for efficient full-text searching across document titles and abstracts

-- Create full-text search index on title and abstract
-- Uses GIN (Generalized Inverted Index) for fast full-text search performance
-- Combines title and abstract fields for comprehensive searching
-- Uses the 'biomedical' text search configuration created in 011-biomedical-ts-config.sql
-- which includes domain-specific stop words and stemming rules
CREATE INDEX idx_documents_fts ON documents
    USING gin (to_tsvector('biomedical',
        COALESCE(title, '') || ' ' || COALESCE(abstract, '')));

-- GIN indexes are optimized for full-text search queries like:
-- SELECT * FROM documents WHERE to_tsvector('biomedical', title || ' ' || abstract) @@ to_tsquery('biomedical', 'search_term');
--
-- COALESCE ensures NULL values don't break the concatenation
-- The space separator ensures words from title and abstract don't merge
