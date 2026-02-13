# Backend Architecture

## Framework & Language
- **Framework**: FastAPI 0.104.1
- **Python Version**: 3.10+
- **Architecture Pattern**: Hybrid - Monolithic main service with external microservices

## Service Architecture

### Main Service
- **Port**: 3012
- **Type**: Monolithic service with 525+ endpoints
- **Deployment**: REMOTE SERVER ONLY at 3.150.176.19:3012
- **Local Development**: No local Docker - connect to remote server

### Active Microservices
- **MCP Server (3002)**: Model Context Protocol for AI tooling and integrations
- **RAG Service (3003)**: Vector search and Retrieval-Augmented Generation functionality
- **Security Service (3005)**: Authentication, authorization, and security operations

### Service Communication
- Main backend depends on MCP (3002) and RAG (3003) services
- Inter-service communication via HTTP/REST APIs
- Service discovery and health checks required

## Data Layer

### Database
- **Primary DB**: PostgreSQL 15+
- **ORM**: SQLAlchemy 2.0.23
- **Vector Extension**: PgVector for embeddings and RAG operations
- **Migrations**: Alembic for schema versioning
- **Connection Pooling**: Configured via SQLAlchemy engine

### Cache
- **Technology**: Redis 7
- **Use Cases**: 
  - Session storage
  - Rate limiting counters
  - General caching (TTL-based)
  - Celery task broker

## Authentication & Security
- **Auth Method**: JWT tokens with configurable expiration
- **Password Hashing**: bcrypt with appropriate cost factor
- **Token Storage**: Redis for session management
- **Multi-tenancy**: Tenant isolation at database level (non-negotiable)

## Background Processing
- **Task Queue**: Celery
- **Broker**: Redis
- **Use Cases**: Long-running tasks, scheduled jobs, async processing

## Directory Structure

Under `src/main_backend/`:
- `api/v1/routers/` - FastAPI route handlers (organized by domain)
- `core/` - Core middleware, dependencies, configuration, exceptions
- `models/` - SQLAlchemy database models
- `schemas/` - Pydantic request/response schemas
- `services/` - Business logic services (domain layer)
- `repositories/` - Data access layer (database operations)
- `utils/` - Utility functions, helpers, common code

## Error Handling Architecture
- **Exception Hierarchy**: Custom exceptions in `core/exceptions.py`
- **Error Middleware**: Global exception handler in `core/middleware.py`
- **Error Responses**: Structured JSON error responses with error codes
- **Logging**: All errors logged with full context before returning to client

## Logging & Monitoring
- **Logging Framework**: Python `logging` module with structured format
- **Log Levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL
- **Log Context**: Include request_id, user_id, tenant_id in all logs
- **Monitoring**: Health check endpoints for all services

## Environment Configuration
- **Config Management**: Environment variables via `pydantic-settings`
- **Secrets**: Never commit secrets - use environment variables or secret management
- **Environment Files**: `.env` for local development (gitignored)

## API Versioning
- **Current Version**: `/api/v1/`
- **Versioning Strategy**: URL path versioning
- **Breaking Changes**: Require new version (e.g., `/api/v2/`)

## Docker & Deployment
- **Docker Compose**: Use `docker/docker-compose.yml` for main backend service
- **Containerization**: All services containerized
- **Deployment**: Manual deployment via SSH to remote server
