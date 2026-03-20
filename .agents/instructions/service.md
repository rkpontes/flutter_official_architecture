---
description: 'Service-layer rules for this Flutter project. Services wrap infrastructure such as HTTP and local storage, exposing small contracts while keeping package-specific details isolated from the rest of the app.'
applyTo: 'lib/data/services/**/*.dart'
---

# Service Guide

Follow these rules when editing or creating services.

## Responsibilities

- Wrap one infrastructure concern.
- Expose a small contract to repositories.
- Hide package-specific details such as `Dio` and `SharedPreferences`.
- Normalize low-level failures into service-level exceptions.

## Must Do

- Keep an abstract service contract when the implementation is infrastructure-bound.
- Inject package instances through the constructor.
- Keep transport and storage logic inside the implementation.
- Throw service-specific exceptions when low-level operations fail.

## Do Not

- Add feature business logic.
- Return widget-facing state.
- Reach into routing or UI layers.
- Mix multiple unrelated infrastructure concerns into one service.

## Project Pattern

- `ApiClient` wraps HTTP access.
- `LocalStorage` wraps local persistence.
- Services are consumed by repositories, not by screens directly.
- DI setup belongs in `lib/injector.dart`, not inside service methods.

