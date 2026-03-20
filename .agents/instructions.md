---
description: "Use when: working with this Flutter project to understand structure, conventions, and available workflows"
---

# Shared Agent Instructions

## Project Overview
This is a Flutter application demonstrating clean architecture principles with data, domain, and UI layers.

## Key Directories
- `lib/data/`: Data handling (repositories, services)
- `lib/domain/`: Business logic (models, use cases)
- `lib/ui/`: Presentation layer (widgets, view models)
- `lib/routing/`: Navigation setup
- `lib/utils/`: Utilities and extensions

## Available Workflows
- `/code-review`: Automated code review with checklists
- `/test`: Run and analyze tests
- `/document`: Generate/update documentation
- `/refactor`: Safe refactoring operations

## Best Practices
- Follow clean architecture: UI → Domain → Data
- Use dependency injection
- Implement repository pattern
- Keep business logic in use cases
- Write comprehensive tests

## Token Efficiency
Reference domain docs in `.agents/docs/` for detailed information rather than loading full context.