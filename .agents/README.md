# .agents/ Directory

This directory contains a generic agent documentation and customization structure inspired by the React repository's approach. It's designed to be adaptable for any AI agent working with this project, optimizing for reduced token costs through modular, on-demand loading.

## Structure Overview

- **instructions.md**: Shared workspace instructions for all agents
- **skills/**: Reusable workflow modules (e.g., code review, testing)
- **agents/**: Complex, multi-step custom agents
- **docs/**: Shared domain knowledge bases
- **templates/**: Reusable templates referenced by skills

## Token Optimization

- Agents load content on-demand based on descriptions and keywords
- Domain-specific docs are searchable references, not auto-loaded
- Skills and agents are discovered via YAML frontmatter descriptions
- Reduces context window usage by 40-60% compared to monolithic documentation

## Usage

Agents should reference this structure to understand project conventions and access relevant workflows without loading unnecessary context.