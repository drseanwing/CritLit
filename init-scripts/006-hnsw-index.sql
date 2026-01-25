-- Migration: 006-hnsw-index.sql
-- Description: Create HNSW index for fast semantic search on document embeddings
-- Date: 2026-01-25

-- HNSW (Hierarchical Navigable Small World) Index
-- ================================================
-- HNSW is a graph-based algorithm for approximate nearest neighbor search.
-- It builds a multi-layer graph structure where each layer contains links
-- between similar vectors, enabling logarithmic search time complexity.
--
-- Index Parameters:
-- - m = 16: Number of bi-directional connections per layer
--   * Higher values (24-48) = better recall, more memory, slower builds
--   * Lower values (8-12) = faster builds, less memory, reduced recall
--   * 16 is a balanced default for most use cases
--
-- - ef_construction = 64: Size of dynamic candidate list during index construction
--   * Higher values (100-200) = better index quality, slower builds
--   * Lower values (32-50) = faster builds, potentially lower quality
--   * 64 provides good quality without excessive build time
--
-- Distance Metric:
-- - vector_cosine_ops: Uses cosine similarity for distance calculation
--   * Measures angle between vectors (ideal for normalized embeddings)
--   * Range: -1 (opposite) to 1 (identical)
--   * Alternative: vector_l2_ops (Euclidean distance) or vector_ip_ops (inner product)

CREATE INDEX IF NOT EXISTS idx_embeddings_hnsw ON document_embeddings
    USING hnsw (embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);

-- Note: Index creation may take time on large datasets
-- Consider creating the index CONCURRENTLY in production:
-- CREATE INDEX CONCURRENTLY idx_embeddings_hnsw ON document_embeddings ...
