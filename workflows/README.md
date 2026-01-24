# n8n Workflows for CritLit SLR Pipeline

This directory contains n8n workflow JSON files for the Autonomous Systematic Literature Review Pipeline. These workflows implement the coordinator/worker pattern with PostgreSQL-backed state management.

## Workflow Files

### 1. slr_main_coordinator.json
**Purpose**: Main entry point for the SLR pipeline. Orchestrates all sub-workflows and manages state transitions.

**Key Features**:
- Webhook trigger for initiating review workflows
- PostgreSQL state loading and checkpoint management
- AI coordinator agent for stage routing
- Switch-based workflow delegation
- Human review wait nodes for checkpoints

**Trigger**: POST to `/webhook/slr-start` with body:
```json
{
  "review_id": "uuid-of-review"
}
```

### 2. slr_protocol_setup.json
**Purpose**: Create or update a systematic review protocol with PICO criteria.

**Key Features**:
- Accept review metadata and PICO criteria
- Store protocol in `reviews` table
- Version control for protocol updates
- Comprehensive audit logging

**Trigger**: POST to `/webhook/slr-protocol-setup` with body:
```json
{
  "review_id": "uuid-of-review",
  "title": "Review title",
  "pico": {
    "population": "Target population",
    "intervention": "Intervention being studied",
    "comparator": "Control or comparison",
    "outcomes": ["Outcome 1", "Outcome 2"],
    "study_types": ["rct", "cohort"]
  },
  "inclusion_criteria": {},
  "exclusion_criteria": {},
  "search_strategy": "Boolean search query"
}
```

### 3. slr_search_execution.json
**Purpose**: Execute PubMed searches using E-utilities API and store results with full document parsing.

**Key Features**:
- PubMed ESearch API integration with history server
- PubMed EFetch API for retrieving document metadata in XML format
- Complete XML parsing to extract structured document data:
  - Title, authors (with affiliations), abstract (including structured abstracts)
  - Publication year, journal, DOI, PMID
  - Study type detection (RCT, Systematic Review, Meta-Analysis, etc.)
  - MeSH terms, keywords, and publication types
- Batch processing for large result sets (configurable batch size)
- Automatic rate limit handling with retry logic
- Document persistence to PostgreSQL with duplicate detection (upsert on PMID)
- Search execution logging for PRISMA tracking
- PRISMA flow count updates after document import
- Comprehensive audit logging

**Trigger**: POST to `/webhook/slr-search-execution` with body:
```json
{
  "review_id": "uuid-of-review",
  "search_query": "(hypertension[MeSH Terms]) AND (SGLT2 inhibitors[MeSH Terms])",
  "database_name": "PubMed",
  "max_results": 1000,
  "batch_size": 500
}
```

### 5. slr_pubmed_test.json
**Purpose**: Test workflow for validating PubMed integration with a small search.

**Key Features**:
- Automatically creates test review record if not exists
- Uses a small, targeted search query for quick testing
- Full XML parsing and document storage
- Verification queries to confirm document persistence
- Detailed test results with next steps

**Trigger**: POST to `/webhook/slr-test-pubmed-search` with body:
```json
{
  "review_id": "00000000-0000-0000-0000-000000000001",
  "search_query": "\"SGLT2 inhibitors\"[Title] AND \"systematic review\"[Publication Type] AND 2023[Publication Date]",
  "max_results": 25
}
```

All parameters are optional - defaults are provided for quick testing.

### 4. slr_screening_batch.json
**Purpose**: Perform AI-powered title/abstract screening using Ollama LLM with confidence-based routing.

**Key Features**:
- Batch fetching of unscreened documents from PostgreSQL
- Comprehensive PICO-based screening prompt template following Cochrane standards
- Ollama integration with configurable model (llama3.1:8b or llama3.1:70b)
- Structured JSON output parsing for screening decisions
- Confidence score calculation for decision routing
- Conditional routing of low-confidence decisions for human review
- Rate limiting between LLM calls to prevent overwhelming Ollama
- Error handling for LLM failures with automatic flagging for human review
- Document status updates (included, excluded, needs_review)
- Audit logging for all screening decisions
- Statistics aggregation (include/exclude/uncertain counts, average confidence)

