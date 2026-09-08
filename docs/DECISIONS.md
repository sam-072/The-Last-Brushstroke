# The Last Brushstroke - Architecture Decisions

This document records important architectural and product decisions.

---

# ADR-001: macOS-First Application

## Decision

The Last Brushstroke will be developed as a macOS-first application.

## Technology

Primary technologies:

- Swift
- SwiftUI
- AppKit
- SpriteKit
- Foundation

## Reason

The product is specifically designed around the Mac desktop, locked/away experience, and Screen Saver capabilities.

A macOS-native implementation provides the best access to the required platform behavior.

---

# ADR-002: Build the Normal Application Before the Screen Saver

## Decision

Do not implement the Screen Saver bundle first.

Build and validate the normal macOS application before platform-specific Screen Saver integration.

## Reason

The core risks of the product are:

- painting progression
- persistence
- rendering
- activity policy
- system-state handling

These can be validated without immediately dealing with Screen Saver packaging and macOS locked-screen restrictions.

## Consequence

Screen Saver integration is a later milestone.

---

# ADR-003: Default Activity Mode is LOCK_ONLY

## Decision

The default activity mode is:

LOCK_ONLY

## Behavior

Unlocked:

```text
PAUSE
```

Locked + supported experience active:

```text
PAINT
```

Sleeping:

```text
PAUSE
```

Wake while still locked:

```text
PAINT
```

## Reason

The core product idea is that the virtual painter should work while the user is away from the Mac.

This makes returning to the Mac feel like discovering progress made in the user's absence.

---

# ADR-004: Support ALWAYS_ACTIVE as an Optional Mode

## Decision

The application should also support:

ALWAYS_ACTIVE

## Behavior

When awake and the experience is active:

```text
PAINT
```

Sleep:

```text
PAUSE
```

## Reason

Some users may prefer to watch the painter work while actively using the Mac.

Providing the mode as a preference allows both experiences without changing the Painting Engine.

---

# ADR-005: Painting Engine Must Be Independent of System State

## Decision

The Painting Engine must not directly depend on lock/unlock or sleep APIs.

## Architecture

```text
System State
     ↓
Activity Policy
     ↓
Painting Engine
```

## Reason

This keeps the core painting system platform-independent and testable.

It also allows future activity modes without rewriting the engine.

---

# ADR-006: Painting Progress Uses Accumulated Active Time

## Decision

Painting progress is based on accumulated active painting time.

Wall-clock time is not the source of truth.

## Example

If the painter runs for:

```text
20 minutes
```

then pauses for:

```text
2 hours
```

then resumes for:

```text
10 minutes
```

the total painting time is:

```text
30 minutes
```

not:

```text
2 hours 30 minutes
```

## Reason

The painting represents work performed by the virtual painter.

Inactive periods should not automatically count as painting work.

---

# ADR-007: Do Not Simulate Painting During Sleep in V1

## Decision

Sleep pauses painting.

No painting progress is accumulated while the Mac is sleeping.

## Reason

The Mac cannot actively render the painter while asleep.

Simulating progress during sleep would also create a difference between the conceptual painting activity and actual rendered activity.

This behavior can be reconsidered in a future version if desired.

---

# ADR-008: SpriteKit for Painting Rendering

## Decision

Use SpriteKit for the primary 2D painting renderer.

## Reason

SpriteKit provides:

- scene graph
- animation
- 2D rendering
- macOS support
- straightforward control over characters and brush movement

It is a good fit for the painter, canvas, and staged landscape animation.

---

# ADR-009: SwiftUI for Application UI

## Decision

Use SwiftUI for the application-level UI.

Use AppKit where macOS-specific functionality requires it.

## Reason

SwiftUI provides a clean modern UI architecture while AppKit remains necessary for certain macOS integrations.

---

# ADR-010: Codable + Local Files for V1 Persistence

## Decision

Use Codable models and local file storage for V1.

## No:

- backend
- cloud database
- remote synchronization
- database server

## Reason

The first version is a local Mac experience.

A lightweight persistence layer is sufficient and minimizes complexity.

---

# ADR-011: Painting State is the Source of Truth

## Decision

The Painting Engine owns the authoritative painting state.

The renderer does not own painting progress.

## Reason

The renderer can be recreated at any time from persisted state.

This is important for:

- application restart
- Screen Saver recreation
- window recreation
- future rendering changes

---

# ADR-012: Visitor Contributions are Separate from the Main Painting

## Decision

Visitor messages and drawings are initially stored separately from the main painting.

## Reason

Visitor integration into the painting introduces additional product rules.

For example:

- when should a contribution appear?
- does the painter react to it?
- can it modify a completed painting?
- how is visitor history maintained?

These decisions should be made explicitly later.

---

# ADR-013: Visitor Access Must Be Sandboxed

## Decision

Visitors may interact only with the Living Canvas experience.

They must not gain access to the user's Mac.

## Visitor Must Not Access

- Finder
- user files
- desktop
- applications
- system settings
- arbitrary filesystem locations

## Reason

The visitor experience exists specifically for safe interaction while the owner is away.

---

# ADR-014: No Assumption of Control Over the macOS Password Screen

## Decision

The project must not assume that custom application UI can be freely rendered over the actual macOS password/login screen.

## Reason

The macOS login/lock UI is system-controlled.

The project will target supported Screen Saver / locked-away surfaces rather than attempting unsupported password-screen injection.

---

# ADR-015: System State is an Input to Activity Policy

## Decision

System state should be represented separately from painting state.

Conceptually:

```text
System State
    +
User Activity Mode
    +
Experience State
        ↓
Activity Policy
        ↓
PAINT / PAUSE
```

## Reason

This keeps platform integration separate from business logic.

---

# ADR-016: Incremental Development

## Decision

The application will be developed through small working milestones.

## Order

```text
1. Documentation
2. SwiftUI shell
3. SpriteKit canvas
4. Painting Engine
5. Painting Clock
6. Progress calculation
7. Painter animation
8. Persistence
9. Activity Policy
10. System State
11. Locked experience
12. Visitor System
13. Screen Saver integration
14. Polish
```

## Reason

Each layer can be validated independently and architectural mistakes can be caught early.

---

# ADR-017: No Premature Infrastructure

## Decision

Do not build infrastructure for future features before it is needed.

Future possibilities such as:

- AI
- cloud sync
- multiple devices
- multiplayer
- analytics
- online visitor contributions

should not influence the V1 architecture unnecessarily.

## Reason

The first objective is to prove the core experience:

```text
Painter
+
Persistent Painting
+
Time-based Progress
+
Away/Locked Activity
```

---

# ADR-018: Deterministic Restoration

## Decision

The visual painting should be reconstructable from persisted painting state.

## Reason

The application must be able to restore the same artwork after:

- restart
- wake
- lock/unlock
- renderer recreation

The persisted state should therefore contain enough information to reproduce the visual result.

---

# ADR-019: Local-First Visitor Data

## Decision

Visitor data remains local in V1.

## Reason

The visitor feature does not require a server for the initial product concept.

Local storage keeps the architecture simple and avoids introducing authentication, networking, or privacy infrastructure prematurely.

---

# ADR-020: Documentation is Part of the Architecture

## Decision

Changes to important architecture or product behavior must update the relevant documentation.

Relevant documents:

```text
AGENTS.md
PROJECT_CONTEXT.md
docs/HLD.md
docs/LLD.md
docs/DECISIONS.md
```

## Reason

The project will be developed with AI coding agents as well as manually.

Keeping architectural intent documented reduces accidental divergence between implementation and product requirements.
