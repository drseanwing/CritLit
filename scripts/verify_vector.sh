#!/bin/bash
# Verification Script: PostgreSQL Vector Extension
# Confirms that pgvector extension is operational

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "pgvector Extension Verification"
echo "========================================"
echo ""

# Check if PostgreSQL container is running
if ! docker ps | grep -q slr_postgres; then
    echo -e "${RED}✗${NC} PostgreSQL container is not running"
    echo "Start services with: ./start.sh"
    exit 1
fi

# Test vector extension
echo "Checking installed extensions..."
extensions=$(docker compose exec -T postgres psql -U slr_user -d slr_database -c "\dx" 2>&1)

if echo "$extensions" | grep -q "vector"; then
    echo -e "${GREEN}✓${NC} pgvector extension is installed"
else
    echo -e "${RED}✗${NC} pgvector extension is not installed"
    exit 1
fi

if echo "$extensions" | grep -q "pg_trgm"; then
    echo -e "${GREEN}✓${NC} pg_trgm extension is installed"
else
    echo -e "${RED}✗${NC} pg_trgm extension is not installed"
    exit 1
fi

if echo "$extensions" | grep -q "uuid-ossp"; then
    echo -e "${GREEN}✓${NC} uuid-ossp extension is installed"
else
    echo -e "${RED}✗${NC} uuid-ossp extension is not installed"
    exit 1
fi

# Test vector operations
echo ""
echo "Testing vector operations..."

# Create a test table with vector column
docker compose exec -T postgres psql -U slr_user -d slr_database > /dev/null 2>&1 <<EOF
DROP TABLE IF EXISTS test_vectors;
CREATE TABLE test_vectors (
    id SERIAL PRIMARY KEY,
    embedding vector(3)
);
INSERT INTO test_vectors (embedding) VALUES ('[1,2,3]'), ('[4,5,6]');
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Vector table creation successful"
else
    echo -e "${RED}✗${NC} Vector table creation failed"
    exit 1
fi

# Test cosine distance query
result=$(docker compose exec -T postgres psql -U slr_user -d slr_database -t -c "SELECT embedding <=> '[1,2,3]' AS distance FROM test_vectors ORDER BY distance LIMIT 1;" 2>&1)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Vector similarity query successful"
    echo "   Sample distance: $(echo $result | xargs)"
else
    echo -e "${RED}✗${NC} Vector similarity query failed"
    exit 1
fi

# Cleanup test table
docker compose exec -T postgres psql -U slr_user -d slr_database -c "DROP TABLE test_vectors;" > /dev/null 2>&1

# Test trigram operations
echo ""
echo "Testing trigram operations..."
trigram_test=$(docker compose exec -T postgres psql -U slr_user -d slr_database -t -c "SELECT similarity('systematic review', 'systematic literature review');" 2>&1)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Trigram similarity function working"
    echo "   Sample similarity: $(echo $trigram_test | xargs)"
else
    echo -e "${RED}✗${NC} Trigram similarity function failed"
    exit 1
fi

# Test UUID generation
echo ""
echo "Testing UUID generation..."
uuid_test=$(docker compose exec -T postgres psql -U slr_user -d slr_database -t -c "SELECT uuid_generate_v4();" 2>&1)

if [ $? -eq 0 ] && [ -n "$uuid_test" ]; then
    echo -e "${GREEN}✓${NC} UUID generation working"
    echo "   Sample UUID: $(echo $uuid_test | xargs)"
else
    echo -e "${RED}✗${NC} UUID generation failed"
    exit 1
fi

echo ""
echo -e "${GREEN}✓${NC} All vector extension verification tests passed!"
