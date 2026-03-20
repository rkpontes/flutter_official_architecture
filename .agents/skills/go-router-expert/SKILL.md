---
name: go-router-expert
description: Expert guidance for `go_router 17.x` in this repository. Covers the actual routing architecture used here: a single router in `lib/routing/router.dart`, centralized path constants in `lib/routing/routes.dart`, route builders that resolve screen dependencies through `GetIt`, navigation with `context.push` and `context.pop`, and passing typed route payloads through `state.extra`. Use when adding screens, changing navigation flows, wiring route arguments, or implementing redirects without breaking this project's routing conventions.
metadata:
  author: flutter-it
  version: "1.0"
---

# Go Router Expert - This Project's Navigation Structure

**What**: Routing guidance for the concrete `go_router` setup in this repository. The app uses a single `GoRouter`, path constants in one place, and simple route builders that construct screens directly.

## Architecture Summary

The current routing shape is:

```text
MaterialApp.router -> router.dart -> Routes constants -> screen builders
```

Navigation is URL-based, but this app currently keeps routing simple:

- flat top-level routes
- no nested routes
- no `ShellRoute`
- no named routes in the router table
- no active redirect policy yet
- route payloads passed through `state.extra`

## Project Routing Files

```text
lib/
  routing/
    router.dart
    routes.dart
  ui/
    home/widgets/home_screen.dart
    add_update/widgets/add_update_screen.dart
    show/widgets/show_screen.dart
  utils/
    extensions.dart
```

## CRITICAL RULES

- Keep route path constants centralized in `lib/routing/routes.dart`
- Register routes only in `lib/routing/router.dart`
- Keep route builders thin; they should construct screens, not run feature logic
- Pass dependencies into screens at route-build time when needed
- Use `state.extra` only for typed payloads that belong to navigation
- Keep navigation policy in redirects, not in screen widgets
- Do not scatter raw `'/some-path'` strings through the UI
- When a route result must be awaited, use the native `go_router` `context.push<T>()`
- Do not move data loading into redirect callbacks

## Current Router Setup

This project currently defines the router as:

```dart
GoRouter get router {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (_, state) => HomeScreen(viewModel: GetIt.I<HomeViewModel>()),
      ),
      GoRoute(
        path: Routes.addUpdate,
        builder: (_, state) => AddUpdateScreen(book: state.extra as Book?),
      ),
      GoRoute(
        path: Routes.show,
        builder: (_, state) => ShowScreen(book: state.extra as Book?),
      ),
    ],
  );
}
```

This means:

- routing is globally configured in one file
- `HomeViewModel` is resolved from `GetIt` in the route builder
- `AddUpdateScreen` and `ShowScreen` receive a `Book?` from `state.extra`

## Route Constants

Path constants live in `lib/routing/routes.dart`:

```dart
abstract final class Routes {
  static const home = '/';
  static const addUpdate = '/add-update';
  static const show = '/show';
}
```

When adding a route:

1. add the path constant in `routes.dart`
2. register the `GoRoute` in `router.dart`
3. update navigation call sites to use `Routes.somePath`

## Screen Construction Pattern

Keep route builders explicit and lightweight:

```dart
GoRoute(
  path: Routes.home,
  builder: (_, state) => HomeScreen(
    viewModel: GetIt.I<HomeViewModel>(),
  ),
),
```

This project already uses route builders to resolve presentation dependencies. Follow that pattern instead of resolving repositories or services from inside widgets.

Good route builder responsibilities:

- construct the screen
- pull a view model from `GetIt` when needed
- read typed route arguments from `state.extra`

Bad route builder responsibilities:

- call use cases
- fetch data
- mutate app state
- run side effects unrelated to navigation

## Passing Arguments With `extra`

The project currently passes `Book` objects through `extra`:

```dart
context.push(Routes.show, extra: book);
context.push(Routes.addUpdate, extra: book);
```

And reads them like this:

```dart
builder: (_, state) => ShowScreen(book: state.extra as Book?)
```

Use `extra` when:

- you are passing an in-memory object to the next screen
- the object is already available at the call site
- the route is not intended to be reconstructed from a URL alone

Avoid `extra` when:

- the screen should be deep-linkable from a URL
- the data should survive app restarts or browser refreshes
- a path parameter would better express route identity

