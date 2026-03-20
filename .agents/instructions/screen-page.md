---
description: 'UI rules for screens and pages in this Flutter project. Keep widgets focused on rendering, user interaction, and navigation while delegating business logic to view models.'
applyTo: 'lib/ui/**/widgets/*screen.dart, lib/ui/**/widgets/*page.dart, lib/ui/**/pages/*.dart, lib/ui/**/screens/*.dart'
---

# Screen / Page Guide

Follow these rules when editing or creating screens and pages.

## Responsibilities

- Render UI state.
- Trigger actions on the view model.
- Handle local UI concerns such as forms, dialogs, snackbars, and navigation.
- Read route arguments and display them.

## Must Do

- Keep screens focused on composition and user interaction.
- Receive dependencies through constructors when possible.
- Use `ListenableBuilder`, controllers, and local widget state only for presentation concerns.
- Keep validation and field mapping close to the form when it is purely UI-specific.

## Do Not

- Call repositories, services, or plugins directly.
- Put HTTP, storage, or persistence logic in the screen.
- Resolve infrastructure dependencies from `GetIt` inside the widget unless that is already the route-builder pattern for the screen.
- Reimplement business rules already owned by use cases or view models.
- Add noisy logs in `build()`.

## Project Pattern

- Screens under `lib/ui/**/widgets` are the view layer.
- `HomeScreen` talks to `HomeViewModel`.
- Form screens may `pop(result)` and let the caller decide what to do next.
- Navigation should use route constants from `lib/routing/routes.dart`.

## Preferred Shape

- constructor inputs
- local controllers and form key
- `build()`
- small private UI helpers

