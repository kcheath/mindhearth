#!/bin/bash

# 🧪 Backend Integration Test Setup Script
# This script sets up and runs comprehensive backend integration tests

set -e  # Exit on any error

echo "🧪 Setting up backend integration tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
check_flutter() {
    print_status "Checking Flutter installation..."
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed. Please install Flutter first."
        exit 1
    fi
    print_success "Flutter is installed"
}

# Check if backend is running
check_backend() {
    print_status "Checking backend connectivity..."
    
    # Test backend health endpoint
    if curl -f -s http://3.150.176.19:8080/api/health > /dev/null; then
        print_success "Backend is running and accessible"
    else
        print_error "Backend is not accessible at http://3.150.176.19:8080/api/health"
        print_warning "Please ensure the backend is running before running tests"
        exit 1
    fi
}

# Check Flutter dependencies
check_dependencies() {
    print_status "Checking Flutter dependencies..."
    
    if [ ! -f "pubspec.yaml" ]; then
        print_error "pubspec.yaml not found. Please run this script from the Flutter project root."
        exit 1
    fi
    
    print_status "Running flutter pub get..."
    flutter pub get
    
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
}

# Run Flutter tests
run_tests() {
    print_status "Running Flutter integration tests..."
    
    # Create test directory if it doesn't exist
    mkdir -p test/integration
    
    # Run all integration tests
    flutter test test/integration/ --reporter=expanded
    
    if [ $? -eq 0 ]; then
        print_success "All integration tests passed! 🎉"
    else
        print_error "Some tests failed. Please check the output above."
        exit 1
    fi
}

# Run specific test categories
run_api_tests() {
    print_status "Running API endpoint tests..."
    flutter test test/integration/api_endpoints_test.dart --reporter=expanded
}

run_auth_tests() {
    print_status "Running authentication flow tests..."
    flutter test test/integration/auth_flow_test.dart --reporter=expanded
}

run_session_tests() {
    print_status "Running session management tests..."
    flutter test test/integration/session_management_test.dart --reporter=expanded
}

# Clean up test data
cleanup_tests() {
    print_status "Cleaning up test data..."
    
    # This would typically involve:
    # - Clearing test sessions
    # - Clearing test messages
    # - Clearing test user data
    
    print_success "Test cleanup completed"
}

# Generate test report
generate_report() {
    print_status "Generating test report..."
    
    # Create test report directory
    mkdir -p test_reports
    
    # Run tests with coverage
    flutter test test/integration/ --coverage --reporter=json > test_reports/integration_tests.json
    
    print_success "Test report generated in test_reports/"
}

# Main execution
main() {
    echo "🚀 Starting Backend Integration Test Setup"
    echo "=========================================="
    
    # Parse command line arguments
    case "${1:-all}" in
        "api")
            check_flutter
            check_backend
            check_dependencies
            run_api_tests
            ;;
        "auth")
            check_flutter
            check_backend
            check_dependencies
            run_auth_tests
            ;;
        "sessions")
            check_flutter
            check_backend
            check_dependencies
            run_session_tests
            ;;
        "all")
            check_flutter
            check_backend
            check_dependencies
            run_tests
            ;;
        "cleanup")
            cleanup_tests
            ;;
        "report")
            check_flutter
            check_backend
            check_dependencies
            generate_report
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  all       - Run all integration tests (default)"
            echo "  api       - Run API endpoint tests only"
            echo "  auth      - Run authentication flow tests only"
            echo "  sessions  - Run session management tests only"
            echo "  cleanup   - Clean up test data"
            echo "  report    - Generate test report with coverage"
            echo "  help      - Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0              # Run all tests"
            echo "  $0 api          # Run API tests only"
            echo "  $0 auth         # Run auth tests only"
            echo "  $0 sessions     # Run session tests only"
            echo "  $0 cleanup      # Clean up test data"
            echo "  $0 report       # Generate test report"
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
    
    echo ""
    echo "✅ Backend Integration Test Setup Complete!"
}

# Run main function with all arguments
main "$@"
