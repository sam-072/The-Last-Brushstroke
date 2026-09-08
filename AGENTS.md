# Animated Painting Lock-Screen - Agent Instructions

## Read First

Before making changes, read:

PROJECT_CONTEXT.md

Also inspect the existing project structure and related source files.

## Project Principles

- macOS-first application
- Swift
- SwiftUI
- AppKit where macOS integration is required
- SpriteKit for painting/rendering
- Codable/local persistence initially
- No backend initially
- No cloud dependency initially
- No AI dependency initially

## Architecture

Keep responsibilities separated:

- UI
- Painting Engine
- Renderer
- Persistence
- System State
- Visitor System

Avoid putting business logic directly inside SwiftUI Views.

## Painting Engine

Painting progress must be based on accumulated painting time.

Do not use raw wall-clock time as the source of truth.

The engine must support:

- start
- pause
- resume
- completion
- persistence

## Persistence

Persist enough information to restore the exact painting state after:

- app restart
- Mac restart
- lock/unlock
- sleep/wake

## Visitor System

Visitor data should initially remain local.

A visitor can leave:

- name
- message
- drawing

## Development Rules

Before implementing a major architectural change:

1. Explain the proposed change.
2. Identify affected files.
3. Keep changes modular.
4. Avoid unnecessary dependencies.
5. Prefer Apple-native frameworks.

## Testing

Every major component should have tests where practical.

Do not modify unrelated files.

## Important

Do not implement the Screen Saver first.

Build and validate the normal macOS application first.