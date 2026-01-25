-- Migration: 004 - Create documents table
-- Description: Stores bibliographic metadata and full text for documents in systematic reviews
-- Date: 2026-01-25

-- Create documents table
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
    -- external_ids holds identifiers from various databases:
    -- {pmid, doi, scopus_id, wos_id, embase_id, etc.}
    external_ids JSONB NOT NULL,
    title TEXT NOT NULL,
    authors JSONB,
    abstract TEXT,
    full_text TEXT,
    publication_year INTEGER,
    journal VARCHAR(500),
    study_type VARCHAR(100),
    source_database VARCHAR(100),
    pdf_path VARCHAR(500),
    is_duplicate BOOLEAN DEFAULT FALSE,
    duplicate_of UUID REFERENCES documents(id),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_review_doi UNIQUE(review_id, (external_ids->>'doi'))
);

-- Create index for fast PubMed lookups
CREATE INDEX idx_documents_pmid ON documents((external_ids->>'pmid'));

-- Create index for DOI lookups
CREATE INDEX idx_documents_doi ON documents((external_ids->>'doi'));

-- Create index for review_id for fast filtering
CREATE INDEX idx_documents_review_id ON documents(review_id);

-- Create index for duplicate tracking
CREATE INDEX idx_documents_duplicate_of ON documents(duplicate_of) WHERE duplicate_of IS NOT NULL;

-- Create trigger to update updated_at timestamp
CREATE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON documents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add table comment
COMMENT ON TABLE documents IS 'Stores bibliographic metadata and full text for documents in systematic reviews';
COMMENT ON COLUMN documents.external_ids IS 'JSON object containing identifiers from various databases (pmid, doi, scopus_id, wos_id, embase_id, etc.)';
COMMENT ON COLUMN documents.authors IS 'JSON array of author objects with name, affiliation, etc.';
COMMENT ON COLUMN documents.metadata IS 'Additional metadata specific to source database or document type';
COMMENT ON COLUMN documents.is_duplicate IS 'Flag indicating if this document is a duplicate of another';
COMMENT ON COLUMN documents.duplicate_of IS 'Reference to the canonical document if this is a duplicate';