**Trigger**: POST to `/webhook/slr-screening-batch` with body:
```json
{
  "review_id": "uuid-of-review",
  "batch_size": 50,
  "confidence_threshold": 0.85
}
```

**Response includes**:
- Documents screened count
- Statistics (included, excluded, uncertain, needs_human_review)
- Average confidence score
- Average processing time

## Importing Workflows into n8n

1. **Access n8n Web Interface**
   ```
   http://localhost:5678
   ```

2. **Import Workflow**
   - Click "Add Workflow" → "Import from File"
   - Select a workflow JSON file from this directory
   - Workflow will be imported with all nodes and connections

3. **Configure Credentials**
   
   Before using the workflows, configure these credentials in n8n.
   
   **See [credentials/README.md](credentials/README.md) for detailed credential configuration instructions.**
   
   Quick reference:
   
   - **PostgreSQL (SLR Database)**
     - Host: `postgres` (Docker network) or `localhost` (local)
     - Port: `5432`
     - Database: `slr_database`
     - User: `slr_user`
     - Password: From `.env` file (`POSTGRES_PASSWORD`)
   
   - **PubMed API (HTTP Query Auth)**
     - Create an HTTP Query Auth credential
     - Name: `api_key`
     - Value: From `.env` file (`PUBMED_API_KEY`)
   
   - **Ollama API**
     - Base URL: `http://ollama:11434` (Docker) or from `.env` (`OLLAMA_BASE_URL`)

4. **Set Environment Variables**
   
   In n8n settings, configure these environment variables:
   
   ```
   PROTOCOL_WORKFLOW_ID=<id-of-imported-protocol-workflow>
   SEARCH_WORKFLOW_ID=<id-of-imported-search-workflow>
   SCREENING_WORKFLOW_ID=<id-of-imported-screening-workflow>
   PUBMED_API_KEY=<your-pubmed-api-key>
   CONTACT_EMAIL=<your-email-for-pubmed>
   OLLAMA_BASE_URL=http://ollama:11434
   OLLAMA_SCREENING_MODEL=llama3.1:8b
   SCREENING_BATCH_SIZE=50
   SCREENING_CONFIDENCE_THRESHOLD=0.85
   ```

## Workflow Execution Flow

```
┌─────────────────────────────────────────────────┐
│         slr_main_coordinator.json               │
│                                                 │
│  1. Receive webhook trigger                    │
│  2. Load review state from PostgreSQL          │
│  3. Coordinator agent determines next stage    │
│  4. Route to appropriate sub-workflow          │
│  5. Save checkpoint after completion           │
│  6. Loop or wait for human review              │
└─────────────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┬───────────┐
        │            │            │           │
        ▼            ▼            ▼           ▼
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│ Protocol │  │  Search  │  │Screening │  │  Human   │
│  Setup   │  │Execution │  │  Batch   │  │  Review  │
└──────────┘  └──────────┘  └──────────┘  └──────────┘
```

## Testing Workflows

### 1. Test Protocol Setup
```bash
curl -X POST http://localhost:5678/webhook/slr-protocol-setup \
  -H "Content-Type: application/json" \
  -d '{
    "review_id": "00000000-0000-0000-0000-000000000001",
    "title": "Test Review: SGLT2 Inhibitors for Type 2 Diabetes",
    "pico": {
      "population": "adults with type 2 diabetes",
      "intervention": "SGLT2 inhibitors",
      "comparator": "placebo or standard care",
      "outcomes": ["HbA1c reduction", "cardiovascular events"],
      "study_types": ["rct"]
    },
    "inclusion_criteria": {"language": ["English"], "min_year": 2015},
    "exclusion_criteria": {"study_types": ["case report", "editorial"]},
    "search_strategy": "(diabetes mellitus, type 2[MeSH Terms]) AND (sodium-glucose transporter 2 inhibitors[MeSH Terms])"
  }'
```

