# Coding Standards

## Naming Conventions
- **Files**: snake_case (`user_service.py`, `auth_router.py`)
- **Classes**: PascalCase (`UserService`, `CommunicationItem`, `AuthRouter`)
- **Functions/Variables**: snake_case (`get_current_user`, `user_id`, `is_authenticated`)
- **Constants**: UPPER_SNAKE_CASE (`DATABASE_URL`, `JWT_SECRET_KEY`, `MAX_RETRY_ATTEMPTS`)
- **Database Tables**: snake_case plural (`users`, `communication_items`, `api_keys`)
- **API Routes**: kebab-case (`/api/v1/auth/login`, `/api/v1/redaction-profiles`)
- **Private Methods**: Prefix with single underscore (`_validate_token`, `_hash_password`)

## Python Code Style
- **Type Hints**: Required for all function parameters and return types
- **Docstrings**: Google-style docstrings for all public functions and classes
- **Line Length**: Max 100 characters (or 120 if team prefers)
- **Imports**: Grouped (stdlib, third-party, local) with blank lines between groups
- **Formatting**: Use `black` formatter or follow PEP 8
- **Linting**: Use `ruff` or `pylint` for code quality checks

## Code Organization
- **Layered Architecture**: Follow repository → service → router pattern
- **Single Responsibility**: Each function/class should have one clear purpose
- **DRY Principle**: Don't repeat yourself - extract common logic to utilities
- **Dependency Injection**: Use FastAPI's dependency injection for shared dependencies

## Error Handling
- **Exception Types**: Use specific exception types, not bare `Exception`
- **Error Responses**: Return structured error responses with appropriate HTTP status codes
- **Logging**: Log errors with context (user_id, tenant_id, request_id) before raising
- **Validation**: Use Pydantic validators for input validation, raise `ValueError` for invalid data

## Async/Await Patterns
- **Async Functions**: Use `async def` for I/O operations (database, API calls)
- **Await**: Always await async function calls
- **Concurrency**: Use `asyncio.gather()` for parallel operations when appropriate
- **Database**: Use async SQLAlchemy sessions for database operations

## Logging Standards
- **Log Levels**: Use appropriate levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- **Structured Logging**: Include context (user_id, tenant_id, request_id, operation)
- **Sensitive Data**: Never log passwords, tokens, or PII in plain text
- **Format**: Use structured logging format for easier parsing

## Database Standards
- **Primary Keys**: Use UUID primary keys for all tables
- **Timestamps**: Include `created_at` and `updated_at` timestamps on all tables
- **Foreign Keys**: Explicit foreign keys with appropriate cascade rules
- **Indexes**: Add indexes on frequently queried columns (foreign keys, tenant_id, etc.)
- **Migrations**: All schema changes must go through Alembic migrations

## API Standards
- **Schemas**: Pydantic models for all API request/response validation
- **Versioning**: Use `/api/v1/` prefix for all endpoints
- **Status Codes**: Use appropriate HTTP status codes (200, 201, 400, 401, 403, 404, 500)
- **Response Format**: Consistent JSON response structure
- **Documentation**: All endpoints must have OpenAPI/Swagger documentation
