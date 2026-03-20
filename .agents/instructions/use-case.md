---
description: 'Domain-layer rules for use cases in this Flutter project. Keep them small, focused, and responsible for turning repository outcomes into `Result` values for the presentation layer.'
applyTo: 'lib/domain/use_cases/**/*.dart'
---

# Use Case Guide

Follow these rules when editing or creating use cases.

## Responsibilities

- Represent one app action.
- Call the repository contract needed for that action.
- Convert exceptions into `Result.ok` or `Result.error`.

## Must Do

- Inject repository dependencies through the constructor.
- Expose a single `execute(...)` entrypoint.
- Return `Result<T>`.
- Catch app-level exceptions that the UI layer is expected to consume.

## Do Not

- Access `GetIt` directly.
- Depend on widgets, routing, or `BuildContext`.
- Know about HTTP, `Dio`, `SharedPreferences`, or plugin details.
- Mix multiple unrelated actions into one use case.

## Project Pattern

- Use cases in `lib/domain/use_cases/book` are the reference.
- They are intentionally thin.
- They should stay stable even if local and remote repository implementations change.

