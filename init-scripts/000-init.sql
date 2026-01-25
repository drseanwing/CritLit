-- =============================================================================
-- MASTER INITIALIZATION SCRIPT
-- =============================================================================
-- This is the master initialization script for the CritLit database.
--
-- NOTE: Docker automatically runs SQL scripts in /docker-entrypoint-initdb.d/
-- in alphabetical order. This master script is provided for documentation
-- purposes and for manual initialization if needed, but Docker will execute
-- all numbered scripts (001-*.sql through 013-*.sql) automatically.
--
-- If running manually, this script includes all other initialization scripts
-- in the correct order using PostgreSQL's \i (include) command.
-- =============================================================================

BEGIN;

-- Extension setup
\i /docker-entrypoint-initdb.d/001-extensions.sql

-- Core tables
\i /docker-entrypoint-initdb.d/002-reviews.sql
\i /docker-entrypoint-initdb.d/003-search-executions.sql
\i /docker-entrypoint-initdb.d/004-documents.sql
\i /docker-entrypoint-initdb.d/005-document-embeddings.sql

-- Indexes
\i /docker-entrypoint-initdb.d/006-hnsw-index.sql

-- Workflow tables
\i /docker-entrypoint-initdb.d/007-screening-decisions.sql
\i /docker-entrypoint-initdb.d/008-workflow-state.sql

-- Audit and flow
\i /docker-entrypoint-initdb.d/009-audit-log.sql
\i /docker-entrypoint-initdb.d/010-prisma-flow.sql

-- Full-text search configuration
\i /docker-entrypoint-initdb.d/011-text-search-config.sql
\i /docker-entrypoint-initdb.d/012-fulltext-index.sql
\i /docker-entrypoint-initdb.d/013-trigram-index.sql

COMMIT;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '=============================================================================';
    RAISE NOTICE 'CritLit database initialization completed successfully!';
    RAISE NOTICE 'All tables, extensions, indexes, and configurations have been created.';
    RAISE NOTICE '=============================================================================';
END $$;
