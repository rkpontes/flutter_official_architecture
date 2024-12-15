# Flutter Official Architecture

## Overview
This case study explores how to structure the architecture of a Flutter application, focusing on separation of concerns, state management, and unidirectional data flow. It presents strategies for building a scalable, testable, and extensible application, illustrating how to apply general architectural principles in the context of Flutter.

The guide covers:

- Separation of concerns: The clear division between layers, such as UI logic and business logic, using a layered architecture.

- State management: How to ensure predictable and organized data flow through immutable state.

- Single source of truth: Centralized data structures to synchronize the UI and backend.

- Extensibility and testability: Building a modular design that makes it easy to add functionality and comprehensive testing.

The concepts are contextualized through a practical example that demonstrates how these practices help address common challenges such as modularity, reusability, and code consistency.

The goal is to provide insights on how to improve the development experience and robustness of the application, aligning with best practices recommended by the Flutter community and the mobile application development industry.

[More details](https://docs.flutter.dev/app-architecture/case-study)

---

## Project Structure

### `lib/`
The `lib` folder is the core of the project, divided into several key directories:

#### 1. `data/`
Responsible for data handling, including fetching data from APIs or other sources and providing it to the domain layer.

- **`repositories/`**: Contains implementations of repository interfaces defined in the domain layer.
- **`services/`**: Holds external services such as API clients or local storage interfaces.

#### 2. `domain/`
Encapsulates the core business logic of the application.

- **`models/`**: Defines the entities and data models used across the domain.
- **`use_cases/`**: Contains classes that implement specific business rules or operations.

#### 3. `routing/`
Manages the navigation system and route definitions.

- **`router.dart`**: Configures the routing logic using `go_router`.
- **`routes.dart`**: Defines named routes and their parameters.

#### 4. `ui/`
Houses all presentation-related code, including views, widgets, and state management.

- **`home/view_models/`**: Contains classes that manage the state and logic for the home screen.
- **`home/widgets/`**: Includes reusable UI components for the home screen.

#### 5. `utils/`
Contains utility classes and helper functions used throughout the application.

- **`command.dart`**: Provides a command pattern implementation.
- **`exceptions.dart`**: Defines custom exception classes.
- **`result.dart`**: Implements a result pattern for handling operations with success or failure outcomes.

### Other Key Files

- **`injector.config.dart`**: Configuration for dependency injection using `get_it`.
- **`main_production.dart`**: The entry point for production builds.
- **`main.dart`**: The default entry point for development and testing.

---

## Dependencies

### Core Dependencies
- `flutter`: The Flutter SDK.
- `flutter_localizations`: For supporting internationalization (i18n).
- `go_router`: Simplifies navigation and routing.
- `intl`: Provides tools for internationalization and localization.
- `logging`: Enables structured logging.
- `get_it`: A lightweight service locator for dependency injection.
- `shared_preferences`: For storing key-value pairs locally.
- `dio`: A powerful HTTP client for handling API requests.
- `import_sorter`: Organizes imports for better readability.

### Dev Dependencies
- `flutter_test`: For writing and running unit tests.
- `integration_test`: For end-to-end testing.
- `flutter_lints`: Ensures adherence to Flutter's best practices.

---

## Getting Started

### Prerequisites
- Flutter SDK >= 3.4.1 < 4.0.0

### Run the Project
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Run the app:
   ```bash
   flutter run
   ```

### Run Tests
To execute unit and integration tests, use:
```bash
flutter test
```

---

## Contributing
We welcome contributions to this project. Please follow these guidelines:
1. Fork the repository and create a feature branch.
2. Make your changes and write tests if applicable.
3. Open a pull request with a clear description of your changes.

---

## License
This project is licensed under the MIT License.

