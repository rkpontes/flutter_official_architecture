---
description: 'Domain model rules for this Flutter project. Keep models simple, framework-agnostic, and centered on app data rather than UI or infrastructure concerns.'
applyTo: 'lib/domain/models/**/*.dart'
---

# Model Guide

Follow these rules when editing or creating domain models.

## Responsibilities

- Represent app data.
- Support basic serialization and deserialization when the project keeps that logic on the model.
- Stay usable across data, domain, and UI layers.

## Must Do

- Keep models simple and predictable.
- Prefer explicit fields over hidden behavior.
- Keep mapping logic readable when `fromJson` and `toJson` live on the model.
- Preserve compatibility with repository and use-case boundaries.

## Do Not

- Depend on Flutter UI classes.
- Depend on services, repositories, or use cases.
- Add navigation, storage, or transport logic.
- Turn models into view models.

## Project Pattern

- `Book` is the current reference model.
- Models are plain Dart objects shared across layers.
- Keep them lightweight unless the architecture intentionally changes.

