# CritLit - Autonomous Systematic Literature Review Pipeline

<<<<<<< HEAD
## Overview

CritLit is an automated systematic literature review (SLR) system designed to streamline the entire research synthesis workflow. It combines workflow automation (n8n), vector database capabilities (PostgreSQL with pgvector), local LLM support (Ollama), and reference management (I-Librarian) into a unified Docker-based deployment.

The system automates key SLR stages including:
- **Search execution** across academic databases (PubMed, etc.)
- **Document deduplication** using vector embeddings
- **Title/abstract screening** with AI assistance
- **Full-text screening** and data extraction
- **Quality assessment** and PRISMA flow diagram generation

## Prerequisites

### Required
- **Docker** (v20.10+) and **Docker Compose** (v2.0+)
- **16GB RAM minimum** (32GB recommended for large review projects)
- **50GB free disk space** for databases and document storage

### Recommended
- **NVIDIA GPU** with CUDA support for Ollama (faster local LLM inference)
- **Docker Desktop** with GPU support enabled (Windows/Mac) or NVIDIA Container Toolkit (Linux)

### API Keys
- **PubMed/NCBI API key** (required) - [Register here](https://www.ncbi.nlm.nih.gov/account/)
- **Anthropic API key** (optional) - For Claude-powered AI screening
- **OpenAI API key** (optional) - Alternative LLM provider
- **Primo API key** (optional) - For institutional full-text access

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/CritLit.git
cd CritLit
```

### 2. Configure Environment
```bash
# Copy the environment template
cp .env.example .env

# Edit .env with your credentials and API keys
# For Windows: notepad .env
# For Mac/Linux: nano .env
```

**Critical configuration values:**
- `POSTGRES_PASSWORD` - Set a strong database password
- `N8N_USER` and `N8N_PASSWORD` - n8n web interface credentials
- `N8N_ENCRYPTION_KEY` - Generate with: `openssl rand -base64 32`
- `PUBMED_API_KEY` - Your NCBI API key
- `CONTACT_EMAIL` - Your email for API compliance

See [.env.example](.env.example) for complete configuration reference.

### 3. Start Services
```bash
# Start all services in detached mode
docker compose up -d

# View logs (optional)
docker compose logs -f
```

### 4. Verify Deployment
```bash
# Check that all services are running
docker compose ps

# Run verification scripts (Linux/Mac/WSL)
bash scripts/verify-postgres.sh
bash scripts/verify-ollama.sh
bash scripts/verify-vector.sh
```

### 5. Access the Web Interface
- **n8n Workflow UI**: http://localhost:5678
  - Login with credentials from `N8N_USER` and `N8N_PASSWORD`
- **I-Librarian**: http://localhost:8080
  - Reference management and PDF organization

## Services Architecture

| Service | Port | Purpose | Technology |
|---------|------|---------|-----------|
| **PostgreSQL** | 5432 | Primary database with vector search | pgvector/pgvector:pg16 |
| **n8n** | 5678 | Workflow automation and orchestration | n8nio/n8n:latest |
| **n8n-worker** | - | Background task execution | n8nio/n8n:latest (worker mode) |
| **Redis** | - | n8n queue and cache | redis:7-alpine |
| **Ollama** | 11434 | Local LLM inference (GPU-accelerated) | ollama/ollama:latest |
| **I-Librarian** | 8080 | Reference management and PDF library | cgrima/i-librarian |

### Service Dependencies
```
n8n → postgres (database), redis (queue)
n8n-worker → postgres, redis, n8n
ollama → (independent, GPU-aware)
i-librarian → (independent)
```

## Database Schema

The PostgreSQL database is automatically initialized with the following schema:

### Core Tables
- **reviews** - SLR project metadata and configuration
- **search_executions** - Search query history and results
- **documents** - Deduplicated article records
- **document_embeddings** - Vector representations for similarity search
- **screening_decisions** - Title/abstract and full-text screening results
- **workflow_state** - n8n workflow execution state tracking
- **audit_log** - Complete audit trail for all operations
- **prisma_flow** - PRISMA flow diagram data

### Key Features
- **pgvector extension** for semantic search (1536-dimension embeddings)
- **HNSW indexing** for fast approximate nearest neighbor search
- **Full-text search** with custom medical/scientific tokenization
- **Trigram indexing** for fuzzy matching and deduplication
- **Automatic timestamps** (`created_at`, `updated_at`) on all tables

See [init-scripts/](init-scripts/) for complete SQL schema definitions.

## Configuration

### Environment Variables (.env)

| Variable | Required | Description |
|----------|----------|-------------|
| `POSTGRES_PASSWORD` | ✅ | Database password for `slr_user` |
| `N8N_USER` | ✅ | n8n web interface username |
| `N8N_PASSWORD` | ✅ | n8n web interface password |
| `N8N_ENCRYPTION_KEY` | ✅ | Base64 encryption key (generate with `openssl rand -base64 32`) |
| `PUBMED_API_KEY` | ✅ | NCBI E-utilities API key for PubMed access |
| `ANTHROPIC_API_KEY` | ⚪ | Claude API key for AI screening (optional) |
| `OPENAI_API_KEY` | ⚪ | OpenAI API key for GPT models (optional) |
| `PRIMO_API_KEY` | ⚪ | Ex Libris Primo API for institutional access (optional) |
| `CONTACT_EMAIL` | ✅ | Email for API rate limit compliance |

### PostgreSQL Performance Tuning

Default settings in `docker-compose.yml`:
```
shared_buffers=512MB       # Adjust based on available RAM
work_mem=32MB              # Memory per query operation
maintenance_work_mem=256MB # Memory for VACUUM, CREATE INDEX
max_connections=100        # Concurrent connection limit
```

For large-scale reviews (10,000+ documents), consider increasing:
- `shared_buffers` to 25% of system RAM
- `work_mem` to 64-128MB
- `maintenance_work_mem` to 512MB-1GB

## Verification

### Check Service Health
```bash
# View running containers
docker compose ps

# Expected output: All services "Up" and healthy
# - slr_postgres (healthy)
# - slr_n8n (Up)
# - slr_n8n_worker (Up)
# - slr_redis (Up)
# - slr_ollama (Up)
# - slr_ilibrarian (Up)
```

### Verify PostgreSQL Initialization
```bash
# Linux/Mac/WSL
bash scripts/verify-postgres.sh

# Expected: Reports all 8 core tables created successfully
```

### Verify Ollama GPU Support
```bash
# Linux/Mac/WSL
bash scripts/verify-ollama.sh

# Expected: Shows NVIDIA GPU detected and available models
```

### Verify Vector Search
```bash
# Linux/Mac/WSL
bash scripts/verify-vector.sh

# Expected: pgvector extension enabled, HNSW index created
```

### Manual Database Verification
```bash
# Connect to PostgreSQL
docker exec -it slr_postgres psql -U slr_user -d slr_database

# List all tables
\dt

# Check extensions
\dx

# Exit
\q
```

## Troubleshooting

### Services Won't Start
```bash
# Check Docker daemon is running
docker info

# View detailed error logs
docker compose logs postgres
docker compose logs n8n

# Restart all services
docker compose restart
```

### "Cannot connect to database" Error
**Problem**: n8n cannot reach PostgreSQL.

**Solution**:
```bash
# Wait for PostgreSQL health check to pass
docker compose logs postgres | grep "ready to accept connections"

# Restart n8n after PostgreSQL is healthy
docker compose restart n8n n8n-worker
```

### Ollama GPU Not Detected
**Problem**: Ollama falls back to CPU inference.

**Solution (NVIDIA GPUs)**:
```bash
# Verify NVIDIA Docker runtime
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# If fails, install NVIDIA Container Toolkit:
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
```

**Solution (No GPU available)**:
```yaml
# Edit docker-compose.yml: Remove GPU reservation section under 'ollama'
# services:
#   ollama:
#     # Remove these lines:
#     # deploy:
#     #   resources:
#     #     reservations:
#     #       devices:
#     #         - driver: nvidia
#     #           count: 1
#     #           capabilities: [gpu]
```

### Port Already in Use
**Problem**: Port 5432, 5678, 8080, or 11434 already in use.

**Solution**:
```bash
# Find process using port (example: 5432)
# Windows:
netstat -ano | findstr :5432

# Mac/Linux:
lsof -i :5432

# Kill the process or change port in docker-compose.yml
# Example: Change PostgreSQL to 15432
# ports:
#   - "15432:5432"
```

### Database Migration Errors
**Problem**: SQL initialization scripts fail.

**Solution**:
```bash
# Stop all services
docker compose down

# Delete PostgreSQL volume (WARNING: destroys all data)
docker volume rm critlit_postgres_data

# Restart (will re-initialize database)
docker compose up -d postgres
```

### n8n Credentials Encrypted with Wrong Key
**Problem**: "Error decrypting credentials" after changing `N8N_ENCRYPTION_KEY`.

**Solution**:
```bash
# Option 1: Restore original N8N_ENCRYPTION_KEY in .env
# Option 2: Reset n8n (WARNING: loses all workflows and credentials)
docker compose down
docker volume rm critlit_n8n_data
docker compose up -d n8n
```

### Out of Disk Space
**Problem**: Docker volumes fill up disk.

**Solution**:
```bash
# Check Docker disk usage
docker system df

# Clean up unused images and containers
docker system prune -a

# Check volume sizes
docker volume ls
docker system df -v

# If necessary, move Docker data directory to larger drive
```

## Workflow Import (Coming Soon)

Pre-built n8n workflows for common SLR tasks will be available in the `workflows/` directory. To import:

1. Access n8n at http://localhost:5678
2. Click **Import from File**
3. Select workflow JSON from `workflows/`
4. Configure credentials (API keys) in n8n settings

## Project Structure

```
CritLit/
├── docker-compose.yml          # Service orchestration
├── .env.example                # Environment template
├── README.md                   # This file
├── init-scripts/               # PostgreSQL schema initialization
│   ├── 000-init.sql            # Master script (documentation)
│   ├── 001-extensions.sql      # pgvector, pg_trgm setup
│   ├── 002-reviews.sql         # SLR project table
│   ├── 003-search-executions.sql
│   ├── 004-documents.sql       # Article metadata
│   ├── 005-document-embeddings.sql  # Vector storage
│   ├── 006-hnsw-index.sql      # Fast similarity search
│   ├── 007-screening-decisions.sql
│   ├── 008-workflow-state.sql
│   ├── 009-audit-log.sql
│   ├── 010-prisma-flow.sql
│   ├── 011-text-search-config.sql   # Medical/scientific tokenization
│   ├── 012-fulltext-index.sql
│   └── 013-trigram-index.sql   # Fuzzy matching
├── scripts/                    # Utility scripts
│   ├── verify-postgres.sh      # Database health check
│   ├── verify-ollama.sh        # Ollama GPU check
│   └── verify-vector.sh        # Vector extension check
└── workflows/                  # n8n workflow templates (coming soon)
```

## Maintenance

### Backup Database
```bash
# Create backup
docker exec slr_postgres pg_dump -U slr_user slr_database > backup_$(date +%Y%m%d).sql

# Restore from backup
cat backup_20260125.sql | docker exec -i slr_postgres psql -U slr_user -d slr_database
```

### Update Services
```bash
# Pull latest images
docker compose pull

# Recreate containers with new images
docker compose up -d --force-recreate
```

### Monitor Resource Usage
```bash
# View resource consumption
docker stats

# View logs for specific service
docker compose logs -f n8n
docker compose logs -f postgres
```

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description

## License

TBD - License to be determined. Check back for updates.

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Check existing documentation in `init-scripts/` for schema details
- Review verification scripts in `scripts/` for diagnostic commands

## Citation

If you use CritLit in your research, please cite:
```
[Citation details to be added]
```

---

**Version**: 1.0.0
**Last Updated**: 2026-01-25
**Maintained By**: CritLit Project Team
=======
A doctoral-level SLR automation system integrating PRISMA 2020 compliance, multi-agent orchestration, and retrieval-augmented generation for **40-70% time savings** while maintaining methodological rigor.

## 🚀 Quick Start

### Prerequisites

- Docker 24.0+ with Docker Compose V2
- 16GB RAM minimum (32GB recommended)
- 50GB free disk space
- NVIDIA GPU (optional, for faster local LLM inference)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/drseanwing/CritLit.git
   cd CritLit
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   nano .env  # Edit with your credentials
   ```

   Required variables:
   - `POSTGRES_PASSWORD`: Secure password for PostgreSQL
   - `N8N_USER` / `N8N_PASSWORD`: n8n web interface credentials
   - `N8N_ENCRYPTION_KEY`: Generate with `openssl rand -hex 32`

   Optional API keys (for full functionality):
   - `PUBMED_API_KEY`: For higher PubMed rate limits
   - `ANTHROPIC_API_KEY`: For Claude-based extraction
   - `OPENAI_API_KEY`: For GPT-4o risk of bias assessment

3. **Start all services**
   ```bash
   ./start.sh
   ```

   This launches:
   - PostgreSQL with pgvector (port 5432)
   - n8n workflow engine (port 5678)
   - n8n worker for queue processing
   - Redis for job queues
   - Ollama for local LLM inference (port 11434)
   - I-Librarian for PDF management (port 8080)

4. **Verify deployment**
   ```bash
   ./scripts/verify_postgres.sh   # Test database connectivity
   ./scripts/verify_vector.sh     # Test pgvector extension
   ./scripts/verify_n8n.sh        # Test n8n web interface
   ./scripts/verify_ollama.sh     # Test Ollama API
   ```

5. **Pull LLM models**
   ```bash
   docker compose exec ollama ollama pull llama3.1:8b
   # For better accuracy (requires ~40GB):
   docker compose exec ollama ollama pull llama3.1:70b
   ```

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   n8n ORCHESTRATION LAYER                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Coordinator  │─▶│  Screening   │─▶│  Synthesis   │      │
│  │    Agent     │  │    Agent     │  │    Agent     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
├─────────────────────────────────────────────────────────────┤
│                  DATA PERSISTENCE LAYER                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │          PostgreSQL + pgvector                       │   │
│  │  • Review state & checkpoints                        │   │
│  │  • Document embeddings (HNSW)                        │   │
│  │  • Screening decisions                               │   │
│  │  • PRISMA flow tracking                              │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                   EXTERNAL INTEGRATIONS                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  PubMed  │  │ Unpaywall│  │I-Librarian│ │ Ollama   │   │
│  │  E-utils │  │   API    │  │ (PDF Repo)│ │ (Local)  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 🗄️ Database Schema

The PostgreSQL database includes:

- **reviews**: Review registry with PROSPERO alignment and PICO criteria
- **search_executions**: Track all database searches for PRISMA reporting
- **documents**: Central document registry with external IDs (PMID, DOI)
- **document_embeddings**: Vector embeddings for semantic search (384d/1536d)
- **screening_decisions**: All screening decisions with confidence scores
- **workflow_state**: Checkpoint/resume capability for long-running workflows
- **audit_log**: Comprehensive audit trail for all decisions
- **prisma_flow**: PRISMA 2020 flow diagram data tracking

All tables are created automatically on first startup via init-scripts.

## 🛠️ Development Workflow

### Managing Services

```bash
# Start all services
./start.sh

# Stop all services
docker compose down

# View logs
docker compose logs -f

# Restart a specific service
docker compose restart n8n

# Stop and remove all data (⚠️ destructive)
docker compose down -v
```

### Database Access

```bash
# Connect to PostgreSQL
docker compose exec postgres psql -U slr_user -d slr_database

# Run a query
docker compose exec postgres psql -U slr_user -d slr_database -c "SELECT * FROM reviews LIMIT 5;"

# View database schema
docker compose exec postgres psql -U slr_user -d slr_database -c "\dt"

# View installed extensions
docker compose exec postgres psql -U slr_user -d slr_database -c "\dx"
```

### n8n Workflow Development

1. Access n8n at http://localhost:5678
2. Login with credentials from `.env` file
3. Import workflow templates from `workflows/` directory
4. Configure credentials for PostgreSQL and Ollama
5. Test workflows with sample PICO criteria

See [workflows/README.md](workflows/README.md) for detailed workflow documentation.

## 📖 Core Concepts

### PICO Framework

All systematic reviews are structured around PICO criteria:

- **P**opulation: Target patient/participant group
- **I**ntervention: Treatment or exposure being studied
- **C**omparator: Alternative intervention or control
- **O**utcomes: Measured endpoints

Example PICO JSON:
```json
{
  "population": "adults with type 2 diabetes",
  "intervention": "SGLT2 inhibitors",
  "comparator": "placebo or standard care",
  "outcomes": ["HbA1c reduction", "cardiovascular events", "renal outcomes"],
  "study_types": ["rct", "cohort"]
}
```

### PRISMA 2020 Compliance

All document flows are tracked for PRISMA reporting:

- **Identification**: Records from databases (PubMed, Cochrane, etc.)
- **Screening**: Title/abstract and full-text screening with exclusion reasons
- **Included**: Studies proceeding to data extraction
- **Synthesis**: Studies included in final analysis

The `prisma_flow` table automatically calculates counts at each stage.

### Checkpoint/Resume

Long-running workflows automatically save checkpoints:

- **Workflow State**: Serialized state after each batch
- **Last Processed**: UUID of last successfully processed item
- **Error Tracking**: Error counts and details for debugging

To resume after interruption:
```sql
SELECT * FROM workflow_state 
WHERE review_id = '<your-review-id>' 
AND status = 'paused'
ORDER BY updated_at DESC LIMIT 1;
```

## 🧪 Alpha Test Status

### ✅ Completed

**Phase 1: Infrastructure Foundation (tasks 1-28)**
- [x] Docker Compose configuration with all services
- [x] PostgreSQL with performance tuning
- [x] n8n with queue mode enabled
- [x] Redis for job queue management
- [x] Ollama for local LLM inference
- [x] Environment variable template
- [x] .gitignore for secrets
- [x] PostgreSQL extensions (vector, pg_trgm, uuid-ossp)
- [x] Complete database schema (13 tables)
- [x] HNSW index for semantic search
- [x] Full-text search configuration
- [x] Trigram index for duplicate detection
- [x] Startup script with health checks
- [x] Verification scripts for all services
- [x] Deployment documentation

**Phase 2: Basic n8n Workflows (tasks 29-38)**
- [x] Main coordinator workflow with state management
- [x] Protocol setup workflow for PICO criteria
- [x] Search execution workflow for PubMed integration
- [x] Screening batch workflow with Ollama LLM
- [x] Workflow documentation and testing guide

### 🚧 In Progress (Phase 3-10)

See [ALPHA_TEST_TASKS.md](ALPHA_TEST_TASKS.md) for complete task list:

- Phase 3: PubMed Integration (tasks 39-48)
- Phase 4: Screening Agent Implementation (tasks 49-62)
- Phase 5: Checkpoint and Resume (tasks 63-71)
- Phase 6: PRISMA Flow Tracking (tasks 72-78)
- Phase 7: Basic Human Review Interface (tasks 79-85)
- Phase 8: Integration Testing (tasks 86-104)
- Phase 9: Alpha Documentation (tasks 105-116)
- Phase 10: Alpha Release Preparation (tasks 117-124)

## 📚 Resources

- [Full Technical Specification](Specifications.md)
- [Alpha Test Task List](ALPHA_TEST_TASKS.md)
- [Cochrane Handbook for Systematic Reviews](https://training.cochrane.org/handbook)
- [PRISMA 2020 Statement](http://www.prisma-statement.org/)
- [n8n Documentation](https://docs.n8n.io/)
- [pgvector Documentation](https://github.com/pgvector/pgvector)
- [Ollama Documentation](https://ollama.ai/docs)

## 🤝 Contributing

This is an alpha-stage research project. Contributions are welcome once core functionality is stable.

## 📄 License

[To be determined]

## 🙏 Acknowledgments

Built following the "Ralph Playbook" pattern for multi-agent orchestration with PostgreSQL-backed persistent memory.

---

**Version**: Alpha 0.2  
**Last Updated**: 2026-01-24  
**Status**: Phase 1 & 2 Complete, Phase 3 In Progress
>>>>>>> 8ec46662c0b4dc47c2c0894f5f415b1c16b9190a
