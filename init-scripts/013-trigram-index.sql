-- Trigram index for fuzzy matching/deduplication
--
-- This index uses the pg_trgm extension's gin_trgm_ops operator class to enable
-- similarity searches on document titles. The GIN (Generalized Inverted Index)
-- structure efficiently supports trigram-based pattern matching.
--
-- PRIMARY USE CASE: Detecting duplicate papers with slightly different titles
-- For example, these would be recognized as similar:
--   - "Deep Learning for Natural Language Processing"
--   - "Deep learning for NLP"
--   - "Deep Learning in Natural Language Processing"
--
-- USAGE EXAMPLE:
-- Find documents with titles similar to a search term:
--   SELECT *
--   FROM documents
--   WHERE title % 'search term'
--   ORDER BY similarity(title, 'search term') DESC;
--
-- The % operator performs a similarity match (returns true if similarity > 0.3 by default)
-- The similarity() function returns a score between 0 and 1 indicating how similar the strings are
--
-- PREREQUISITE: Requires pg_trgm extension to be enabled in the database
-- (This should be created in an earlier migration)

CREATE INDEX idx_documents_title_trgm ON documents
    USING gin (title gin_trgm_ops);