### 2. Test Search Execution
```bash
curl -X POST http://localhost:5678/webhook/slr-search-execution \
  -H "Content-Type: application/json" \
  -d '{
    "review_id": "00000000-0000-0000-0000-000000000001",
    "search_query": "(diabetes mellitus, type 2[MeSH Terms]) AND (sodium-glucose transporter 2 inhibitors[MeSH Terms])",
    "max_results": 100
  }'
```

### 3. Test Screening (requires documents in database)
```bash
curl -X POST http://localhost:5678/webhook/slr-screening-batch \
  -H "Content-Type: application/json" \
  -d '{
    "review_id": "00000000-0000-0000-0000-000000000001",
    "batch_size": 10
  }'
```

### 4. Quick PubMed Test (creates test review automatically)
```bash
curl -X POST http://localhost:5678/webhook/slr-test-pubmed-search \
  -H "Content-Type: application/json" \
  -d '{}'
```

## Alpha Version Status

The current workflows implement Phase 1-4 functionality:

✅ **Implemented (Phase 1-2)**:
- Main coordinator workflow structure
- Protocol setup and storage
- Checkpoint/state management structure
- Human review wait nodes

✅ **Implemented (Phase 3)**:
- PubMed search execution (ESearch + EFetch with history server)
- Complete PubMed XML parsing and document metadata extraction
- Structured data extraction (title, authors, abstract, DOI, PMID, study type)
- Batch processing for large result sets
- Rate limit handling with automatic retry
- Document persistence with duplicate detection (upsert on PMID)
- PRISMA flow tracking updates
- Test workflow for quick validation
- Credentials configuration documentation

✅ **Implemented (Phase 4)**:
- AI-powered title/abstract screening with Ollama LLM
- PICO-based screening prompt following Cochrane standards
- Structured JSON output parsing for decisions
- Confidence score calculation for decision routing
- Low-confidence routing to human review
- Rate limiting between LLM calls
- Error handling for LLM failures
- Audit logging for all screening decisions
- Statistics aggregation

🚧 **Pending (Phase 5+)**:
- Duplicate detection and deduplication
- Full-text PDF retrieval
- Data extraction workflows
- Risk of bias assessment
- GRADE assessment
- Synthesis and reporting workflows

## Troubleshooting

### Workflow Import Errors
- Ensure n8n is running: `docker compose ps`
- Check n8n logs: `docker compose logs n8n`
- Verify JSON syntax is valid

### Credential Errors
- Verify PostgreSQL credentials in n8n settings
- Test database connection from n8n
- Check `.env` file has correct values

### Ollama Integration Issues
- Verify Ollama is running: `docker compose ps ollama`
- Check model is pulled: `docker compose exec ollama ollama list`
- Test Ollama API: `curl http://localhost:11434/api/version`

### PubMed API Issues
- Verify API key is valid and not rate-limited
- Check CONTACT_EMAIL is set correctly
- Review error responses in workflow execution logs

## Next Steps

1. **Import all workflows** into n8n
2. **Configure credentials** for PostgreSQL and Ollama
3. **Set environment variables** for workflow IDs
4. **Test each workflow** individually
5. **Test end-to-end flow** via main coordinator
6. **Implement Phase 3** tasks (PubMed XML parsing, document storage)

## References

- [n8n Documentation](https://docs.n8n.io/)
- [PubMed E-utilities API](https://www.ncbi.nlm.nih.gov/books/NBK25501/)
- [Ollama API Documentation](https://ollama.ai/docs/api)
- [Full Technical Specification](../Specifications.md)
- [Alpha Test Tasks](../ALPHA_TEST_TASKS.md)
