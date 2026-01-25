-- Migration: 005 - Create document_embeddings table
-- Description: Stores vector embeddings for document sections to enable semantic search
-- Date: 2026-01-25

-- Create document_embeddings table
-- ===================================
-- This table stores vector embeddings for different sections of documents,
-- enabling semantic similarity search and retrieval.
--
-- Embedding Strategy:
-- - Documents are split into semantic sections (abstract, methods, results, etc.)
-- - Each section is further chunked if needed to fit model context windows
-- - Embeddings are versioned to support model upgrades without data loss
--
-- Section Types:
-- - abstract: Document abstract/summary
-- - methods: Methodology section
-- - results: Results/findings section
-- - discussion: Discussion/interpretation section
-- - full_summary: Complete document summary embedding
--
-- Embedding Model:
-- - Default: OpenAI text-embedding-3-small (1536 dimensions)
-- - Vector dimension must match embedding model output
-- - embedding_version tracks model changes over time

CREATE TABLE document_embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    section_type VARCHAR(50) NOT NULL,
    chunk_index INTEGER NOT NULL,
    chunk_text TEXT NOT NULL,
    embedding vector(1536),
    embedding_model VARCHAR(100) NOT NULL,
    embedding_version INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(document_id, section_type, chunk_index, embedding_version)
);

-- Create indexes for query performance
-- =====================================

-- Index on document_id for fast filtering by document
CREATE INDEX idx_embeddings_document_id ON document_embeddings(document_id);

-- Index on section_type for filtering by section
CREATE INDEX idx_embeddings_section_type ON document_embeddings(section_type);

-- Composite index for document + section queries
CREATE INDEX idx_embeddings_doc_section ON document_embeddings(document_id, section_type);

-- Add table and column comments
-- ==============================

COMMENT ON TABLE document_embeddings IS 'Vector embeddings for document sections enabling semantic similarity search';
COMMENT ON COLUMN document_embeddings.section_type IS 'Type of document section: abstract, methods, results, discussion, full_summary';
COMMENT ON COLUMN document_embeddings.chunk_index IS 'Sequential index for chunks within a section (0-based)';
COMMENT ON COLUMN document_embeddings.embedding IS 'Vector embedding (1536 dimensions for OpenAI text-embedding-3-small)';
COMMENT ON COLUMN document_embeddings.embedding_model IS 'Name of the embedding model used (e.g., text-embedding-3-small)';
COMMENT ON COLUMN document_embeddings.embedding_version IS 'Version number to track embedding model changes over time';
