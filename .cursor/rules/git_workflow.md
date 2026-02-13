# Git Workflow

## Branch Naming Convention
- `feature/<description>` - New features (e.g., `feature/user-profile-page`)
- `fix/<description>` - Bug fixes (e.g., `fix/auth-token-expiration`)
- `hotfix/<description>` - Critical production fixes (e.g., `hotfix/security-patch`)
- `chore/<description>` - Maintenance tasks (e.g., `chore/update-dependencies`)
- Use kebab-case for branch names

## Branch Strategy
- **Main Branch**: `development` (protected, requires PR)
- **Production Branch**: `main` or `production` (protected, only via releases)
- **Feature Branches**: Created from `development`, merged back via PR
- **Hotfix Branches**: Can be created from production branch if needed

## Commit Messages

### Format
Use present tense, imperative mood:
- ✅ "Add user authentication endpoint"
- ✅ "Fix token refresh logic"
- ❌ "Added user authentication endpoint"
- ❌ "Fixes token refresh logic"

### Structure
```
<type>: <subject>

<body (optional)>

<footer (optional)>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```
feat: Add user profile API endpoint

Implements GET /api/v1/users/profile endpoint with authentication.
Includes unit and integration tests.

Closes #123
```

## Pull Requests

### Requirements
- **All changes** must go through PRs (no direct commits to `development`)
- **CI Checks**: All PRs must pass CI checks (tests, linting, security scans)
- **Code Review**: At least one approval required before merging
- **Description**: PR description should explain what, why, and how

### PR Template
PRs should include:
- Description of changes
- Related issue/ticket number
- Testing performed
- Screenshots (for UI changes)
- Breaking changes (if any)

### Review Guidelines
- Reviewers should check code quality, tests, and documentation
- Request changes if code doesn't meet standards
- Approve when code is ready to merge
- Be constructive and respectful in feedback

## Pre-Commit Checklist
Before committing, ensure:
1. ✅ Run tests: `pytest` (backend) or `flutter test` (frontend)
2. ✅ Run linting: `ruff check` or `dart analyze`
3. ✅ Code formatting: `black .` or `dart format`
4. ✅ No debug code or console.logs left in
5. ✅ Documentation updated (PROJECT_CONTEXT.md for significant changes)

## Merge Strategy
- **Squash and Merge**: Preferred for feature branches (clean history)
- **Rebase**: Use for keeping feature branches up to date
- **Merge Commit**: Use for hotfixes or when preserving branch history

## Deployment Workflow

### Backend Changes
1. Commit and push to `development` branch
2. Create PR and get approval
3. Merge to `development`
4. SSH to remote server (3.150.176.19)
5. Pull latest changes
6. Rebuild container: `docker-compose -f docker/docker-compose.yml build main-backend-service`
7. Restart service: `docker-compose -f docker/docker-compose.yml up -d main-backend-service`
8. Run migrations if needed: `alembic upgrade head`
9. Verify health: `curl http://3.150.176.19:3012/api/health`

### Schema Changes
- Create Alembic migration: `alembic revision --autogenerate -m "description"`
- Review migration file carefully
- Test migration on remote server database
- Deploy migration as part of deployment process

### API Changes
- Rebuild container on remote server after router changes
- Update API documentation if endpoints change
- Consider versioning for breaking changes
