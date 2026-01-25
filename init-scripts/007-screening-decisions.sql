-- Migration: 007 - Create screening_decisions table
-- Description: Tracks screening decisions (include/exclude) at title-abstract and full-text stages
-- Date: 2026-01-25

-- Create screening_decisions table
CREATE TABLE screening_decisions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
    screening_stage VARCHAR(50) NOT NULL,
    reviewer_type VARCHAR(50) NOT NULL,
    reviewer_id VARCHAR(100),
    decision VARCHAR(20) NOT NULL,
    confidence FLOAT,
    exclusion_reason VARCHAR(200),
    rationale TEXT,
    criteria_matched JSONB,
    processing_time_ms INTEGER,
    human_reviewed BOOLEAN DEFAULT FALSE,
    overridden BOOLEAN DEFAULT FALSE,
    reviewed_at TIMESTAMPTZ,
    reviewer_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for fast lookups
CREATE INDEX idx_screening_doc ON screening_decisions(document_id);
CREATE INDEX idx_screening_stage ON screening_decisions(screening_stage, decision);
CREATE INDEX idx_screening_review ON screening_decisions(review_id);

-- Add comments explaining column values and constraints
COMMENT ON TABLE screening_decisions IS 'Tracks screening decisions at title-abstract and full-text stages with human and AI reviewers';
COMMENT ON COLUMN screening_decisions.screening_stage IS 'Valid values: title_abstract, full_text';
COMMENT ON COLUMN screening_decisions.reviewer_type IS 'Valid values: human, ai_primary, ai_secondary';
COMMENT ON COLUMN screening_decisions.reviewer_id IS 'User ID for human reviewers, model name/version for AI reviewers';
COMMENT ON COLUMN screening_decisions.decision IS 'Valid values: include, exclude, uncertain';
COMMENT ON COLUMN screening_decisions.confidence IS 'AI screening confidence score (0.0-1.0), NULL for human reviewers';
COMMENT ON COLUMN screening_decisions.exclusion_reason IS 'Short code/category for why document was excluded';
COMMENT ON COLUMN screening_decisions.rationale IS 'Detailed explanation of the screening decision';
COMMENT ON COLUMN screening_decisions.criteria_matched IS 'JSON object tracking which inclusion/exclusion criteria were matched';
COMMENT ON COLUMN screening_decisions.processing_time_ms IS 'Time taken to make the screening decision in milliseconds';

-- Create trigger for auto-updating updated_at
CREATE TRIGGER screening_decisions_updated_at
    BEFORE UPDATE ON screening_decisions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
