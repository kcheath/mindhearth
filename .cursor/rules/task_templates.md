# Task Templates

## Adding a New API Endpoint (Backend)

### Steps
1. **Create Pydantic Schema**: Define request/response schemas in `src/main_backend/schemas/`
   - Include validation rules
   - Add docstrings for OpenAPI documentation
   
2. **Database Model** (if needed): Add SQLAlchemy model in `src/main_backend/models/`
   - Include UUID primary key
   - Add timestamps (created_at, updated_at)
   - Define relationships and foreign keys
   
3. **Repository Layer**: Create repository in `src/main_backend/repositories/`
   - Implement data access methods
   - Handle database transactions
   
4. **Service Layer**: Create service in `src/main_backend/services/`
   - Implement business logic
   - Call repository methods
   - Handle errors and validation
   
5. **Router**: Add route handler in `src/main_backend/api/v1/routers/`
   - Define endpoint with proper HTTP method
   - Add authentication/authorization dependencies
   - Call service methods
   - Return appropriate responses
   
6. **Migration** (if schema change): Create Alembic migration
   - `alembic revision --autogenerate -m "add user_profile table"`
   - Review migration file carefully
   
7. **Tests**: Add comprehensive tests in `tests/`
   - Unit tests for service and repository
   - Integration tests for API endpoint
   - Test error cases and edge cases
   
8. **Documentation**: Update PROJECT_CONTEXT.md
   - Add endpoint to API Index
   - Update Models Index if new model added
   
9. **Deployment**: Deploy to remote server
   - Follow Remote Server Deployment Workflow
   - Rebuild container at 3.150.176.19:3012

## Database Schema Change

### Steps
1. **Update Model**: Update SQLAlchemy model in `src/main_backend/models/`
   - Add/modify columns, relationships, indexes
   
2. **Create Migration**: Generate Alembic migration
   - `alembic revision --autogenerate -m "description"`
   - Review generated migration file carefully
   - Verify column types, constraints, indexes
   
3. **Test Migration**: Test migration on remote server database
   - Test upgrade: `alembic upgrade head`
   - Test downgrade: `alembic downgrade -1` (if needed)
   - Verify data integrity
   
4. **Update Documentation**: Update PROJECT_CONTEXT.md
   - Update Models Index
   - Document schema changes
   
5. **Deploy Migration**: Deploy to production
   - `docker-compose -f docker/docker-compose.yml exec main-backend-service alembic upgrade head`
   - Monitor for errors
   - Verify application functionality

## Adding a New Service/Microservice

### Steps
1. **Verify Need**: Check if service is needed
   - Review active vs legacy services in PROJECT_CONTEXT.md
   - Consider if functionality fits in existing service
   
2. **Create Structure**: Create service directory in `src/microservices/`
   - Follow existing service patterns
   - Include main service file, routers, models, etc.
   
3. **Docker Configuration**: Add Docker configuration
   - Create Dockerfile
   - Configure service-specific settings
   
4. **Update Docker Compose**: Update `docker/docker-compose.yml`
   - Add service definition
   - Configure networking and dependencies
   
5. **Documentation**: Document in PROJECT_CONTEXT.md
   - Add to Architecture section
   - Document service purpose and endpoints
   
6. **Health Check**: Add health check endpoint
   - `/health` endpoint for monitoring
   - Return service status
   
7. **Deploy**: Deploy to remote server at 3.150.176.19
   - Build and start service
   - Verify health check
   - Update service discovery if needed

## Adding a New Flutter Feature

### Steps
1. **Create Feature Module**: Create feature directory in `lib/features/<feature_name>/`
   - Models, providers, services, widgets
   
2. **API Integration**: Add API client methods
   - Update API client in `lib/core/api/`
   - Add request/response models
   
3. **State Management**: Create providers/services
   - Business logic in services
   - State management in providers
   
4. **UI Components**: Create widgets
   - Follow design patterns guide
   - Use consistent styling
   
5. **Navigation**: Add routes
   - Update route definitions
   - Handle navigation parameters
   
6. **Tests**: Add tests
   - Unit tests for services/providers
   - Widget tests for UI components
   - Integration tests for user flows
   
7. **Documentation**: Update project documentation
   - Document new feature
   - Update API documentation if needed

## Remote Server Deployment Workflow

### Steps
1. **Local Changes**: Make and test changes locally
   - Run tests: `pytest` or `flutter test`
   - Verify functionality
   
2. **Commit & Push**: Commit and push to `development` branch
   - Follow Git Workflow guidelines
   - Create PR and get approval
   - Merge to development
   
3. **SSH to Server**: Connect to remote server
   - `ssh user@3.150.176.19`
   
4. **Pull Changes**: Pull latest code
   - Navigate to project directory
   - `git pull origin development`
   
5. **Rebuild Container**: Rebuild Docker container
   - `docker-compose -f docker/docker-compose.yml build main-backend-service`
   
6. **Restart Service**: Restart the service
   - `docker-compose -f docker/docker-compose.yml up -d main-backend-service`
   
7. **Run Migrations** (if needed): Apply database migrations
   - `docker-compose -f docker/docker-compose.yml exec main-backend-service alembic upgrade head`
   
8. **Verify Health**: Check service health
   - `curl http://3.150.176.19:3012/api/health`
   - Check logs: `docker-compose -f docker/docker-compose.yml logs -f main-backend-service`
   
9. **Monitor**: Monitor for errors
   - Watch logs for first few minutes
   - Verify critical endpoints are working
