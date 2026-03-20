---
name: build-runner-expert
description: Expert guidance for `build_runner 2.13.x` in this repository. Covers adopting code generation safely in a project that currently has no `build_runner`, no `build.yaml`, and no checked-in generated files. Use when adding builders such as `json_serializable`, `freezed`, `mockito`, `go_router_builder`, or similar; configuring `build.yaml`; running `build` or `watch`; handling generated outputs; or debugging codegen issues without breaking this project's architecture.
metadata:
  author: flutter-it
  version: "1.0"
---

# Build Runner Expert - Code Generation In This Repository

**What**: Guidance for introducing and maintaining `build_runner` in this project. Today, this repository does not yet use code generation, so any `build_runner` adoption should be treated as an explicit architecture/tooling change.

## Current Project State

At the moment this repository has:

- no `build_runner` dependency in `pubspec.yaml`
- no `build.yaml`
- no generated files such as `*.g.dart`, `*.freezed.dart`, `*.mocks.dart`, `*.gr.dart`, or `*.config.dart`

That matters because `build_runner` is not something to "just run" here. It must first be introduced intentionally, together with the specific builder that needs it.

## CRITICAL RULES

- Do not add `build_runner` unless there is a concrete builder need
- Add both `build_runner` and the actual builder package required for the task
- Keep generated code scoped to the feature or package that owns it
- Do not introduce code generation where handwritten code is already simple and maintainable
- If a builder writes source files, check whether those outputs should be committed
- Do not edit `.dart_tool` contents manually
- Keep `build.yaml` minimal; only add it when builder configuration is actually needed
- Prefer deterministic generator workflows that fit the repository architecture
- If adopting generation, update tests and CI assumptions together

## Architecture Fit

This project currently favors explicit handwritten layers:

- services
- repositories
- domain models
- use cases
- view models
- router

That means codegen should support the architecture, not replace it.

Good fits for `build_runner` here:

- model serialization with `json_serializable`
- mock generation for tests
- route generation if the router strategy changes intentionally
- immutable value objects if the project adopts them consistently

Poor fits here:

- generating abstractions that already exist and are small
- introducing heavy codegen just to avoid writing a few constructors
- mixing multiple overlapping builders with no clear need

## When To Use `build_runner`

Use `build_runner` only when a specific builder requires it. Common examples:

- `json_serializable`
- `freezed`
- `mockito`
- `go_router_builder`
- `injectable_generator`

Do not add `build_runner` by itself. It is the execution tool for builders, not the feature itself.

## Initial Adoption Workflow

When introducing code generation in this repository:

1. identify the exact builder needed
2. add the corresponding runtime dependency if required
3. add `build_runner` and the builder package to `dev_dependencies`
4. annotate or structure the source file according to that builder
5. add `part` directives only where the builder expects them
6. run `dart run build_runner build`
7. inspect generated outputs
8. commit generated files if they are part of source outputs for the package

Typical dependency shape:

```yaml
dependencies:
  json_annotation: ^4.x.x

dev_dependencies:
  build_runner: ^2.13.1
  json_serializable: ^6.x.x
```

## Current Repo Integration Points

If `build_runner` is introduced here, the most likely files to change are:

- `pubspec.yaml`
- source files under `lib/**` that opt into generation
- `test/**` if generation is used for mocks
- optional `build.yaml`
- generated outputs under `lib/**` or `test/**`

There is currently no repo-level build configuration file, so `build.yaml` should only be added when:

- a builder needs custom options
- generation should be restricted to certain files
- builder ordering or global options must be controlled

## Running Builds

Single build:

```bash
dart run build_runner build
```

Watch mode:

```bash
dart run build_runner watch
```

When source outputs may already exist and need replacement:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Use `watch` only when actively iterating on generated code. Prefer one-off `build` for smaller or less frequent updates.

## `build` vs `watch`

Use `build` when:

- introducing codegen
- updating generated outputs after a known source change
- CI or local verification should be explicit

Use `watch` when:

- iterating repeatedly on annotated files
- generator turnaround time matters
- the builder is part of active daily development

Do not leave `watch` running as a substitute for understanding what the builder is generating.

## Generated Outputs

`build_runner` writes generated outputs into the source tree for builders configured with source outputs.

Examples include:

