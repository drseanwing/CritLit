-- Migration: 008-workflow-state.sql
-- Description: Create workflow_state table for checkpoint/resume functionality
-- Date: 2026-01-25
--
-- This table enables workflow checkpoint and resume capabilities, allowing long-running
-- processes to save their progress and recover from interruptions. Each workflow execution
-- can store its current state, track processing progress, and resume from the last
-- successful checkpoint if the process is interrupted or fails.

-- Create workflow_state table
CREATE TABLE workflow_state (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
    execution_id VARCHAR(100) NOT NULL,
    workflow_stage VARCHAR(100) NOT NULL,
    checkpoint_data JSONB NOT NULL,
    items_processed INTEGER,
    items_total INTEGER,
    last_processed_id UUID,
    error_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on review_id for efficient lookups by review
CREATE INDEX idx_workflow_state_review_id ON workflow_state(review_id);

-- Create index on execution_id for finding workflow instances
CREATE INDEX idx_workflow_state_execution_id ON workflow_state(execution_id);

-- Add unique constraint to prevent duplicate execution_ids per review
ALTER TABLE workflow_state ADD CONSTRAINT unique_workflow_execution UNIQUE (review_id, execution_id);

-- Create trigger to call update_updated_at_column before each update
-- (function definition already exists in 002-reviews.sql)
CREATE TRIGGER update_workflow_state_updated_at
    BEFORE UPDATE ON workflow_state
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
