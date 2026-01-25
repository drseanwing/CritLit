#!/bin/bash
# Verification Script: PostgreSQL Connection
# Confirms that PostgreSQL accepts connections and database is accessible

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "PostgreSQL Connection Verification"
echo "========================================"
echo ""

# Check if PostgreSQL container is running
if ! docker ps | grep -q slr_postgres; then
    echo -e "${RED}✗${NC} PostgreSQL container is not running"
    echo "Start services with: ./start.sh"
    exit 1
fi

echo -e "${GREEN}✓${NC} PostgreSQL container is running"

# Test database connection
echo "Testing database connection..."
if docker compose exec -T postgres psql -U slr_user -d slr_database -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Successfully connected to database"
else
    echo -e "${RED}✗${NC} Failed to connect to database"
    exit 1
fi

# Check PostgreSQL version
echo ""
echo "PostgreSQL Version:"
docker compose exec -T postgres psql -U slr_user -d slr_database -c "SELECT version();" | grep PostgreSQL

# Check database size
echo ""
echo "Database Size:"
docker compose exec -T postgres psql -U slr_user -d slr_database -c "SELECT pg_size_pretty(pg_database_size('slr_database')) AS database_size;"

# Check active connections
echo ""
echo "Active Connections:"
docker compose exec -T postgres psql -U slr_user -d slr_database -c "SELECT count(*) FROM pg_stat_activity WHERE datname = 'slr_database';"

echo ""
echo -e "${GREEN}✓${NC} PostgreSQL verification complete!"
