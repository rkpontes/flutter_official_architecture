---
name: shared-preferences-expert
description: Expert guidance for `shared_preferences 2.5.x` in this repository. Covers the actual storage architecture used here: asynchronous `SharedPreferences` registration in `lib/injector.dart`, startup readiness in `lib/main.dart`, and access only through the `LocalStorage` abstraction in `lib/data/services/local_storage`. Use when adding lightweight persistence, evolving the local storage service, or deciding whether to stay on legacy `SharedPreferences` or migrate to `SharedPreferencesAsync` or `SharedPreferencesWithCache`.
metadata:
  author: flutter-it
  version: "1.0"
---

# Shared Preferences Expert - This Project's Local Storage Pattern

**What**: Persistence guidance for the concrete `shared_preferences` usage in this repository. The app uses `shared_preferences` behind a `LocalStorage` service and waits for initialization before starting the app.

## Architecture Summary

The current storage flow is:

```text
widgets/ui -> view models/use cases -> repositories -> LocalStorage -> SharedPreferences
```

`SharedPreferences` is an infrastructure detail. The rest of the app should depend on `LocalStorage`, not on the plugin directly.

## Current Project Usage

The project currently uses the legacy `SharedPreferences` API:

```dart
getIt.registerLazySingletonAsync<SharedPreferences>(
  () async => SharedPreferences.getInstance(),
);

getIt.registerLazySingleton<LocalStorage>(
  () => LocalStorageImpl(getIt.get<SharedPreferences>()),
);
```

And startup waits for it explicitly:

```dart
await Injector.getIt.isReady<SharedPreferences>();
```

The current service contract is string-based:

```dart
abstract class LocalStorage {
  Future<void> save(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
}
```

Implementation:

```dart
class LocalStorageImpl implements LocalStorage {
  LocalStorageImpl(this.sharedPreferences);

  final SharedPreferences sharedPreferences;
}
```

## CRITICAL RULES

- Do not call `SharedPreferences` directly from widgets, view models, repositories, or use cases
- Access the plugin only through `lib/data/services/local_storage`
- Keep plugin-specific logic inside `LocalStorageImpl`
- Preserve explicit startup readiness when storage initialization is async
- Store only lightweight, non-critical data
- Do not treat `shared_preferences` as a database
- Centralize keys and serialization close to the storage service or owning repository
- Prefer deleting with `remove` instead of using old null-setter patterns
- If changing APIs from legacy `SharedPreferences`, update DI and startup readiness together

## Important Package Guidance

As of `shared_preferences 2.5.x`, the package exposes three APIs:

- `SharedPreferences` - legacy API
- `SharedPreferencesAsync`
- `SharedPreferencesWithCache`

The package recommends new code prefer `SharedPreferencesAsync` or `SharedPreferencesWithCache`.

This project currently still uses the legacy `SharedPreferences` API. That is important:

- existing code should stay consistent unless you are intentionally migrating
- new storage features should fit the current architecture first
- migration to a newer API is an architectural change, not a casual refactor

## When The Current Approach Is Fine

The existing design is acceptable when:

- data is simple
- reads are mostly local to one app instance
- cached synchronous getters are acceptable after startup
- you want minimal architectural change

Current examples that fit this style:

- simple lists serialized as JSON
- lightweight app flags
- cached local-only feature state

## When To Consider `SharedPreferencesAsync`

Prefer `SharedPreferencesAsync` if the storage must always reflect the latest underlying platform state and you want to avoid cache coherence issues.

That matters when:

- multiple isolates may read or write preferences
- multiple engine instances may access the same store
- native code may mutate the underlying preferences
- stale cached reads are a real problem

If you migrate this project to `SharedPreferencesAsync`, the storage abstraction should stay in place. Change the implementation and DI wiring, not the whole app.

## When To Consider `SharedPreferencesWithCache`

Prefer `SharedPreferencesWithCache` if:

- you want a modern API
- you still want cached synchronous getters
- you want stronger control over allowed keys

This is useful when the project benefits from:

- allowlisted keys
- more explicit cache semantics
- keeping fast local reads after initialization

## Current Local Storage Responsibilities

`LocalStorageImpl` should own:

- direct plugin calls
- mapping plugin exceptions to `LocalStorageException`
- low-level `save`, `read`, `delete`, and `clear` behavior

It should not own:

- domain-level decisions
- repository branching
- UI logic
- feature-specific business rules

## Current Data Shape

The storage service currently stores `String` values only:

```dart
Future<void> save(String key, String value);
Future<String?> read(String key);
```

This means repositories or callers must serialize complex objects before saving them.

That matches the current `BookRepositoryLocal` approach:

