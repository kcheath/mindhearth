# Mindhearth

AI-powered mental health support app built with Flutter using Clean Architecture principles.

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles as outlined in the Flutter Clean Architecture book, with a focus on:

- **Separation of Concerns**: Clear boundaries between layers
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Testability**: Each layer can be tested independently
- **Scalability**: Easy to add new features and modify existing ones

### Project Structure

```
lib/
├── app/                    # Application layer
│   ├── router/            # Navigation configuration
│   ├── themes/            # App theming
│   └── providers/         # Riverpod providers
├── core/                  # Shared layer
│   ├── models/            # Domain models
│   ├── services/          # Core services (API, storage)
│   ├── utils/             # Utility functions
│   └── constants/         # App constants
└── features/              # Feature modules
    ├── auth/              # Authentication
    ├── onboarding/        # User onboarding
    ├── safetycode/        # Safety code management
    ├── chat/              # AI chat interface
    ├── sessions/          # Session history
    ├── journal/           # Journal entries
    ├── documents/         # Document management
    ├── reports/           # Reports and analytics
    └── settings/          # App settings
```

## 🎯 State Management Strategy

### Riverpod Integration

We use **Riverpod** as our state management solution with the following patterns:

- **@riverpod** annotations for code generation
- **Provider** for dependency injection
- **NotifierProvider** for state management
- **ConsumerWidget** and **HookConsumerWidget** for UI integration

### Key Providers

- `authNotifierProvider`: Manages authentication state
- `apiServiceProvider`: Provides API service instance
- `routerProvider`: Handles navigation with auth guards

### State Flow

1. **UI Layer**: Uses `ConsumerWidget` to watch providers
2. **State Layer**: Riverpod providers manage state
3. **Service Layer**: API calls and data persistence
4. **Model Layer**: Freezed models for type safety

## 🧭 Navigation Strategy

### GoRouter Implementation

We use **GoRouter** for navigation with the following features:

- **Authentication Guards**: Automatic redirects based on auth state
- **Deep Linking**: Support for direct URL navigation
- **Nested Routes**: Organized route structure
- **Route Guards**: Conditional navigation based on user state

### Route Structure

```
/login              # Authentication
/onboarding         # User onboarding
/                   # Main chat interface
/sessions           # Session history
/journal            # Journal entries
/documents          # Document management
/reports            # Reports and analytics
/settings           # App settings
/safety-code        # Safety code management
```

### Navigation Guards

- **Unauthenticated users**: Redirected to `/login`
- **Authenticated but not onboarded**: Redirected to `/onboarding`
- **Fully authenticated users**: Access to all routes

## 🔧 Development Setup

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.8.1 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mindhearth
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Code Generation

The project uses several code generation tools:

- **build_runner**: For generating freezed models and Riverpod providers
- **json_serializable**: For JSON serialization
- **freezed**: For immutable data classes
- **riverpod_generator**: For Riverpod provider generation

Run code generation after making changes to models or providers:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 🎨 Design System

### Material 3

The app uses **Material 3** design system with:

- **Dynamic Color**: Adaptive theming based on system colors
- **Custom Color Scheme**: Purple-based primary colors
- **Typography**: Inter font family
- **Components**: Material 3 components throughout

### Theme Configuration

- **Light Theme**: Clean, accessible design
- **Dark Theme**: Dark mode support
- **System Theme**: Automatic theme switching

## 🔌 Backend Integration

### API Service

The app integrates with the **Tsukiyo backend** using:

- **Dio**: HTTP client for API calls
- **REST API**: Standard REST endpoints
- **JWT Authentication**: Bearer token authentication
- **Secure Storage**: Token persistence

### API Endpoints

- `POST /api/auth/login`: User authentication
- `GET /api/health`: Health check
- `POST /api/chat`: AI chat interface

## 🧪 Testing Strategy

### Test Structure

```
test/
├── unit/              # Unit tests
├── widget/            # Widget tests
└── integration/       # Integration tests
```

### Testing Tools

- **flutter_test**: Core testing framework
- **mockito**: Mocking for dependencies
- **riverpod_test**: Testing Riverpod providers

## 📱 Features

### Current Features

- ✅ User authentication
- ✅ Navigation with auth guards
- ✅ Material 3 theming
- ✅ Clean architecture structure
- ✅ Riverpod state management

### Planned Features

- 🔄 AI chat interface
- 🔄 Session management
- 🔄 Journal entries
- 🔄 Document upload
- 🔄 Safety code system
- 🔄 Reports and analytics
- 🔄 User onboarding flow

## 🚀 Deployment

### Build Commands

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📄 License

This project is proprietary and confidential.

## 🤝 Contributing

1. Follow the clean architecture principles
2. Use Riverpod for state management
3. Write tests for new features
4. Follow the existing code style
5. Update documentation as needed

## 📞 Support

For support and questions, please contact the development team.
