---
description: 'Repository-layer rules for this Flutter project. Repositories own feature-facing data access, choose the correct source implementation, and convert raw service data into domain models.'
applyTo: 'lib/data/repositories/**/*.dart'
---

# Repository Guide

Follow these rules when editing or creating repositories.

## Responsibilities

- Expose feature-facing data operations.
- Convert raw service results into domain models.
- Delegate infrastructure access to services.
- Re-throw known service exceptions and wrap unexpected failures in app exceptions when appropriate.

## Must Do

- Keep the abstract repository contract stable and app-facing.
- Keep local and remote implementations behind the same contract.
- Serialize and deserialize data where the repository owns that mapping.
- Keep source-specific concerns inside the respective implementation.

## Do Not

- Call widgets or depend on `BuildContext`.
- Use `GetIt` inside repository methods.
- Embed HTTP client setup or plugin bootstrapping here.
- Leak raw service implementation details upward unless the contract explicitly allows it.

## Project Pattern

- `BookRepository` is the contract.
- `BookRepositoryLocal` uses `LocalStorage`.
- `BookRepositoryRemote` uses `ApiClient`.
- Flavor decides which implementation is registered in DI.