- serialize `List<Book>` to JSON
- save the JSON string under one key
- read and decode later

This is the right pattern for the current architecture.

## Initialization Pattern

The current app startup is correct for the existing API:

```dart
WidgetsFlutterBinding.ensureInitialized();
Injector.configureDependencies(flavor: flavor);
await Injector.getIt.isReady<SharedPreferences>();
runApp(const MainApp());
```

If you change the storage implementation:

- keep `WidgetsFlutterBinding.ensureInitialized()`
- keep async registration explicit in `Injector.configureDependencies`
- wait for the new storage dependency before `runApp()` if it still requires readiness

Do not hide this readiness inside widgets.

## Using The Storage Service

The project rule is:

- services wrap plugin access
- repositories use services
- upper layers use repositories and use cases

So if you need local persistence for a feature:

1. extend or reuse `LocalStorage`
2. update `LocalStorageImpl`
3. use it from the appropriate repository
4. expose behavior through use cases if the UI needs it

Do not inject `SharedPreferences` directly into repositories or view models.

## Key Management

Keys should be stable and centralized at the owning boundary.

Current example:

```dart
final label = 'books';
```

Prefer:

- explicit key constants or dedicated labels per repository/service
- one owner per key namespace
- avoiding duplicate string keys across unrelated files

If key usage expands, consider moving keys into a dedicated constants file owned by the storage layer or the feature repository.

## Serialization Guidance

Because the current abstraction is string-only, serialize complex data explicitly:

```dart
await _storage.save(label, jsonEncode(booksList));
final books = await _storage.read(label);
```

Use this for:

- lists of domain objects
- lightweight cached documents
- small structured app settings

Do not use this for:

- large datasets
- critical transactional data
- storage requiring query semantics

## Clear And Delete Behavior

Current operations:

- `delete(key)` removes one key
- `clear()` wipes the full preference store accessible to the app

Be careful with `clear()`:

- it is broad
- it can remove unrelated app values
- it should be used only when full storage reset is really intended

If the storage surface grows, prefer key-scoped deletes over global clear.

## Error Handling

`LocalStorageImpl` currently maps plugin failures to `LocalStorageException`:

```dart
try {
  await sharedPreferences.setString(key, value);
} catch (e) {
  throw LocalStorageException('Error saving key: $key');
}
```

Keep that boundary:

- plugin-specific failures stay in the storage layer
- repositories may rethrow `LocalStorageException`
- unexpected repository failures can be wrapped as `AppException`

Do not leak plugin implementation details upward unless there is a strong reason.

## Migration Guidance

If migrating from legacy `SharedPreferences` to `SharedPreferencesAsync` or `SharedPreferencesWithCache`:

1. keep the `LocalStorage` abstraction
2. create or update the implementation to use the new API
3. update DI registration in `lib/injector.dart`
4. update startup readiness in `lib/main.dart` if needed
5. preserve the public service contract unless there is a strong reason to change it
6. update tests in `test/data/services/local_storage/`

If migration changes semantics around caching or async reads, document that in the service contract rather than leaking those details across the app.

## File Targets

- `lib/data/services/local_storage/local_storage.dart`
- `lib/data/services/local_storage/local_storage_impl.dart`
- `lib/data/repositories/**`
- `lib/injector.dart`
- `lib/main.dart`
- `test/data/services/local_storage/**`

## Project-Specific Notes

- the app currently uses the legacy `SharedPreferences` API
- `SharedPreferences` is registered asynchronously in `Injector.configureDependencies`
- `main.dart` waits for storage readiness before `runApp()`
- the storage abstraction is string-oriented, so repositories are responsible for JSON encoding and decoding
- the development flavor uses a local repository implementation backed by `LocalStorage`

## Anti-Patterns

```dart
// ❌ Direct plugin usage in upper layers
final prefs = await SharedPreferences.getInstance();
await prefs.setString('books', json);

// ✅ Go through the local storage service
await _storage.save('books', json);
```

```dart
// ❌ Treating shared_preferences like durable critical storage
await prefs.setString('payment_state', sensitiveCriticalValue);

// ✅ Use it only for lightweight non-critical app data
await _storage.save('books', jsonEncode(books));
```

```dart
// ❌ Hiding async initialization inside a widget
class MyScreen extends StatefulWidget {
  ...
}

// ✅ Make readiness explicit at startup
await Injector.getIt.isReady<SharedPreferences>();
runApp(const MainApp());
```

```dart
// ❌ Spreading raw keys across the app
await _storage.save('books', value);
await _storage.save('books', otherValue);

// ✅ Keep key ownership near the repository/service
final label = 'books';
await _storage.save(label, value);
```
