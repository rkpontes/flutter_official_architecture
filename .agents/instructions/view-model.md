---
description: 'Presentation-layer rules for view models in this Flutter project. Coordinate use cases, expose UI-friendly state, and keep transport and persistence details out of the UI boundary.'
applyTo: 'lib/ui/**/view_models/*.dart'
---

# View Model Guide

Follow these rules when editing or creating view models.

## Responsibilities

- Coordinate use cases.
- Expose state in a UI-friendly way.
- Own `Command` objects for async actions.
- Keep lightweight in-memory state needed by the screen.

## Must Do

- Inject dependencies through the constructor.
- Use `Command0` and `Command1` for async user actions.
- Return `Result` from internal async methods that back commands.
- Log meaningful success and failure outcomes at the view-model boundary.

## Do Not

- Call `Dio`, `SharedPreferences`, or other plugins directly.
- Depend on `BuildContext`.
- Perform routing directly.
- Instantiate repositories or use cases inside the class.

## Project Pattern

- `HomeViewModel` is the current reference.
- View models sit between screens and use cases.
- Success and failure handling should map cleanly to UI state and feedback.

## Preferred Shape

- constructor dependencies
- logger
- commands
- private mutable state
- public getters
- private async methods used by commands

