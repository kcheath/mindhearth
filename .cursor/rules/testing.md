# Testing Standards

## Python Backend Testing

### Framework & Configuration
- **Framework**: pytest
- **Coverage Target**: ≥85% coverage for changed files
- **Coverage Path**: `src` (not `app`)
- **Test Discovery**: Automatic discovery of `test_*.py` and `*_test.py` files

### Test Commands
- **Unit Tests**: `pytest tests/unit/ -v`
- **Integration Tests**: `pytest tests/integration/ -v`
- **E2E Tests**: `pytest tests/e2e/ -v`
- **All Tests**: `pytest --cov=src --cov-report=term-missing`
- **With Markers**: `pytest -m billing -v`, `pytest -m "not slow" -v`
- **Specific File**: `pytest tests/unit/test_user_service.py -v`

### Test Structure
```
tests/
  ├── unit/           # Fast, isolated unit tests
  ├── integration/    # Integration tests with database/API
  └── e2e/            # End-to-end tests
```

### Test Markers
Use pytest markers to categorize tests:
- `@pytest.mark.unit` - Unit tests
- `@pytest.mark.integration` - Integration tests
- `@pytest.mark.e2e` - End-to-end tests
- `@pytest.mark.slow` - Slow-running tests
- `@pytest.mark.real_openai` - Tests requiring real OpenAI API
- `@pytest.mark.billing` - Billing-related tests
- `@pytest.mark.rag` - RAG functionality tests
- `@pytest.mark.multitenant` - Multi-tenant tests

### Test Naming Conventions
- **Test Files**: `test_<module_name>.py` (e.g., `test_user_service.py`)
- **Test Functions**: `test_<functionality>_<expected_behavior>` (e.g., `test_create_user_success`)
- **Test Classes**: `Test<ClassName>` (e.g., `TestUserService`)

### Test Best Practices
- **Arrange-Act-Assert**: Follow AAA pattern in tests
- **Fixtures**: Use pytest fixtures for test data and setup
- **Mocking**: Mock external dependencies (APIs, databases, services)
- **Isolation**: Tests should be independent and runnable in any order
- **Fast**: Unit tests should be fast (<100ms each)
- **Clear**: Test names should clearly describe what is being tested

### Mocking Patterns
- **External APIs**: Mock HTTP requests using `responses` or `httpx`
- **Database**: Use test database or in-memory SQLite for unit tests
- **Services**: Mock service dependencies using `unittest.mock`
- **Time**: Mock time-dependent operations for deterministic tests

### Test Data Management
- **Fixtures**: Use pytest fixtures for reusable test data
- **Factories**: Use factory pattern for creating test objects
- **Cleanup**: Ensure test data is cleaned up after tests (use fixtures with teardown)

## Flutter Frontend Testing

### Framework
- **Framework**: `flutter test` (built-in testing framework)
- **Coverage Target**: ≥80% code coverage

### Test Types
- **Unit Tests**: Test business logic, services, utilities
- **Widget Tests**: Test individual widgets and UI components
- **Integration Tests**: Test complete user flows

### Test Commands
- **All Tests**: `flutter test`
- **With Coverage**: `flutter test --coverage`
- **Specific File**: `flutter test test/user_service_test.dart`

### Test Structure
```
test/
  ├── unit/           # Unit tests for business logic
  ├── widget/         # Widget tests
  └── integration/   # Integration tests
```

### Flutter Test Best Practices
- **Golden Tests**: Use golden tests for UI regression testing
- **Mocking**: Mock API calls and external dependencies
- **Widget Testing**: Test widgets in isolation
- **Integration Testing**: Test complete user flows
- **Test Data**: Use test fixtures and factories for consistent test data