If a screen should become deep-linkable later, prefer a path such as `'/books/:id'` and let the screen or view model load by id.

## Current Navigation Flow

The home screen uses `go_router` directly:

```dart
onTap: () => context.push(Routes.show, extra: book),
```

For add/edit flows:

```dart
final res = await context.push(Routes.addUpdate, extra: book);
if (res != null && res is Book) {
  widget.viewModel.editingBooksCommand.execute(res);
}
```

And the form screen returns data with:

```dart
context.pop(Book(...));
```

This is the current preferred pattern for modal-style edit/create flows:

- push the form screen
- await the returned domain object
- let the caller decide whether to add or edit

## Redirects

`router.dart` already contains a redirect hook:

```dart
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  return null;
}
```

Keep redirects for navigation policy only, such as:

- auth gating
- forcing onboarding
- redirecting away from invalid route states

Do not use redirects for:

- loading repositories
- invoking use cases
- fetching remote data
- doing expensive async work unrelated to route policy

If auth routing is added later, keep the redirect small and use a refresh signal rather than duplicating checks inside multiple screens.

## `go`, `push`, and `pop`

Use the navigation method that matches the flow:

- `context.go(...)` for replacing location
- `context.push(...)` for stacking a new screen
- `context.pop(result)` for returning to the previous screen with an optional result

In this project:

- `push` is correct for `show` and `add-update`
- `pop(result)` is correct for returning a created or edited `Book`

Avoid using `go` where the caller expects a result back.

## Interaction With Local Extensions

This repository has `GoRouterX` extensions in `lib/utils/extensions.dart`.

Important detail:

- those helpers define `push` as `void`
- native `go_router` `BuildContext.push<T>()` returns `Future<T?>`

So:

- use the native `go_router` methods when you need `await context.push(...)`
- helper extensions are only safe for fire-and-forget navigation

Do not replace awaited navigation flows with the local extension methods unless you also change the extension contract.

## Adding A New Route

Follow this order:

1. add a constant to `lib/routing/routes.dart`
2. register a `GoRoute` in `lib/routing/router.dart`
3. decide whether the screen needs DI-resolved dependencies
4. decide whether route data belongs in `extra`, path parameters, or query parameters
5. update the calling widget to navigate via `Routes`
6. update redirect logic only if navigation policy changed

Example pattern:

```dart
// routes.dart
static const details = '/details';

// router.dart
GoRoute(
  path: Routes.details,
  builder: (_, state) => DetailsScreen(
    item: state.extra as Item,
  ),
),
```

## Deep Linking Guidance

The current app mostly uses in-memory navigation payloads. That is fine for internal flows, but it limits URL reconstruction.

Use this rule:

- if the route represents a durable resource identity, prefer path parameters
- if the route is only an internal workflow handoff, `extra` is acceptable

For example:

- good candidate for path parameter: a public book details page by id
- acceptable `extra` flow: returning a just-edited `Book` from the form screen

## File Targets

- `lib/routing/router.dart`
- `lib/routing/routes.dart`
- `lib/ui/**` navigation call sites
- `lib/utils/extensions.dart` if navigation helper behavior changes

## Anti-Patterns

```dart
// ❌ Raw route strings in widgets
context.push('/show', extra: book);

// ✅ Centralized route constant
context.push(Routes.show, extra: book);
```

```dart
// ❌ Doing feature work in the route builder
builder: (_, state) {
  final vm = GetIt.I<HomeViewModel>();
  vm.loadingBooksCommand.execute();
  return HomeScreen(viewModel: vm);
}

// ✅ Keep route builder focused on construction
builder: (_, state) => HomeScreen(
  viewModel: GetIt.I<HomeViewModel>(),
)
```

```dart
// ❌ Using a helper that cannot return a pushed result
context.push(Routes.addUpdate, extra: book);

// ✅ Use native go_router push when awaiting result
final result = await context.push<Book?>(Routes.addUpdate, extra: book);
```

```dart
// ❌ Putting routing branches in widgets based on flavor or infra
if (config.isDevelopment) {
  // navigate one way
} else {
  // navigate another way
}

// ✅ Keep navigation decisions route- and state-driven
context.push(Routes.show, extra: book);
```
