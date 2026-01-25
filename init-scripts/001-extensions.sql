-- ============================================================================
-- SLR Pipeline Database Initialization - PostgreSQL Extensions
-- ============================================================================
-- This script enables required PostgreSQL extensions for the Systematic
-- Literature Review (SLR) Pipeline database.
--
-- Extensions:
--   - vector (pgvector): Enables vector similarity search for embeddings
--   - pg_trgm: Provides trigram matching for duplicate detection
--   - uuid-ossp: Provides UUID generation functions
--
-- Usage: Run this script before creating tables/schemas
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
