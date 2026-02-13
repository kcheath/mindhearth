# Project Overview

## Platform Description
Fortessa is a multi-tenant SaaS platform providing AI-powered communication and document management. MindHearth is a Flutter mobile application built on the Fortessa platform.

## Technology Stack

### Backend
- **Framework**: FastAPI 0.104.1 with Python 3.10+
- **Architecture**: Hybrid - Monolithic main service (525+ endpoints) with external microservices
- **Database**: PostgreSQL 15+ with PgVector extension for vector embeddings
- **Cache**: Redis 7 for sessions, rate limiting, and caching
- **ORM**: SQLAlchemy 2.0.23 with Alembic migrations
- **Background Tasks**: Celery with Redis broker

### Active Microservices
- **MCP Server (3002)**: Model Context Protocol for AI tooling
- **RAG Service (3003)**: Vector search and Retrieval-Augmented Generation
- **Security Service (3005)**: Authentication and security operations

### Frontend
- **Framework**: Flutter (Dart)
- **UI Pattern**: Chat-first interface with white-label configuration support
- **State Management**: Provider/Riverpod pattern
- **API Connection**: `http://3.150.176.19:3012/api/v1`

## Deployment
- **Environment**: REMOTE SERVER ONLY at 3.150.176.19:3012
- **Local Development**: No local Docker development (connect to remote server)
- **Deployment Process**: Manual via SSH to remote server

## Core Principles (Non-Negotiables)
1. **Tenant Isolation**: Database-level tenant isolation is mandatory and non-negotiable
2. **Testing**: All code changes must include appropriate tests
3. **Documentation**: PROJECT_CONTEXT.md must be updated after significant changes
4. **Security**: All security principles must be followed (see security_principles.md)
