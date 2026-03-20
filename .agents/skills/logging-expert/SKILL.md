---
name: logging-expert
description: Expert guidance for `package:logging 1.3.x` in this repository. Covers the actual logging setup used here: root log level configuration in `lib/main.dart`, class-scoped `Logger('<ClassName>')` usage in view models, choosing levels such as `fine` and `warning`, and adding a root log handler when operational output is needed. Use when adding diagnostics, standardizing log messages, wiring global log sinks, or improving observability without breaking this project's architecture.
metadata:
  author: flutter-it
  version: "1.0"
---

# Logging Expert - This Project's Diagnostic Pattern

**What**: Logging guidance for the concrete `package:logging` usage in this repository. The app already depends on `logging`, sets a global root level in startup, and uses per-class loggers in presentation code.

## Architecture Summary

The current logging pattern is:

```text
main.dart configures Logger.root
classes create Logger('<ClassName>')
classes log meaningful events near the boundary they own
```

Logging is supplemental diagnostics. It must not replace error propagation, `Result`, exceptions, or UI feedback.

## Current Project Usage

The project currently does two things:

1. sets the root level in `lib/main.dart`
2. uses a class-scoped logger in `HomeViewModel`

Current startup:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Injector.configureDependencies(flavor: flavor);
  await Injector.getIt.isReady<SharedPreferences>();
  runApp(const MainApp());
}
```

Current class logger pattern:

```dart
final _log = Logger('HomeViewModel');
```

And usage:

```dart
_log.fine('Loaded bookings');
_log.warning('Failed to load bookings', result);
```

## CRITICAL RULES

- Create one logger per class or per owned component using `Logger('<ClassName>')`
- Log at the layer that owns the event, failure, or state transition
- Keep log messages short, searchable, and operation-focused
- Use logging to add context, not to duplicate every failure in every layer
- Do not log secrets, tokens, credentials, or full sensitive payloads
- Do not add logs in hot rebuild paths, animation loops, or noisy widget callbacks
- Preserve the separation between logging and error handling
- If you need visible output, configure a root `onRecord` listener in `main.dart`

## Important Current Limitation

This project sets:

```dart
Logger.root.level = Level.ALL;
```

But it does **not** currently attach:

```dart
Logger.root.onRecord.listen(...)
```

So the app defines log level filtering, but not a sink that prints or exports records.

That means:

- class loggers can emit records
- those records are filtered by level
- but they are not automatically shown anywhere unless a listener is added

When updating logging behavior, do not assume logs are already being printed.

## Root Configuration

If the task is to make logs visible during development, configure the root handler in `main.dart`:

```dart
Logger.root.level = Level.ALL;
Logger.root.onRecord.listen((record) {
  debugPrint(
    '${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}',
  );
});
```

Keep the root configuration centralized in `main.dart`.

If you add a sink:

- prefer `debugPrint` in Flutter apps
- keep formatting stable and easy to scan
- include `loggerName`
- include error and stack trace when available

Example:

```dart
Logger.root.onRecord.listen((record) {
  debugPrint(
    '${record.level.name}: ${record.loggerName}: ${record.message}',
  );
  if (record.error != null) {
    debugPrint('error: ${record.error}');
  }
  if (record.stackTrace != null) {
    debugPrint('${record.stackTrace}');
  }
});
```

## Level Selection

Use levels intentionally:

- `severe` for unexpected failures that indicate broken behavior
- `warning` for failed operations that are handled but still important
- `info` for meaningful high-level lifecycle events
- `fine` for development diagnostics and successful command outcomes
- `finer` and `finest` only for temporary deep debugging

In this project, `HomeViewModel` already uses:

- `fine` for successful operations
- `warning` for failed operations

That is a good baseline for view-model command orchestration.

## Where Logs Belong By Layer

## UI Layer

Widgets should usually avoid logging unless:

- the widget owns a meaningful UI event boundary
- the log adds operational value not already represented elsewhere

Prefer logging in view models over widgets. Widgets already have visual feedback paths like snackbars and loading indicators.

Avoid logs such as:

- every `build()`
- every `ListView` item render
- every button tap if the resulting command already logs the outcome

## View Models

View models are a good logging boundary in this project.

They can log:

- command success
- command failure
- state refresh events
- business-relevant user-triggered operations

Pattern used here:

```dart
switch (result) {
  case Ok<void>():
    _log.fine('Added booking');
  case Error<void>():
    _log.warning('Failed to add booking', result);
}
```

When extending this pattern:

- keep the verb first: `Loaded`, `Added`, `Edited`, `Deleted`
- keep failure wording parallel to success wording
- attach the result or exception object when it adds context

## Use Cases

Use cases should normally avoid verbose logging unless they add unique business-level context not already present in the caller or repository.

Because this project already converts exceptions into `Result`, excessive logging in use cases can easily duplicate logs from view models and repositories.

Add logs in use cases only when:

- the use case orchestrates multiple steps
- the use case applies meaningful branching that is otherwise invisible

## Repositories and Services

Repositories and services may log when they own infrastructure boundaries:

- HTTP failures
- storage failures
- serialization or mapping issues
- fallback decisions

But avoid duplicated noise:

- if a service logs a transport failure with enough context, the repository should not repeat the exact same message unless it adds feature-level information
- if a view model logs command failure for the user action, deeper layers should not all emit identical warnings

## Message Style

Prefer concise messages that answer:

- what operation happened
- whether it succeeded or failed
- which entity or identifier was involved when relevant

Good patterns:

```dart
_log.fine('Loaded bookings');
_log.warning('Failed to load bookings', result);
_log.warning('Failed to delete book: $id', result);
```

Avoid vague messages:

```dart
_log.warning('Something went wrong');
_log.info('Running code');
```

If computing the message is expensive, pass a closure:

```dart
_log.fine(() => 'Loaded ${books.length} books');
```

## Async Errors

The package supports attaching an error and stack trace:

```dart
try {
  await doWork();
} catch (e, stackTrace) {
  _log.severe('Failed to sync books', e, stackTrace);
  rethrow;
}
```

Use this when the logging layer is the right owner of the failure context.

Do not catch only to log and swallow unless that layer is explicitly responsible for recovery.

## Workflow

When adding or changing logging in this repository:

1. identify the layer that owns the event
2. reuse or add a class logger with `Logger('<ClassName>')`
3. choose the lowest level that still reflects the importance
4. add context that helps diagnose the operation
5. check whether the same failure is already logged elsewhere
6. update `main.dart` only if the root log sink or global level behavior changes

## File Targets

- `lib/main.dart`
- `lib/ui/**`
- `lib/domain/**`
- `lib/data/**`

## Project-Specific Notes

- `main.dart` currently sets `Logger.root.level = Level.ALL`
- there is no root `onRecord` listener yet
- `HomeViewModel` is the current example of consistent class-level logger usage
- the project already uses `Result` and command state for user-facing error handling, so logs should support diagnosis rather than drive UI behavior

## Anti-Patterns

```dart
// ❌ Logging without a configured sink and assuming it prints
Logger.root.level = Level.ALL;

// ✅ Configure the sink when visible output is needed
Logger.root.level = Level.ALL;
Logger.root.onRecord.listen((record) {
  debugPrint('${record.level.name}: ${record.loggerName}: ${record.message}');
});
```

```dart
// ❌ Logging the same failure at every layer with no new information
_log.warning('Failed to load books');
_log.warning('Failed to load books');
_log.warning('Failed to load books');

// ✅ Log where the context is strongest
_log.warning('Failed to load books', result);
```

```dart
// ❌ Noisy widget logging
@override
Widget build(BuildContext context) {
  _log.fine('Building HomeScreen');
  return ...
}

// ✅ Log command or state boundaries instead
_log.fine('Loaded bookings');
```

```dart
// ❌ Logging secrets or raw sensitive data
_log.info('Token: $token');

// ✅ Log safe operational context
_log.info('Authenticated request started');
```
