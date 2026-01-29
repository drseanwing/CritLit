#!/bin/bash
set -e

<<<<<<< HEAD
# REdI brand colors for output
CORAL='\033[38;2;229;91;100m'
NAVY='\033[38;2;27;58;95m'
TEAL='\033[38;2;43;158;158m'
RED='\033[38;2;220;53;69m'
GREEN='\033[38;2;40;167;69m'
YELLOW='\033[38;2;255;193;7m'
NC='\033[0m'

echo "=== REdI | PostgreSQL Verification ==="
=======
echo "=== PostgreSQL Verification Script ==="
>>>>>>> main
echo ""

EXIT_CODE=0

# Test 1: Connection Test
echo "[1/3] Testing database connection..."
if docker compose exec -T postgres psql -U slr_user -d slr_database -c "SELECT 1;" > /dev/null 2>&1; then
<<<<<<< HEAD
    echo -e "${GREEN}✓${NC} Connection successful"
else
    echo -e "${RED}✗${NC} Connection failed"
=======
    echo "✓ Connection successful"
else
    echo "✗ Connection failed"
>>>>>>> main
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
<<<<<<< HEAD
    echo -e "${GREEN}✓${NC} Tables listed successfully"
=======
    echo "✓ Tables listed successfully"
>>>>>>> main
fi
echo ""

# Test 3: Verify Extensions
echo "[3/3] Verifying required extensions..."
EXTENSIONS=$(docker compose exec -T postgres psql -U slr_user -d slr_database -c "SELECT extname FROM pg_extension WHERE extname IN ('vector', 'pg_trgm', 'uuid-ossp');" -t 2>&1)

if echo "$EXTENSIONS" | grep -q "vector"; then
<<<<<<< HEAD
    echo -e "${GREEN}✓${NC} vector extension enabled"
else
    echo -e "${RED}✗${NC} vector extension NOT found"
=======
    echo "✓ vector extension enabled"
else
    echo "✗ vector extension NOT found"
>>>>>>> main
    EXIT_CODE=1
fi

if echo "$EXTENSIONS" | grep -q "pg_trgm"; then
<<<<<<< HEAD
    echo -e "${GREEN}✓${NC} pg_trgm extension enabled"
else
    echo -e "${RED}✗${NC} pg_trgm extension NOT found"
=======
    echo "✓ pg_trgm extension enabled"
else
    echo "✗ pg_trgm extension NOT found"
>>>>>>> main
    EXIT_CODE=1
fi

if echo "$EXTENSIONS" | grep -q "uuid-ossp"; then
<<<<<<< HEAD
    echo -e "${GREEN}✓${NC} uuid-ossp extension enabled"
else
    echo -e "${RED}✗${NC} uuid-ossp extension NOT found"
=======
    echo "✓ uuid-ossp extension enabled"
else
    echo "✗ uuid-ossp extension NOT found"
>>>>>>> main
    EXIT_CODE=1
fi
echo ""

# Final Status
if [ $EXIT_CODE -eq 0 ]; then
<<<<<<< HEAD
    echo -e "=== ${GREEN}✓ ALL CHECKS PASSED${NC} ==="
else
    echo -e "=== ${RED}✗ SOME CHECKS FAILED${NC} ==="
=======
    echo "=== ✓ ALL CHECKS PASSED ==="
else
    echo "=== ✗ SOME CHECKS FAILED ==="
>>>>>>> main
fi

exit $EXIT_CODE
