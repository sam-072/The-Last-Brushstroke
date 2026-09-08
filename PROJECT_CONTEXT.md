# The Last Brushstroke - Project Context

## 1. Project Overview

The Last Brushstroke is a macOS living digital art experience.

The core concept is a virtual painter living inside a small artist studio on the Mac.

The painter progressively creates a landscape painting on a canvas.

The artwork should feel alive and persistent rather than being a fixed animation or video.

The painting is created progressively over accumulated active painting time.

When the painter stops, the painting must remain exactly where it was.

When the painter starts again, it must continue from the previous state rather than restarting.

---

# 2. Core Product Vision

The experience should feel like the user owns a tiny virtual artist studio.

Inside the studio:

- a painter character exists
- a canvas is displayed
- the painter progressively creates artwork
- the environment can eventually have lighting, atmosphere, sounds, and other subtle details
- the painting evolves over time

The initial landscape may be created in stages such as:

1. Sky
2. Mountains
3. Lake
4. Trees
5. Reflections
6. Fine details
7. Final brushstroke

These stages are conceptual and may change during implementation.

The final painting should represent the accumulated work of the virtual painter.

---

# 3. Most Important Behavioral Requirement

The painter should normally work when the user is away from the Mac.

Default behavior:

LOCK_ONLY

In LOCK_ONLY mode:

- Mac unlocked → painter stopped
- Mac locked / supported locked-away experience active → painter works
- Mac unlocked again → painter stops
- Mac sleeping → painter stops
- Mac wakes while still locked → painter may resume

This means the painting progresses primarily while the user is not actively using the Mac.

---

# 4. Optional Activity Modes

The product should support two activity modes.

## Mode 1 - LOCK_ONLY

Default mode.

Behavior:

UNLOCKED
→ PAUSE

LOCKED + EXPERIENCE ACTIVE
→ PAINT

SLEEPING
→ PAUSE

WAKE + STILL LOCKED
→ PAINT

This mode is intended to make the painter feel like it works while the user is away.

---

## Mode 2 - ALWAYS_ACTIVE

Optional mode.

Behavior:

UNLOCKED + APP/EXPERIENCE ACTIVE
→ PAINT

LOCKED + EXPERIENCE ACTIVE
→ PAINT

SLEEPING
→ PAUSE

WAKE
→ RESUME if the experience is active

This mode is intended for users who want the painter to continue working while they are also using the Mac.

---

# 5. Important macOS Constraint

The project must not assume that it can freely draw custom UI over the macOS password/login screen.

The first implementation should therefore focus on the supported macOS locked/screen-saver experience.

The architecture should allow the locked experience to be integrated later without coupling the Painting Engine to macOS-specific APIs.

Actual Screen Saver integration should happen after the normal application and painting system have been validated.

---

# 6. Painting Time Model

Painting progress must be based on accumulated active painting time.

Wall-clock time must not be the source of truth.

The system should track something conceptually similar to:

accumulatedPaintingTime

The Painting Engine should only increase this value while the painter is actively painting.

Example:

09:00
Mac unlocked
Painting paused

10:00
Mac locked
Painting starts

12:30
Mac still locked
Painting continues

13:00
Mac unlocked
Painting pauses

Painting time accumulated:

3 hours

The unlocked period from 09:00–10:00 is not counted.

---

# 7. Sleep Behavior

A sleeping Mac cannot actively render the experience.

Therefore V1 should not simulate painting progress while the Mac is asleep.

Example:

10:00 - locked and awake → painting
11:00 - Mac sleeps → painting pauses
13:00 - Mac wakes while still locked → painting resumes

Only:

10:00–11:00

counts as active painting time.

---

# 8. Painting State Machine

The core Painting Engine should use a state model similar to:

IDLE
  ↓
PAINTING
  ↓
PAUSED
  ↓
PAINTING
  ↓
COMPLETED
  ↓
NEW PAINTING

Possible transitions:

IDLE → PAINTING
IDLE → PAUSED

PAINTING → PAUSED
PAINTING → COMPLETED

PAUSED → PAINTING

COMPLETED → NEW PAINTING

The exact implementation may evolve.

The important principle is that system state and activity policy determine whether the engine should be active.

---

# 9. System State

The application needs a system-state layer that can understand relevant macOS conditions.

Conceptual states include:

UNLOCKED
LOCKED
AWAKE
SLEEPING

These states should not directly control the Painting Engine.

Instead:

System State
→ Activity Policy
→ Painting decision

---

# 10. Activity Policy

The Activity Policy is responsible for converting:

- current system state
- selected activity mode
- current application/experience state

into:

PAINT
or
PAUSE

