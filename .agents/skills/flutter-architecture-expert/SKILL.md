---
name: flutter-architecture-expert
description: Architecture guidance for this Flutter project. Covers the actual layered structure used here: dependency injection with get_it in `lib/injector.dart`, startup readiness in `lib/main.dart`, service abstractions under `lib/data/services`, local and remote repository implementations under `lib/data/repositories`, use cases returning `Result` under `lib/domain/use_cases`, and UI/view-model integration with `Command` under `lib/ui`. Use when designing features, placing code in the correct layer, wiring dependencies, or extending this repository without breaking its architecture.
metadata:
  author: flutter-it
  version: "1.0"
---

# Flutter Architecture Expert - This Project's Layered Structure

**What**: Architecture guidance for the concrete structure in this repository. This app uses a layered approach with `data`, `domain`, `ui`, and centralized dependency injection via `get_it`.

## Architecture Summary

The current dependency flow is:

```text
ui -> view_models -> use_cases -> repositories -> services -> external systems
```

Domain models flow across layers, while implementation details stay in the layer that owns them.

## Project Structure

```text
lib/
  data/
    repositories/
      book/
        book_repository.dart
        book_repository_local.dart
        book_repository_remote.dart
    services/
      api_client/
        api_client.dart
        api_client_impl.dart
      local_storage/
        local_storage.dart
        local_storage_impl.dart
  domain/
    models/
      book/
        book.dart
    use_cases/
      book/
        add_book_usecase.dart
        delete_book_usecase.dart
        edit_book_usecase.dart
        get_book_usecase.dart
        list_books_usecase.dart
  ui/
    add_update/
    home/
    show/
  routing/
  utils/
  injector.dart
  main.dart
```

## CRITICAL RULES

- Keep dependency wiring centralized in `lib/injector.dart`
- `main.dart` must wait for async dependencies before `runApp()`
- UI must not call `Dio` or `SharedPreferences` directly
- UI should talk to view models, not repositories or services
- View models should coordinate use cases and expose UI-friendly state
- Use cases are the boundary between UI-facing orchestration and repository access
- Repositories decide where data comes from; services only wrap transport or persistence mechanisms
- Service implementations must stay behind their abstract contracts
- Exceptions from `data` should be converted into `Result` in use cases before the UI consumes them
- Flavor-specific behavior belongs in configuration and DI, not spread across widgets

## App Startup

Startup is explicit and dependency-driven:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Injector.configureDependencies(flavor: flavor);
  await Injector.getIt.isReady<SharedPreferences>();
  runApp(const MainApp());
}
```

This means:

- sync and async registrations happen in `Injector.configureDependencies`
- `SharedPreferences` is registered asynchronously
- the app waits for readiness before rendering

If a new startup dependency is async, keep that readiness explicit in `main.dart`.

## Dependency Injection

All registrations live in `lib/injector.dart`.

Current registration order:

1. config and flavor-dependent values
2. low-level services such as `Dio` and `SharedPreferences`
3. service abstractions such as `ApiClient` and `LocalStorage`
4. repositories
5. use cases
6. view models

Typical pattern:

```dart
getIt.registerLazySingleton<ApiClient>(
  () => ApiClientImpl(getIt.get<Dio>()),
);

