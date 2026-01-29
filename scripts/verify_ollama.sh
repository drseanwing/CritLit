#!/bin/bash
# Verification Script: Ollama API Endpoint
# Confirms that Ollama API endpoint responds

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "Ollama API Verification"
echo "========================================"
echo ""

# Check if Ollama container is running
if ! docker ps | grep -q slr_ollama; then
    echo -e "${RED}✗${NC} Ollama container is not running"
    echo "Start services with: ./start.sh"
    exit 1
fi

echo -e "${GREEN}✓${NC} Ollama container is running"

# Test Ollama API endpoint
echo ""
echo "Testing Ollama API endpoint..."

max_attempts=20
attempt=1

while [ $attempt -le $max_attempts ]; do
<<<<<<< HEAD
    if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Ollama API is responding at http://localhost:11434"
=======
    if curl -s http://localhost:7362/api/tags > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Ollama API is responding at http://localhost:7362"
>>>>>>> main
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        echo -e "${RED}✗${NC} Ollama API is not responding after ${max_attempts} attempts"
        echo "Check logs with: docker compose logs ollama"
        exit 1
    fi
    
    echo -n "."
    sleep 2
    attempt=$((attempt + 1))
done

# Check for installed models
echo ""
echo "Checking installed models..."
<<<<<<< HEAD
models=$(curl -s http://localhost:11434/api/tags 2>&1)
=======
models=$(curl -s http://localhost:7362/api/tags 2>&1)
>>>>>>> main

if echo "$models" | grep -q "models"; then
    echo -e "${GREEN}✓${NC} Ollama API can list models"
    
    # Check if llama3.1 models are installed
    if echo "$models" | grep -q "llama3.1"; then
        echo -e "${GREEN}✓${NC} Llama 3.1 model(s) found"
        echo ""
        echo "Installed Llama 3.1 models:"
        echo "$models" | grep -o '"name":"llama3.1[^"]*"' | sed 's/"name":"//;s/"$//' | sed 's/^/  - /'
    else
        echo -e "${YELLOW}⚠${NC} No Llama 3.1 models installed yet"
        echo ""
        echo "To pull Llama 3.1 models, run:"
        echo "  docker compose exec ollama ollama pull llama3.1:8b"
        echo "  docker compose exec ollama ollama pull llama3.1:70b  (requires ~40GB)"
    fi
else
    echo -e "${RED}✗${NC} Failed to query Ollama models"
    exit 1
fi

# Check GPU availability if NVIDIA runtime is available
echo ""
echo "Checking GPU availability..."
if docker compose exec ollama nvidia-smi > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} GPU is available to Ollama"
    docker compose exec ollama nvidia-smi --query-gpu=name,memory.total --format=csv,noheader | sed 's/^/  GPU: /'
else
    echo -e "${YELLOW}⚠${NC} GPU not detected (will use CPU - slower inference)"
    echo "  For GPU support, ensure:"
    echo "  - NVIDIA drivers are installed"
    echo "  - Docker has NVIDIA runtime configured"
    echo "  - GPU is specified in docker-compose.yml"
fi

echo ""
echo -e "${GREEN}✓${NC} Ollama verification complete!"