- `*.g.dart`
- `*.freezed.dart`
- `*.mocks.dart`
- `*.gr.dart`
- `*.config.dart`

These files become part of the package surface for tools, compilers, and IDEs.

If this package is ever published, generated source files must be included in the published package.

## Internal Files

`build_runner` also uses `.dart_tool` for internal state.

Rules:

- do not edit `.dart_tool` manually
- do not commit `.dart_tool`
- treat it as disposable build state

If build state becomes corrupted, regeneration should happen by rerunning the tool, not by depending on internal cache details.

## `build.yaml` Guidance

Only add `build.yaml` when you need configuration beyond defaults.

Common reasons:

- restrict generation to certain files
- configure builder options
- define builder ordering
- apply global builder options

Example pattern:

```yaml
targets:
  $default:
    builders:
      json_serializable:
        generate_for:
          - lib/domain/models/**.dart
```

Keep `build.yaml` focused. Avoid speculative configuration for builders not in use.

## Builder Selection For This Project

Use these heuristics:

- `json_serializable` if domain/data models become more serialization-heavy
- `mockito` only if the team intentionally moves from handwritten or `mocktail`-based test doubles
- `go_router_builder` only if the routing strategy changes from manual route tables to generated typed routes
- `freezed` only if the codebase intentionally adopts immutable generated model patterns

Current repository state suggests:

- handwritten router
- handwritten models
- handwritten DI
- handwritten local abstractions

So any builder adoption should be a deliberate directional change, not a default.

## Tests And Generated Code

If generated code is introduced for tests:

- keep generation local to the tests that need it
- avoid spreading generator-specific patterns across unrelated tests
- update the test workflow so stale generated files are less likely

If generated code is introduced under `lib`, update relevant unit tests to verify the handwritten source API, not the generated implementation details.

## Debugging Builds

Common debugging workflow:

1. inspect the annotated source file
2. inspect missing or stale `part` directives
3. rerun `dart run build_runner build --delete-conflicting-outputs`
4. check whether builder dependencies are present in `pubspec.yaml`
5. add `build.yaml` only if defaults are insufficient

If the generator is behaving unexpectedly, debug the builder-specific setup first before changing repository architecture.

For deeper build process debugging, `build_runner` supports passing VM args through:

```bash
dart run build_runner build --dart-jit-vm-arg=--observe --dart-jit-vm-arg=--pause-isolates-on-start
```

Use this only for real builder debugging, not normal development.

## Workflow For Adding A New Generated Feature

1. confirm the feature genuinely benefits from code generation
2. choose the builder package
3. update `pubspec.yaml`
4. add or update source annotations and `part` directives
5. add `build.yaml` only if required
6. run `dart run build_runner build --delete-conflicting-outputs`
7. inspect generated code for placement and naming
8. update tests and docs if the developer workflow changed

## File Targets

- `pubspec.yaml`
- optional `build.yaml`
- `lib/**`
- `test/**`
- generated source files next to opted-in sources

## Project-Specific Notes

- this repository currently does not use `build_runner`
- this repository currently has no generated Dart source files
- this repository currently has no `build.yaml`
- current project architecture is explicit and handwritten, so codegen should be introduced sparingly
- if codegen is adopted, keep it aligned with the existing `data`, `domain`, `ui`, and routing boundaries

## Anti-Patterns

```yaml
# ❌ Adding build_runner with no builder need
dev_dependencies:
  build_runner: ^2.13.1
```

```yaml
# ✅ Add build_runner together with the actual generator
dependencies:
  json_annotation: ^4.x.x

dev_dependencies:
  build_runner: ^2.13.1
  json_serializable: ^6.x.x
```

```bash
# ❌ Running build_runner in a repo with no configured builders and expecting generated code
dart run build_runner build

# ✅ First add the builder and opt-in source files
dart run build_runner build --delete-conflicting-outputs
```

```yaml
# ❌ Overengineering build.yaml before it's needed
targets:
  $default:
    builders:
      many_unused_builders: ...

# ✅ Add minimal configuration only for active builders
targets:
  $default:
    builders:
      json_serializable:
        generate_for:
          - lib/domain/models/**.dart
```

```dart
// ❌ Let generated code define architecture direction by accident
// random annotations spread across unrelated layers

// ✅ Introduce generation deliberately in the layer that benefits from it
// for example model serialization or test mocks
```
