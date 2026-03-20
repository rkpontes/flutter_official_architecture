---
name: flutter-bloc-expert
description: Expert guidance for `flutter_bloc 9.1.x`, `bloc 9.x`, and `bloc_test 10.x` in this repository. Covers Cubit vs Bloc, BlocProvider and RepositoryProvider, BlocBuilder, BlocListener, BlocConsumer, BlocSelector, BlocObserver, and testing with bloc_test. Use when adopting flutter_bloc, introducing bloc-based presentation state, testing blocs/cubits, or deciding how bloc fits this project's existing get_it plus view-model architecture.
metadata:
  author: flutter-it
  version: "1.0"
---

# Flutter Bloc Expert - State Management In This Repository

**What**: Guidance for using `flutter_bloc` and `bloc` in this project. This repository does not currently use `flutter_bloc`, so introducing it is an architectural decision, not a casual refactor.

## Current Project State

Today this project uses:

- `get_it` for dependency wiring
- view models under `lib/ui/**/view_models`
- `Command` in `lib/utils/command.dart` for async UI actions
- `go_router` for navigation

It does **not** currently use:

- `flutter_bloc`
- `bloc`
- `bloc_test`
- `BlocProvider`
- `Cubit`
- `Bloc`

That means bloc adoption must be deliberate and consistent.

## CRITICAL RULES

- Do not mix `flutter_bloc` into a feature unless the feature clearly benefits from it
- Prefer one presentation-state pattern per feature; avoid half view model, half bloc ownership
- Use `Cubit` by default for simple state transitions
- Use full `Bloc<Event, State>` only when explicit event modeling adds real value
- Keep repositories and services independent from bloc widgets
- Keep `BlocProvider` and `RepositoryProvider` in the presentation composition layer, not inside repositories or services
- Use `BlocListener` for side effects and `BlocBuilder` for rendering
- Keep bloc state immutable and UI-facing
- Test blocs and cubits with `bloc_test` if bloc is adopted
- If a feature remains on the current architecture, prefer `Command` plus view model over introducing bloc just for fashion

## When `flutter_bloc` Fits This Project

Adopt bloc when a feature has:

- richer UI state transitions
- multiple asynchronous states with clear progression
- complex event-driven behavior
- a need for explicit state machines
- multiple widgets reacting to the same presentation state in one subtree

Do not adopt bloc when:

- a simple view model with one or two `Command`s is already sufficient
- the feature only needs one async action and a list of results
- introducing bloc would duplicate an existing view-model layer without removing it

## Cubit vs Bloc

Use `Cubit` when:

- state changes are driven by direct intent methods
- events do not need to be modeled separately
- the interaction surface is small and clear

```dart
class BooksCubit extends Cubit<BooksState> {
  BooksCubit(this._listBooksUsecase) : super(const BooksState.initial());

  final ListBooksUsecase _listBooksUsecase;

  Future<void> load() async {
    emit(state.copyWith(status: BooksStatus.loading));
    final result = await _listBooksUsecase.execute();
    switch (result) {
      case Ok<List<Book>>():
        emit(state.copyWith(
          status: BooksStatus.success,
          books: result.value,
        ));
      case Error<List<Book>>():
        emit(state.copyWith(
          status: BooksStatus.failure,
          error: result.error,
        ));
    }
  }
}
```

Use `Bloc<Event, State>` when:

- the event model is important to the domain or UI flow
- multiple event types need separate handling
- concurrency or event ordering matters

```dart
sealed class BooksEvent {}
final class BooksRequested extends BooksEvent {}
final class BookDeleted extends BooksEvent {
  BookDeleted(this.id);
  final String id;
}
```

Default to `Cubit` unless event modeling makes the feature clearer.

## Providers

Use `BlocProvider` to provide bloc or cubit instances to a subtree:

```dart
BlocProvider(
  create: (_) => BooksCubit(getIt<ListBooksUsecase>()),
  child: const BooksScreen(),
)
```

Use `BlocProvider.value` only when passing an existing instance into another subtree or route:

```dart
BlocProvider.value(
  value: context.read<BooksCubit>(),
  child: const BooksDetailsScreen(),
)
```

Use `RepositoryProvider` only for repositories in a bloc subtree. In this project, repositories are already wired in `get_it`, so adding `RepositoryProvider` is usually unnecessary unless a feature intentionally scopes a repository to a subtree.

## UI Widgets

### `BlocBuilder`

Use for pure rebuilds:

```dart
BlocBuilder<BooksCubit, BooksState>(
  builder: (context, state) {
    if (state.status == BooksStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return BooksList(books: state.books);
  },
)
```

Use `buildWhen` only when you have a clear rebuild optimization reason.

### `BlocListener`

Use for one-off side effects:

- navigation
- snackbars
- dialogs

```dart
BlocListener<BooksCubit, BooksState>(
  listenWhen: (previous, current) =>
      previous.status != current.status &&
      current.status == BooksStatus.failure,
  listener: (context, state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.error.toString())),
    );
  },
  child: const BooksView(),
)
```

### `BlocConsumer`

Use only when the same widget genuinely needs both rebuild and side effects:

```dart
BlocConsumer<BooksCubit, BooksState>(
  listener: (context, state) {},
  builder: (context, state) => const SizedBox(),
)
```

Do not default to `BlocConsumer` out of convenience.

### `BlocSelector`

