#!/bin/bash
# Verification Script: n8n Web Interface
# Confirms that n8n web interface is accessible

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "n8n Web Interface Verification"
echo "========================================"
echo ""

# Check if n8n container is running
if ! docker ps | grep -q slr_n8n; then
    echo -e "${RED}✗${NC} n8n container is not running"
    echo "Start services with: ./start.sh"
    exit 1
fi

echo -e "${GREEN}✓${NC} n8n container is running"

# Test n8n web interface availability
echo ""
echo "Testing n8n web interface..."

max_attempts=30
attempt=1

while [ $attempt -le $max_attempts ]; do
<<<<<<< HEAD
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 | grep -q "200\|401"; then
        echo -e "${GREEN}✓${NC} n8n web interface is accessible at http://localhost:5678"
=======
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:7361 | grep -q "200\|401"; then
        echo -e "${GREEN}✓${NC} n8n web interface is accessible at http://localhost:7361"
>>>>>>> main
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        echo -e "${RED}✗${NC} n8n web interface is not responding after ${max_attempts} attempts"
        echo "Check logs with: docker compose logs n8n"
        exit 1
    fi
    
    echo -n "."
    sleep 2
    attempt=$((attempt + 1))
done

# Check n8n worker status
echo ""
if docker ps | grep -q slr_n8n_worker; then
    echo -e "${GREEN}✓${NC} n8n worker is running"
else
    echo -e "${YELLOW}⚠${NC} n8n worker is not running (queue mode may not work)"
fi

# Check Redis connectivity (required for queue mode)
echo ""
if docker ps | grep -q slr_redis; then
    echo -e "${GREEN}✓${NC} Redis is running (queue mode enabled)"
else
    echo -e "${RED}✗${NC} Redis is not running (queue mode will not work)"
    exit 1
fi

echo ""
echo "========================================"
echo "n8n Access Information"
echo "========================================"
echo ""
<<<<<<< HEAD
echo "  URL: http://localhost:5678"
=======
echo "  URL: http://localhost:7361"
>>>>>>> main
echo "  Username: (from .env N8N_USER)"
echo "  Password: (from .env N8N_PASSWORD)"
echo ""
echo -e "${GREEN}✓${NC} n8n verification complete!"