getIt.registerLazySingleton<BookRepository>(
  () {
    if (flavor == Flavor.development) {
      return BookRepositoryLocal(getIt.get<LocalStorage>());
    }
    return BookRepositoryRemote(getIt.get<ApiClient>());
  },
);
```

Use `registerLazySingletonAsync` only when the dependency itself is async to construct.

## Flavor-Driven Composition

This project changes infrastructure by flavor:

- `Flavor.development` uses `BookRepositoryLocal`
- `Flavor.production` uses `BookRepositoryRemote`
- `baseUrl` is selected from environment variables in DI

This is an architectural rule, not a one-off detail. When adding a new feature with local and remote behavior, prefer switching implementations in DI rather than branching inside widgets or use cases.

## Layer Responsibilities

## Data Layer

The data layer owns transport, persistence, and infrastructure-specific errors.

### Services

Services wrap one external mechanism:

- `ApiClient` wraps HTTP access through `Dio`
- `LocalStorage` wraps `SharedPreferences`

Services should:

- expose a simple contract
- isolate plugin/package specifics
- return raw transport/persistence data needed by repositories
- throw service-specific exceptions such as `ApiClientException` or `LocalStorageException`

Services should not:

- contain UI logic
- select between local and remote data sources
- know about navigation or widget state

### Repositories

Repositories implement business-facing data access over one source.

In this project:

- `BookRepository` is the abstract contract
- `BookRepositoryLocal` uses `LocalStorage`
- `BookRepositoryRemote` uses `ApiClient`

Repositories should:

- convert raw maps/lists into domain models
- choose persistence/transport operations for the feature
- rethrow source-specific exceptions when they are already meaningful
- wrap unexpected failures in `AppException`

Repositories should not:

- depend on widgets
- use `BuildContext`
- contain screen interaction logic

## Domain Layer

The domain layer defines app-facing business operations and stable models.

### Models

Domain models live in `lib/domain/models`.

Current example:

```dart
class Book {
  String? id;
  String? createdAt;
  String? title;
  String? image;
  String? resume;
  String? slug;
}
```

Keep models framework-agnostic. Do not add widget concerns or transport client state to domain objects.

### Use Cases

Use cases are thin orchestration units around repositories.

Current pattern:

```dart
Future<Result<List<Book>>> execute() async {
  try {
    final books = await _bookRepository.getBooks();
    return Result.ok(books);
  } on AppGenericException catch (e) {
    return Result.error(e);
  }
}
```

Use cases should:

- receive repositories through constructor injection
- expose one action each
- return `Result<T>`
- translate repository exceptions into `Result.error`

Use cases should not:

- know about widgets or navigation
- access `GetIt` directly
- instantiate repositories internally

## UI Layer

The UI layer is split into routing, screens/widgets, and view models.

### View Models

`HomeViewModel` is the current presentation boundary for the home flow.

It owns:

- injected use cases
- `Command0` and `Command1` instances
- in-memory UI state such as `books`
- logging for success/failure branches

Pattern:

```dart
loadingBooksCommand = Command0(_load)..execute();
addingBooksCommand = Command1(_add);
editingBooksCommand = Command1(_edit);
deletingBooksCommand = Command1(_delete);
```

View models should:

- orchestrate use case execution
- store screen state needed by widgets
- expose `Command` objects for loading, success, and error states

View models should not:

- call `Dio` or `SharedPreferences` directly
- perform routing
- depend on `BuildContext`

### Commands

This project uses a local `Command` abstraction in `lib/utils/command.dart`.

`Command` is the standard way to expose:

- `running`
- `completed`
- `error`
- `result`

When adding new async UI actions, prefer a `Command0` or `Command1` instead of hand-rolled loading booleans scattered through widgets.

### Screens and Widgets

Screens render state and trigger view-model actions.

Current examples:

- `HomeScreen` listens to command state with `ListenableBuilder`
- `AddUpdateScreen` gathers form input and returns a `Book` through routing
- `ShowScreen` renders a `Book`

Widgets may:

- listen to `Command` or other `Listenable` state
- call `viewModel.someCommand.execute(...)`
- show snackbars, dialogs, and loading indicators

Widgets should not:

- instantiate repositories or services
- duplicate business rules already represented in use cases
- decide between local and remote sources

## Routing

Routing is centralized in `lib/routing/router.dart` using `go_router`.

Current pattern:

```dart
GoRoute(
  path: Routes.home,
  builder: (_, state) => HomeScreen(viewModel: GetIt.I<HomeViewModel>()),
),
```

Keep route construction in the router layer. If a screen needs a dependency, prefer passing a view model or route argument from `router.dart` rather than resolving infrastructure from inside the widget tree.

## Error Flow

The intended error direction is:

```text
service exception -> repository rethrow/wrap -> use case Result.error -> view model command result -> UI feedback
```

This means:

- services throw infrastructure exceptions
- repositories may normalize unexpected failures into `AppException`
- use cases convert exceptions into `Result`
- widgets react to command state instead of catching repository exceptions

## Testing Strategy

Tests mirror the architecture:

- `test/data/services/...` for service implementations
- `test/data/repositories/...` for repository behavior
- `test/domain/use_cases/...` for use case success/error mapping
- `test/ui/home/view_models/...` for presentation logic
- `test/utils/command_test.dart` for command behavior

When adding a new feature, add tests at the same layer where the behavior lives.

## Workflow For New Features

When extending the project, follow this order:

1. Add or update the domain model in `lib/domain/models`
2. Define or extend the repository contract in `lib/data/repositories`
3. Implement local and/or remote repository behavior
4. Add or extend service contracts only if infrastructure access changes
5. Create use cases that return `Result`
6. Register everything in `lib/injector.dart`
7. Build or extend the view model with `Command`
8. Connect screens/widgets and routes
9. Add tests for the touched layers

## File Targets

- `lib/injector.dart`
- `lib/main.dart`
- `lib/data/services/**`
- `lib/data/repositories/**`
- `lib/domain/models/**`
- `lib/domain/use_cases/**`
- `lib/ui/**`
- `lib/routing/**`
- `test/**`

## Anti-Patterns

```dart
// ❌ Widget using repository directly
final books = await GetIt.I<BookRepository>().getBooks();

// ✅ Widget uses view model command
await widget.viewModel.loadingBooksCommand.execute();
```

```dart
// ❌ Use case reaching into DI
class ListBooksUsecase {
  Future<Result<List<Book>>> execute() async {
    final repo = GetIt.I<BookRepository>();
    return Result.ok(await repo.getBooks());
  }
}

// ✅ Use case receives dependency in constructor
class ListBooksUsecase {
  ListBooksUsecase(this._bookRepository);
  final BookRepository _bookRepository;
}
```

```dart
// ❌ Widget deciding data source
if (config.isDevelopment) {
  // use local storage
} else {
  // use API
}

// ✅ DI decides implementation by flavor
getIt.registerLazySingleton<BookRepository>(() {
  if (flavor == Flavor.development) {
    return BookRepositoryLocal(getIt.get<LocalStorage>());
  }
  return BookRepositoryRemote(getIt.get<ApiClient>());
});
```