Use when only a small immutable slice of state should trigger rebuilds:

```dart
BlocSelector<BooksCubit, BooksState, bool>(
  selector: (state) => state.isLoading,
  builder: (context, isLoading) {
    return isLoading
        ? const CircularProgressIndicator()
        : const SizedBox.shrink();
  },
)
```

Prefer this over manual rebuild tuning when the selected value is clear and stable.

## Accessing Instances

Preferred access patterns:

```dart
context.read<BooksCubit>();   // one-time read
context.watch<BooksCubit>();  // subscribe to bloc instance changes
context.select((BooksCubit c) => c.state.status);
```

Use `read` for user actions.
Use builders/selectors for state-driven UI.

Do not perform business logic in widgets just because the bloc instance is available.

## State Design

Bloc state should be:

- immutable
- presentation-facing
- explicit about loading, success, and failure

Prefer one state object over scattered booleans:

```dart
enum BooksStatus { initial, loading, success, failure }

class BooksState {
  const BooksState({
    required this.status,
    required this.books,
    this.error,
  });

  const BooksState.initial()
      : status = BooksStatus.initial,
        books = const [],
        error = null;

  final BooksStatus status;
  final List<Book> books;
  final Exception? error;
}
```

## Dependency Injection

This repository already centralizes DI in `lib/injector.dart`.

If bloc is adopted, prefer:

- repositories, use cases, and services from `get_it`
- blocs/cubits created in route builders or feature composition widgets

Example:

```dart
GoRoute(
  path: Routes.home,
  builder: (_, state) => BlocProvider(
    create: (_) => BooksCubit(GetIt.I<ListBooksUsecase>())..load(),
    child: const BooksScreen(),
  ),
)
```

Do not move repository or service construction into bloc classes.

## BlocObserver

Use `Bloc.observer` for global diagnostics when bloc is actually part of the app:

```dart
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }
}
```

Set it during startup only if the app is using bloc meaningfully. Do not add a global observer for a single experimental feature and forget it.

## Testing With `bloc_test`

If bloc is adopted, use `bloc_test` for cubit and bloc behavior.

Cubit test:

```dart
blocTest<BooksCubit, BooksState>(
  'emits loading then success when load succeeds',
  build: () => BooksCubit(listBooksUsecase),
  act: (cubit) => cubit.load(),
  expect: () => [
    isA<BooksState>().having((s) => s.status, 'status', BooksStatus.loading),
    isA<BooksState>().having((s) => s.status, 'status', BooksStatus.success),
  ],
);
```

Bloc test:

```dart
blocTest<BooksBloc, BooksState>(
  'emits loading then success when BooksRequested is added',
  build: () => BooksBloc(listBooksUsecase),
  act: (bloc) => bloc.add(BooksRequested()),
  expect: () => [
    isA<BooksState>().having((s) => s.status, 'status', BooksStatus.loading),
    isA<BooksState>().having((s) => s.status, 'status', BooksStatus.success),
  ],
);
```

Use `whenListen` for mocked stream behavior when needed.

## How Bloc Fits This Architecture

If bloc is introduced here, use one of these approaches and be consistent:

### Option 1: Replace ViewModel Per Feature

- widget subtree uses bloc/cubit directly
- use cases remain
- repositories remain
- services remain

Flow:

```text
ui/widgets -> cubit/bloc -> use_cases -> repositories -> services
```

### Option 2: Do Not Add Bloc

- keep current view-model plus `Command` pattern

Flow:

```text
ui/widgets -> view_model -> use_cases -> repositories -> services
```

Do **not** keep both a `HomeViewModel` and a `HomeCubit` owning the same feature state unless there is a very narrow adapter reason.

## File Targets

- `pubspec.yaml`
- `lib/ui/**`
- `lib/routing/**`
- `lib/injector.dart`
- `test/ui/**`
- optional new bloc/cubit folders if the feature structure changes intentionally

## Project-Specific Notes

- this repository does not currently depend on `flutter_bloc`
- this repository does not currently depend on `bloc`
- this repository does not currently depend on `bloc_test`
- current presentation logic uses view models and `Command`
- introducing bloc should be a per-feature architectural choice with explicit migration, not an incidental dependency

## Anti-Patterns

```dart
// ❌ Widget doing side effects in BlocBuilder
BlocBuilder<BooksCubit, BooksState>(
  builder: (context, state) {
    if (state.status == BooksStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
    return const SizedBox();
  },
)

// ✅ Use BlocListener for side effects
BlocListener<BooksCubit, BooksState>(
  listener: (context, state) { ... },
  child: const BooksView(),
)
```

```dart
// ❌ Introducing bloc and keeping duplicate view-model ownership
class HomeViewModel { ... }
class HomeCubit extends Cubit<HomeState> { ... }

// ✅ One feature, one presentation-state owner
class HomeCubit extends Cubit<HomeState> { ... }
```

```dart
// ❌ Using full Bloc when Cubit is enough
class CounterBloc extends Bloc<CounterEvent, int> { ... }

// ✅ Prefer Cubit for direct intent methods
class CounterCubit extends Cubit<int> { ... }
```

```dart
// ❌ Constructing repositories inside the bloc
BooksCubit() : _repo = BookRepositoryRemote(ApiClientImpl(Dio()));

// ✅ Inject dependencies from the existing composition root
BooksCubit(this._listBooksUsecase) : super(const BooksState.initial());
```
