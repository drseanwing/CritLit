-- Migration: Create reviews table
-- Purpose: Store systematic review metadata and protocol information
-- Date: 2026-01-25

-- Create trigger function for auto-updating updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create reviews table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(500) NOT NULL,
    prospero_id VARCHAR(50),
    status VARCHAR(50) DEFAULT 'protocol',
    pico JSONB NOT NULL,
    inclusion_criteria JSONB NOT NULL,
    exclusion_criteria JSONB NOT NULL,
    search_strategy TEXT,
    protocol_version INTEGER DEFAULT 1,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comment explaining valid status values
COMMENT ON COLUMN reviews.status IS 'Valid values: protocol, searching, screening, extraction, synthesis, complete';

-- Create trigger to auto-update updated_at column
CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
