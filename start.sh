#!/bin/bash
# CritLit Startup Script
# Launches all Docker services with health validation and provides status feedback

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[CritLit]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to check if .env file exists
check_env_file() {
    print_status "Checking environment configuration..."
    if [ ! -f .env ]; then
        print_error ".env file not found"
        print_warning "Please copy .env.example to .env and configure your credentials:"
        echo "    cp .env.example .env"
        echo "    nano .env  # or use your preferred editor"
        exit 1
    fi
    print_success ".env file found"
}

# Function to check if Docker is running
check_docker() {
    print_status "Checking Docker availability..."
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running or not accessible"
        echo "Please start Docker and try again"
        exit 1
    fi
    print_success "Docker is running"
}

# Function to check if Docker Compose is available
check_docker_compose() {
    print_status "Checking Docker Compose availability..."
    if ! docker compose version > /dev/null 2>&1; then
        print_error "Docker Compose is not available"
        echo "Please install Docker Compose and try again"
        exit 1
    fi
    print_success "Docker Compose is available"
}

# Function to start Docker services
start_services() {
    print_status "Starting Docker services..."
    echo ""
    docker compose up -d
    echo ""
    print_success "Services started"
}

# Function to wait for a service to be healthy
wait_for_service() {
    local service=$1
    local max_attempts=$2
    local attempt=1
    
    print_status "Waiting for $service to be healthy..."
    
    while [ $attempt -le $max_attempts ]; do
        local health_status=$(docker inspect --format='{{.State.Health.Status}}' slr_$service 2>/dev/null || echo "none")
        
        if [ "$health_status" = "healthy" ]; then
            print_success "$service is healthy"
            return 0
        elif [ "$health_status" = "none" ]; then
            # Service doesn't have a health check, just check if it's running
            local running=$(docker inspect --format='{{.State.Running}}' slr_$service 2>/dev/null || echo "false")
            if [ "$running" = "true" ]; then
                print_success "$service is running"
                return 0
            fi
        fi
        
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo ""
    print_error "$service failed to become healthy"
    return 1
}

# Function to display service status
display_status() {
    echo ""
    echo "========================================"
    print_status "Service Status"
    echo "========================================"
    docker compose ps
    echo ""
}

# Function to display access information
display_access_info() {
    echo "========================================"
    print_status "Access Information"
    echo "========================================"
    echo ""
    echo "  📊 n8n Workflow Interface:"
    echo "     URL: http://localhost:5678"
    echo "     Login with credentials from .env file"
    echo ""
    echo "  🗄️  PostgreSQL Database:"
    echo "     Host: localhost"
    echo "     Port: 5432"
    echo "     Database: slr_database"
    echo "     User: slr_user"
    echo ""
    echo "  🤖 Ollama LLM API:"
    echo "     URL: http://localhost:11434"
    echo "     Pull models with: docker compose exec ollama ollama pull llama3.1:8b"
    echo ""
    echo "  📚 I-Librarian PDF Manager:"
    echo "     URL: http://localhost:8080"
    echo ""
    echo "========================================"
    print_status "Next Steps"
    echo "========================================"
    echo ""
    echo "  1. Access n8n at http://localhost:5678"
    echo "  2. Pull Ollama models for screening:"
    echo "     docker compose exec ollama ollama pull llama3.1:8b"
    echo "  3. Verify database schema:"
    echo "     docker compose exec postgres psql -U slr_user -d slr_database -c '\\dt'"
    echo "  4. Check the documentation for creating your first review"
    echo ""
    print_success "CritLit SLR Pipeline is ready!"
    echo ""
}

# Function to show logs
show_logs() {
    print_status "Showing service logs (Ctrl+C to exit)..."
    echo ""
    docker compose logs -f
}

# Main script execution
main() {
    echo ""
    echo "========================================"
    echo "  CritLit SLR Pipeline Startup"
    echo "========================================"
    echo ""
    
    # Pre-flight checks
    check_env_file
    check_docker
    check_docker_compose
    
    # Start services
    start_services
    
    # Wait for critical services
    print_status "Performing health checks..."
    echo ""
    
    if ! wait_for_service "postgres" 30; then
        print_error "PostgreSQL failed to start. Check logs with: docker compose logs postgres"
        exit 1
    fi
    
    sleep 2  # Give n8n a moment to connect to postgres
    
    if ! wait_for_service "redis" 10; then
        print_warning "Redis may not be fully ready, but continuing..."
    fi
    
    if ! wait_for_service "n8n" 15; then
        print_warning "n8n may not be fully ready, but continuing..."
    fi
    
    if ! wait_for_service "n8n_worker" 10; then
        print_warning "n8n worker may not be fully ready, but continuing..."
    fi
    
    if ! wait_for_service "ollama" 10; then
        print_warning "Ollama may not be fully ready, but continuing..."
    fi
    
    if ! wait_for_service "ilibrarian" 10; then
        print_warning "I-Librarian may not be fully ready, but continuing..."
    fi
    
    # Display status and access information
    display_status
    display_access_info
    
    # Ask if user wants to see logs
    if [ -t 0 ]; then  # Check if running in interactive terminal
        echo ""
        read -p "Would you like to view service logs? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            show_logs
        fi
    fi
}

# Run main function
main "$@"
