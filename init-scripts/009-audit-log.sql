-- Migration: 009-audit-log.sql
-- Description: Create audit_log table for tracking all review-related actions and decisions
-- Date: 2026-01-25
--
-- This table provides complete decision tracking for PRISMA compliance by recording
-- all actions taken on review entities. It supports both human and AI agent actions,
-- storing before/after values and reasoning for each change. This ensures full
-- traceability and reproducibility of the systematic review process.

-- Create audit_log table
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    review_id UUID,
    entity_type VARCHAR(50),  -- Type of entity: document, screening, extraction, rob, grade
    entity_id UUID,           -- ID of the affected entity
    action VARCHAR(50),       -- Action performed: create, update, delete, approve, reject
    actor_type VARCHAR(50),   -- Who performed the action: human, ai_agent
    actor_id VARCHAR(100),    -- Identifier for the actor (user ID or agent name)
    old_value JSONB,          -- Previous state of the entity (NULL for create actions)
    new_value JSONB,          -- New state of the entity (NULL for delete actions)
    reasoning TEXT,           -- Explanation for the action (especially important for AI decisions)
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on review_id for efficient filtering by review
CREATE INDEX idx_audit_review ON audit_log(review_id);

-- Create index on entity for tracking changes to specific entities
CREATE INDEX idx_audit_entity ON audit_log(entity_type, entity_id);

-- Create index on timestamp for chronological queries
CREATE INDEX idx_audit_time ON audit_log(timestamp DESC);
