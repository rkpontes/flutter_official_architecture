# AGENTS.md

## Project Overview

The repository is a Flutter application that follows the Flutter app architecture guidance with explicit layering, MVVM-style presentation, dependency injection via `get_it`, and modular agent resources under `.agents/`.

The project includes:

- **Agents** - custom agent mode definitions under `.agents/agents/`
- **Instructions** - file-pattern-based coding guidance under `.agents/instructions/`
- **Skills** - reusable specialized workflows under `.agents/skills/`
- **Templates** - reusable markdown assets under `.agents/templates/`
- **Shared agent instructions** - repository-wide guidance in `.agents/instructions.md`
- **Flutter application code** - app source under `lib/`, tests under `test/`, and architecture docs under `docs/`

This repository is not a generic agent marketplace. The `.agents/` directory exists to support AI-assisted work on this specific Flutter codebase.

## Repository Structure

```text
.
├── .agents/
│   ├── agents/         # Custom agent mode definitions (.md with frontmatter)
│   ├── instructions/   # File-pattern instructions (.md with frontmatter)
│   ├── skills/         # Skill folders (each with SKILL.md)
│   ├── templates/      # Reusable markdown templates
│   ├── README.md       # .agents directory overview
│   └── instructions.md # Shared repository-wide agent instructions
├── docs/               # Architecture and supporting documentation
├── lib/                # Flutter application source
│   ├── data/           # Repositories and services
│   ├── domain/         # Models and use cases
│   ├── routing/        # go_router configuration
│   ├── ui/             # Screens, widgets, and view models
│   ├── utils/          # Shared utilities
│   ├── injector.dart   # Dependency injection
│   └── main.dart       # App bootstrap
├── test/               # Tests by layer
├── web/                # Web entry assets
├── android/            # Android host app
├── ios/                # iOS host app
├── pubspec.yaml        # Dart/Flutter dependencies
└── README.md           # Project overview
```

## Setup Commands

```bash
# Install Dart and Flutter dependencies
flutter pub get

# Run the app with environment values
flutter run --dart-define-from-file=.env

# Run unit and widget tests
flutter test

# Analyze the project
flutter analyze

# Format Dart files
dart format lib test .agents
```

If dependency resolution changes, prefer rerunning `flutter pub get` rather than editing generated lock state manually.

## Development Workflow

### Working with Agents, Instructions, and Skills

All resources under `.agents/` should be lightweight, explicit, and aligned with the actual architecture of this repository.

#### Agent Files (`.agents/agents/*.md`)

- Must have markdown frontmatter
- Must include a `description` field
- Should include a human-readable `name`
- May include a `tools` array when the consuming platform supports it
- File names should be lower case with words separated by hyphens
- Agent content should reflect this repository's Flutter architecture, not generic unrelated stacks

#### Instruction Files (`.agents/instructions/*.md`)

- Must have markdown frontmatter
- Must include a non-empty `description` field
- Must include an `applyTo` field with file patterns
- File names should be lower case with words separated by hyphens
- Instructions should map to real file locations in this repository

#### Skills (`.agents/skills/*/SKILL.md`)

- Each skill lives in its own folder
- `SKILL.md` must include frontmatter
- `name` should match the folder name in lowercase hyphenated form
- `description` should describe when the skill should be used
- Skills should stay focused on one package, layer, or workflow
- Any bundled assets should be referenced from `SKILL.md`

### Adding New Resources

When adding a new agent, instruction, or skill:

1. place it in the correct `.agents/` subdirectory
2. add proper frontmatter
3. align naming with the existing lower-case hyphenated convention
4. make the content specific to this codebase and architecture
5. verify referenced files and paths actually exist

### Adding New Instructions

For instructions under `.agents/instructions/`:

1. create a new `.md` file with a descriptive lower-case hyphenated name
2. add `description` and `applyTo` in frontmatter
3. target real paths such as:
   - `lib/ui/**`
   - `lib/domain/**`
   - `lib/data/**`
4. keep the instruction focused on one layer or concern

### Adding New Skills

For skills under `.agents/skills/`:

1. create a new folder with a lower-case hyphenated name
2. add `SKILL.md`
3. include `name` and `description` in frontmatter
4. keep the skill concise and task-oriented
5. reference only the files and workflows relevant to the skill

## Architecture Rules

This project follows these architectural boundaries:

- `ui -> view_models -> use_cases -> repositories -> services`
- `lib/data/` owns infrastructure-facing concerns
- `lib/domain/` owns models and use cases
- `lib/ui/` owns widgets, screens, and view models
- `lib/routing/` owns navigation
- `lib/injector.dart` owns DI wiring
- `lib/main.dart` owns startup readiness

Agents and instructions created for this repository should preserve those boundaries.

### Layer Responsibilities

#### UI

- render state
- collect user input
- trigger view-model actions
- perform local presentation logic only

#### View Models

- coordinate use cases
- expose `Command`-driven async state
- prepare state for widgets

#### Use Cases

- represent app actions
- call repositories
- return `Result`

#### Repositories

- own feature-facing data access
- map raw service outputs to domain models
- separate local and remote implementations when needed

#### Services

- wrap infrastructure such as `dio` and `shared_preferences`
- hide plugin-specific behavior behind small contracts

## Testing Expectations

Tests are organized by layer under `test/`:

```text
test/
  data/
  domain/
  ui/
  utils/
```

When changing behavior:

- update the nearest layer's tests
- prefer unit tests for services, repositories, use cases, and view models
- add widget tests when view behavior changes materially

## Code Style Guidelines

### Dart and Flutter

- Keep widgets focused on rendering and interaction
- Keep business logic out of widgets
- Prefer constructor injection over hidden global access
- Use `get_it` only through the existing DI strategy
- Keep route strings centralized in `lib/routing/routes.dart`
- Keep plugin access behind services
- Use concise, meaningful logs

### Markdown

- Use clear headings
- Keep frontmatter valid and minimal
- Prefer concise descriptions that explain when to use the resource

## Review Checklist

Before finishing changes, verify:

- file names follow the lower-case-with-hyphens convention where applicable
- frontmatter exists and is valid for `.agents` resources
- `applyTo` patterns match real files
- skill names match folder names
- new guidance reflects the current Flutter architecture
- no new resource references missing files

For app code, also verify:

- no UI layer access to repositories or services
- no plugin access outside services
- no DI wiring hidden in feature code
- tests still match the layer boundaries

## Recommended Validation Commands

```bash
flutter analyze
flutter test
dart format lib test .agents
```

If you changed dependencies:

```bash
flutter pub get
```

## Contributing

When contributing agent resources or code changes:

- keep architecture-specific guidance grounded in this repository
- prefer updating existing instructions or skills over adding overlapping ones
- avoid introducing new architectural patterns casually
- document meaningful architectural shifts in `docs/architecture.md` when appropriate

## Notes for Agents

- Read `.agents/instructions.md` first for shared context
- Load only the relevant skill or instruction for the task
- Prefer the layer-specific instructions in `.agents/instructions/` when editing app code
- Treat `.agents/` as support tooling for this repository, not as an independent product structure
