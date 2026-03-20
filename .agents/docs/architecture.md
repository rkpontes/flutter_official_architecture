# Architecture Documentation

## Clean Architecture Overview

This Flutter project follows clean architecture principles:

### Layers
- **UI Layer**: Widgets, view models, presentation logic
- **Domain Layer**: Business logic, use cases, entities
- **Data Layer**: Repositories, services, external data sources

### Data Flow
UI → Domain → Data (unidirectional)

### Key Patterns
- Repository pattern for data access
- Dependency injection for testability
- Use cases for business operations
- Immutable state management

## Benefits
- Testable code
- Maintainable structure
- Scalable architecture
- Clear separation of concerns