This prevents the Painting Engine from knowing anything about macOS lock/unlock APIs.

---

# 11. Painting Engine Responsibilities

The Painting Engine is responsible for:

- starting painting
- pausing painting
- resuming painting
- tracking accumulated painting time
- calculating painting progress
- determining completion
- restoring painting state
- exposing current painting state

It should not be responsible for:

- detecting Mac lock state
- detecting sleep state
- rendering SpriteKit nodes
- drawing SwiftUI views
- storing visitor messages

---

# 12. Renderer Responsibilities

The renderer is responsible for visual representation.

SpriteKit is the preferred rendering technology for the 2D painting experience.

The renderer should handle:

- canvas
- painting layers
- brush strokes
- painter character
- brush movement
- painting animations
- visual effects
- studio environment

The renderer should not become the authoritative source of painting progress.

---

# 13. Persistence

Painting state must survive:

- application restart
- Mac restart
- lock/unlock
- sleep/wake

The persisted state should contain enough information to reconstruct the painting accurately.

Initial persistence technology:

Swift Codable + local files

No backend is required for V1.

---

# 14. Visitor Experience

A future visitor mode allows someone interacting with the locked/away experience to leave a small contribution.

A visitor can provide:

- name
- message
- small drawing/painting

The visitor contribution should initially be stored separately from the main painting.

Potential future behavior:

Visitor contribution
→ Visitor History
→ optional integration into the main painting

This should not be implemented as an implicit side effect.

The integration rules should be explicitly designed later.

---

# 15. Visitor Security Boundary

The visitor experience must be limited to the Living Canvas application.

A visitor must not gain access to:

- Finder
- user's files
- user's applications
- desktop
- system settings
- arbitrary filesystem paths

Visitor data should be stored using the application's local sandbox/storage.

---

# 16. Future Vision

Possible future features include:

- painting timeline
- completed painting gallery
- multiple paintings
- visitor history
- visitor artwork integration
- studio day/night cycle
- ambient sounds
- painter personality
- more detailed animations
- multiple virtual painters
- additional art styles
- AI-assisted painting or story generation

These are future possibilities, not V1 requirements.

Do not introduce infrastructure for these features prematurely.

---

# 17. V1 Scope

The first working prototype should prove:

1. macOS application launches
2. SwiftUI UI works
3. SpriteKit canvas renders
4. basic landscape exists
5. painter can progressively paint
6. painting progress is based on accumulated active painting time
7. painting can pause
8. painting can resume
9. painting state persists
10. activity mode can determine PAINT/PAUSE
11. basic system-state integration can control activity
12. the architecture is ready for locked/screen-saver integration

Visitor functionality and final Screen Saver packaging can follow after the core loop is stable.

---

# 18. Architecture

High-level architecture:

The Last Brushstroke
│
├── UI
│
├── Painting System
│   ├── Painting Engine
│   ├── Painting Clock
│   ├── Progress Calculator
│   └── Renderer
│
├── System State
│   ├── Lock State
│   ├── Sleep/Wake
│   └── Lifecycle
│
├── Activity Policy
│   ├── LOCK_ONLY
│   └── ALWAYS_ACTIVE
│
├── Persistence
│
└── Visitor System

The major rule is:

System State must not be embedded inside the Painting Engine.

---

# 19. Development Strategy

Build the normal macOS application first.

Do not begin by implementing a Screen Saver bundle.

Recommended sequence:

1. Documentation
2. Project skeleton
3. SwiftUI shell
4. SpriteKit canvas
5. Painting Engine
6. Painting Clock
7. Painting Progress
8. Renderer
9. Persistence
10. Activity Policy
11. System State integration
12. Painter experience
13. Locked/screen-saver prototype
14. Visitor experience
15. Screen Saver integration
16. Polish and optimization

Each stage should produce a working increment.

---

# 20. Technology Choices

Primary:

- Swift
- SwiftUI
- AppKit
- SpriteKit
- Foundation
- Codable
- Local file storage

Potential macOS integration APIs may include:

- ScreenSaver framework
- NSWorkspace notifications
- Service Management / SMAppService
- AppKit lifecycle APIs

Exact APIs should be introduced only when the corresponding milestone requires them.

---

# 21. Non-Goals for V1

V1 should not require:

- backend
- cloud
- database server
- account/login system
- internet connectivity
- AI
- remote synchronization
- multiplayer
- complex analytics

The experience should work locally on the Mac.

---

# 22. Guiding Principle

The most important product principle is:

The painting is a persistent state, not an animation that restarts.

The painter should feel like a tiny artist who continues working on the same artwork over time.

When the user returns, they should be able to see what changed since the last time they were away.