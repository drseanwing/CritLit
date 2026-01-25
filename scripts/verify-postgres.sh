#!/bin/bash
set -e

echo "=== PostgreSQL Verification Script ==="
echo ""

EXIT_CODE=0

# Test 1: Connection Test
echo "[1/3] Testing database connection..."
if docker compose exec -T postgres psql -U slr_user -d slr_database -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✓ Connection successful"
else
    echo "✗ Connection failed"
    EXIT_CODE=1
fi
echo ""

# Test 2: List Tables
echo "[2/3] Listing all tables..."
TABLES=$(docker compose exec -T postgres psql -U slr_user -d slr_database -c "\dt" 2>&1)
if echo "$TABLES" | grep -q "Did not find any relations"; then
    echo "! No tables found (database is empty)"
else
    echo "$TABLES"
    echo "✓ Tables listed successfully"
fi
echo ""

# Test 3: Verify Extensions
echo "[3/3] Verifying required extensions..."
EXTENSIONS=$(docker compose exec -T postgres psql -U slr_user -d slr_database -c "SELECT extname FROM pg_extension WHERE extname IN ('vector', 'pg_trgm', 'uuid-ossp');" -t 2>&1)

if echo "$EXTENSIONS" | grep -q "vector"; then
    echo "✓ vector extension enabled"
else
    echo "✗ vector extension NOT found"
    EXIT_CODE=1
fi

if echo "$EXTENSIONS" | grep -q "pg_trgm"; then
    echo "✓ pg_trgm extension enabled"
else
    echo "✗ pg_trgm extension NOT found"
    EXIT_CODE=1
fi

if echo "$EXTENSIONS" | grep -q "uuid-ossp"; then
    echo "✓ uuid-ossp extension enabled"
else
    echo "✗ uuid-ossp extension NOT found"
    EXIT_CODE=1
fi
echo ""

# Final Status
if [ $EXIT_CODE -eq 0 ]; then
    echo "=== ✓ ALL CHECKS PASSED ==="
else
    echo "=== ✗ SOME CHECKS FAILED ==="
fi

exit $EXIT_CODE
