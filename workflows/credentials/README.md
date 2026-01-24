# n8n Credentials Configuration for CritLit

This directory contains documentation for configuring n8n credentials used by the CritLit SLR Pipeline workflows.

## Required Credentials

### 1. PostgreSQL (SLR Database)

**Credential Type**: PostgreSQL

**Configuration**:
| Field | Value | Description |
|-------|-------|-------------|
| Host | `postgres` | Docker service name (or `localhost` for external access) |
| Database | `slr_database` | Database name |
| User | `slr_user` | Database user |
| Password | *from .env* | Value of `POSTGRES_PASSWORD` from your `.env` file |
| Port | `5432` | Default PostgreSQL port |
| SSL | `Disable` | Not required within Docker network |

**Credential ID**: Use `postgres-slr-database` for consistency with workflow templates.

### 2. PubMed API Credentials

**Credential Type**: HTTP Query Auth

**Configuration**:
| Field | Value | Description |
|-------|-------|-------------|
| Name | `api_key` | Query parameter name for NCBI API key |
| Value | *from .env* | Your NCBI API key (obtained from https://www.ncbi.nlm.nih.gov/account/settings/) |

**Credential ID**: Use `pubmed-api-credentials` for consistency with workflow templates.

**Note**: The PubMed API key is optional but highly recommended. Without an API key, you are limited to 3 requests per second. With an API key, you can make up to 10 requests per second.

#### Obtaining a PubMed API Key

1. Create an NCBI account at https://www.ncbi.nlm.nih.gov/account/
2. Go to Settings > API Key Management
3. Click "Create API Key"
4. Copy the key and add it to your `.env` file as `PUBMED_API_KEY`

### 3. Ollama API (Optional)

**Credential Type**: HTTP Header Auth

**Configuration**:
| Field | Value | Description |
|-------|-------|-------------|
| Name | `Authorization` | Header name (if authentication is enabled) |
| Value | `Bearer <token>` | Authentication token (if configured) |

**Note**: By default, Ollama does not require authentication. Only configure this if you have enabled authentication on your Ollama instance.

**Credential ID**: Use `ollama-api-credentials` for consistency with workflow templates.

## Environment Variables

The following environment variables should be configured in n8n for the workflows to function correctly:

| Variable | Description | Example |
|----------|-------------|---------|
| `PUBMED_API_KEY` | NCBI API key for PubMed | `your_ncbi_api_key` |
| `CONTACT_EMAIL` | Email address for NCBI API requests | `researcher@example.edu` |
| `OLLAMA_BASE_URL` | Base URL for Ollama API | `http://ollama:11434` |
| `OLLAMA_SCREENING_MODEL` | Ollama model for screening | `llama3.1:8b` |
| `SCREENING_BATCH_SIZE` | Documents per screening batch | `50` |
| `SCREENING_CONFIDENCE_THRESHOLD` | Confidence threshold for human review | `0.85` |

### Setting Environment Variables in n8n

1. Open n8n web interface at http://localhost:5678
2. Click on the user icon in the bottom left
3. Select "Settings"
4. Navigate to "Environment Variables" or configure via Docker environment

## Creating Credentials in n8n

1. Open n8n web interface at http://localhost:5678
2. Click on "Credentials" in the left sidebar
3. Click "Add Credential"
4. Select the credential type (e.g., "PostgreSQL")
5. Fill in the configuration fields as documented above
6. Click "Save"
7. Note the credential ID for use in workflow configurations

## Security Notes

- **Never commit credentials** to version control
- Store all sensitive values in the `.env` file
- Use n8n's built-in credential encryption (ensure `N8N_ENCRYPTION_KEY` is set)
- Rotate API keys periodically
- Use separate API keys for development and production

## Troubleshooting

### PostgreSQL Connection Failed
- Verify the `postgres` service is running: `docker compose ps postgres`
- Check PostgreSQL logs: `docker compose logs postgres`
- Test connection: `docker compose exec postgres pg_isready`

### PubMed API Rate Limited
- Ensure your API key is correctly configured
- Verify the rate limit wait nodes are active in workflows
- Check if NCBI is experiencing issues: https://www.ncbi.nlm.nih.gov/status

### Ollama Connection Failed
- Verify Ollama service is running: `docker compose ps ollama`
- Check if model is pulled: `docker compose exec ollama ollama list`
- Test API: `curl http://localhost:11434/api/version`
