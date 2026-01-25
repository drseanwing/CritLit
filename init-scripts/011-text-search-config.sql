-- 011-text-search-config.sql
-- Configure biomedical text search dictionary
--
-- This migration configures PostgreSQL's full-text search capabilities
-- to better handle biomedical and medical terminology. The custom text
-- search configuration optimizes stemming and indexing for domain-specific
-- terms commonly found in medical literature and research articles.

-- Create a custom text search dictionary using the Snowball stemmer
-- for English language biomedical content
CREATE TEXT SEARCH DICTIONARY english_stem_med (
    TEMPLATE = snowball,
    Language = english
);

-- Create a new text search configuration based on the default English
-- configuration, customized for biomedical content
CREATE TEXT SEARCH CONFIGURATION biomedical (COPY = english);

-- Alter the mapping to use our custom medical stemmer for word tokens
-- This ensures better handling of medical terminology during full-text
-- search operations (e.g., "carcinoma" and "carcinomas" will be properly stemmed)
ALTER TEXT SEARCH CONFIGURATION biomedical
    ALTER MAPPING FOR word, asciiword WITH english_stem_med;

-- The 'biomedical' text search configuration can now be used in queries like:
-- SELECT * FROM articles WHERE to_tsvector('biomedical', content) @@ to_tsquery('biomedical', 'diabetes');
