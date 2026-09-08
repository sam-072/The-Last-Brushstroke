# The Last Brushstroke - Agent Instructions

## Read First

Before making any changes, read:

1. PROJECT_CONTEXT.md
2. docs/HLD.md
3. docs/LLD.md
4. docs/DECISIONS.md

Also inspect the existing Xcode project structure and related source files before implementing changes.

---

## Project Identity

Project name:

The Last Brushstroke

Platform:

macOS

Primary technologies:

- Swift
- SwiftUI
- AppKit where macOS integration is required
- SpriteKit for 2D painting/rendering
- Codable/local file persistence initially

The project is a living digital art experience in which a virtual painter progressively creates a painting over accumulated active painting time.

---

## Product Principles

The project should feel like a living digital painting rather than a conventional application.

The virtual painter should:

- progressively create artwork
- preserve painting progress
- resume from the exact previous state
- behave according to the configured activity mode
- eventually support a locked/screen-saver experience
- eventually allow visitors to leave messages and drawings

The first version must remain local and lightweight.

Do not introduce:

- backend services
- cloud storage
- databases
- AI services
- unnecessary third-party dependencies

unless explicitly approved.

Prefer Apple-native frameworks and APIs.

---

# Activity Policy

The default activity mode is:

LOCK_ONLY

The application should also support:

ALWAYS_ACTIVE

These are user-selectable modes.

---

## LOCK_ONLY Mode

In LOCK_ONLY mode:

- Painting must not progress while the Mac is unlocked.
- Painting should become active when the supported locked/screen-saver experience is active.
- Unlocking the Mac must stop painting.
- Painting should not progress while the Mac is asleep.
- If the Mac wakes while remaining locked and the locked/screen-saver experience is active, painting may resume.
- The exact supported surface for the locked experience must be determined by the macOS integration implementation.

Important:

Do not assume that arbitrary UI can be rendered over the macOS password/login screen.

The project should initially target the supported macOS Screen Saver / locked-away experience.

---

## ALWAYS_ACTIVE Mode

In ALWAYS_ACTIVE mode:

- Painting may progress while the application is active on the unlocked desktop.
- Painting may also progress while the supported locked/screen-saver experience is active.
- Sleep must pause painting.
- Waking may resume painting if the experience is active.

---

## System State vs Activity Policy

The Painting Engine must NOT directly depend on macOS lock/unlock APIs.

Keep these responsibilities separate:

System State:

- detects whether the Mac is locked/unlocked
- detects sleep/wake
- detects relevant application/system lifecycle events

Activity Policy:

- converts system state and user preference into a painting activity decision

Painting Engine:

- only understands whether it should start, pause, resume, or complete
- must not contain macOS lock/unlock implementation details

For example:

System State
    ↓
Activity Policy
    ↓
PAINT / PAUSE
    ↓
Painting Engine

---

# Painting Engine

Painting progress must be based on accumulated painting time.

Do NOT use raw wall-clock time as the source of truth for painting progress.

The engine must support:

- start
- pause
- resume
- completion
- persistence
- restoration

Painting time should only accumulate while the painting is actively running.

Example:

10:00 - Mac unlocked → PAUSED
10:20 - Mac locked → PAINTING
12:20 - Mac unlocked → PAUSED

Painting time accumulated:

2 hours

The 20 minutes spent unlocked before 10:20 must not be counted.

---

## Sleep Behavior

The Mac cannot actively render the painting while sleeping.

Therefore:

- sleep must pause active painting
- no painting time should be accumulated during sleep
- wake may resume painting if the configured Activity Policy allows it

Do not simulate painting progress during sleep in V1.

---

# Persistence

Persist enough information to restore the exact painting state after:

- application restart
- Mac restart
- lock/unlock
- sleep/wake

Persistence must preserve painting progress and the information required to reconstruct the visual state.

Use local Codable/file-based persistence initially.

---

# Architecture

Keep responsibilities separated.

Primary boundaries:

- UI
- Painting Engine
- Renderer
- Persistence
- System State
- Activity Policy
- Visitor System

Avoid putting business logic directly inside SwiftUI Views.

Avoid making one component responsible for unrelated concerns.

---

# Renderer

SpriteKit should be used for the painting/rendering layer where appropriate.

The renderer is responsible for:

- displaying the canvas
- rendering painting layers/strokes
- animating the painter
- visual transitions
- visual effects

The renderer should not become the source of truth for painting progress.

The Painting Engine remains the source of truth.

---

# Visitor System

Visitor functionality is part of the product vision but should remain modular.

A visitor may eventually be able to leave:

- name
- message
- small drawing/painting

Visitor data should initially remain local.

Visitor contributions should initially be stored separately from the main painting state.

Do not merge visitor artwork directly into the main painting engine until that behavior is explicitly designed.

Visitors must never gain access to:

- Finder
- user files
- other applications
- system settings
- the user's desktop
- arbitrary filesystem locations

The visitor experience must be sandboxed to the application's supported UI.

---

# Screen Saver / Locked Experience

Do NOT implement the Screen Saver first.

First build and validate the normal macOS application.

The initial development sequence should prove:

1. SwiftUI application
2. SpriteKit canvas
3. Painting Engine
4. Painting progress
5. Painter animation
6. Persistence
7. Activity Policy
8. System State integration
9. Locked/screen-saver experience
10. Visitor interaction
11. Screen Saver packaging/integration
12. Polish and performance

The exact macOS integration approach may evolve after the core experience is validated.

---

# Development Rules

Before implementing a major architectural change:

1. Explain the proposed change.
2. Identify affected files.
3. Keep changes modular.
4. Avoid unnecessary dependencies.
5. Prefer Apple-native frameworks.
6. Do not modify unrelated files.
7. Preserve existing architecture unless there is a clear reason to change it.
8. Update relevant documentation when architecture or behavior changes.

---

# Testing

Every major component should have tests where practical.

Prioritize tests for:

- PaintingClock
- PaintingProgressCalculator
- PaintingEngine
- ActivityPolicy
- persistence/restoration
- painting state transitions

System-level macOS behavior may require integration/manual testing.

---

# Implementation Discipline

Do not build the entire application at once.

Prefer small vertical milestones.

Each milestone should:

- compile
- run
- be testable
- preserve the existing architecture
- introduce only the required files

Do not create speculative infrastructure for future features unless it is necessary for the current milestone.

---

# Important Constraints

Do not:

- create a new repository
- run git init
- introduce a backend
- introduce a database
- introduce cloud services
- introduce AI
- add unnecessary dependencies
- couple the Painting Engine to macOS lock APIs
- implement visitor access to the user's filesystem
- assume arbitrary control over the macOS password/login screen
- implement Screen Saver integration before the core painting experience works

The Last Brushstroke should remain a macOS-first, Apple-native, modular project.