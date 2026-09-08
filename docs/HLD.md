# The Last Brushstroke - High Level Design

## 1. Overview

The Last Brushstroke is a macOS living digital art experience.

A virtual painter progressively creates artwork on a canvas.

The artwork is persistent and advances according to accumulated active painting time.

The system is designed around five major concerns:

1. Painting
2. Rendering
3. Persistence
4. System State and Activity Policy
5. Visitor Experience

The architecture is intentionally modular so that the normal macOS application can be developed and tested before integrating the locked/screen-saver experience.

---

## 2. High-Level Architecture

```text
                         ┌───────────────────────┐
                         │        SwiftUI        │
                         │          UI           │
                         └───────────┬───────────┘
                                     │
                                     ▼
                         ┌───────────────────────┐
                         │    App Coordinator    │
                         └───────────┬───────────┘
                                     │
             ┌───────────────────────┼───────────────────────┐
             │                       │                       │
             ▼                       ▼                       ▼
   ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
   │ Painting System │     │ Activity Policy │     │ Visitor System  │
   └────────┬────────┘     └────────┬────────┘     └────────┬────────┘
            │                       │                       │
            │                       ▼                       │
            │              ┌─────────────────┐              │
            │              │  System State   │              │
            │              │ Lock / Sleep    │              │
            │              └────────┬────────┘              │
            │                       │                       │
            ▼                       │                       ▼
   ┌─────────────────┐              │              ┌─────────────────┐
   │ Painting Engine │◄─────────────┘              │ Visitor Storage │
   └────────┬────────┘                             └─────────────────┘
            │
            ▼
   ┌─────────────────┐
   │    Renderer     │
   │    SpriteKit    │
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │   Canvas /      │
   │ Painter / Art   │
   └─────────────────┘

            ▲
            │
   ┌─────────────────┐
   │   Persistence   │
   │ Codable + Files │
   └─────────────────┘
```

---

## 3. Major Components

### 3.1 UI

Technology:

- SwiftUI

Responsibilities:

- application screens
- settings
- activity-mode selection
- painting screen/container
- visitor UI
- application-level controls

The UI must not contain painting business logic.

### 3.2 App Coordinator

Responsibilities:

- create application-level services
- connect system state to Activity Policy
- connect Activity Policy to Painting Engine
- coordinate persistence
- manage high-level application lifecycle

The coordinator should avoid becoming a general-purpose business-logic container.

---

## 4. Painting System

The Painting System consists of:

```text
Painting Engine
      │
      ├── Painting Clock
      ├── Progress Calculator
      └── Painting State
             │
             ▼
          Renderer
```

### 4.1 Painting Engine

The Painting Engine is the authoritative source of painting progress.

Responsibilities:

- start
- pause
- resume
- complete
- track active painting time
- calculate current progress
- restore state
- publish state changes

It does not know whether the Mac is locked.

### 4.2 Painting Clock

The Painting Clock tracks accumulated active painting time.

Conceptually:

```text
start()
pause()
resume()
elapsedPaintingTime
```

Only active periods contribute to elapsed painting time.

The clock must not simply calculate:

```text
currentTime - paintingStartTime
```

because inactive periods must be excluded.

### 4.3 Progress Calculator

Converts accumulated painting time into painting progress.

Conceptually:

```text
paintingTime
        ↓
progress
        ↓
painting stage
        ↓
visual state
```

Example:

```text
0%       → empty canvas
0-20%    → sky
20-40%   → mountains
40-60%   → lake
60-75%   → trees
75-90%   → reflections
90-99%   → details
100%     → final brushstroke
```

These values are illustrative and may be changed during implementation.

---

## 5. Renderer

SpriteKit is the primary rendering technology.

The renderer converts the authoritative painting state into visual output.

Possible responsibilities:

- canvas
- landscape layers
- brush strokes
- painter character
- brush movement
- animation
- studio environment

The renderer should be deterministic enough that the same persisted painting state can recreate the same visual result.

---

## 6. System State

The System State layer detects relevant macOS conditions.

Conceptual states:

```text
UNLOCKED
LOCKED
AWAKE
SLEEPING
```

Potential implementation technologies:

- AppKit
- NSWorkspace notifications
- relevant macOS lifecycle APIs
- Screen Saver APIs during later integration

The System State layer should not directly modify painting progress.

---

## 7. Activity Policy

Activity Policy converts system conditions into a painting decision.

Supported modes:

```text
LOCK_ONLY
ALWAYS_ACTIVE
```

### 7.1 LOCK_ONLY

```text
Unlocked
    ↓
PAUSE

Locked + supported experience active
    ↓
PAINT

Sleeping
    ↓
PAUSE

Wake + still locked
    ↓
PAINT
```

### 7.2 ALWAYS_ACTIVE

```text
Unlocked + application active
    ↓
PAINT

Locked + supported experience active
    ↓
PAINT

Sleeping
    ↓
PAUSE
```

The Activity Policy is the only layer that should combine:

- user activity preference
- lock state
- sleep state
- relevant experience state

---

## 8. Persistence

Initial implementation:

```text
Codable
   ↓
JSON / local file
   ↓
Application sandbox
```

The persisted model should contain enough information to restore:

- painting identity
- painting state
- accumulated painting time
- progress
- layers/strokes or deterministic information needed to recreate them
- completion status
- relevant configuration

Persistence should be independent of the renderer.

---

## 9. Visitor System

Visitor functionality is isolated from the Painting System.

Conceptually:

```text
Visitor UI
    │
    ├── Name
    ├── Message
    └── Drawing
            │
            ▼
      Visitor Storage
```

Visitor contributions should initially remain separate from the main painting state.

Future integration can be added as a separate workflow.

---

## 10. Screen Saver / Locked Experience

The locked experience is treated as a platform integration layer.

The architecture must not assume control over the macOS password/login screen.

The preferred progression is:

```text
Normal macOS App
      ↓
Validate Painting Experience
      ↓
Validate Activity Policy
      ↓
Validate System State
      ↓
Locked/Screen-Saver Prototype
      ↓
Screen Saver Integration
```

This minimizes platform risk.

---

## 11. Data Flow

Normal painting flow:

```text
System State
     ↓
Activity Policy
     ↓
PAINT / PAUSE
     ↓
Painting Engine
     ↓
Painting State
     ↓
Renderer
     ↓
Screen
```

Persistence flow:

```text
Painting Engine
     ↓
Persistence Service
     ↓
Local Codable File
```

Restoration flow:

```text
Local File
     ↓
Persistence Service
     ↓
Painting State
     ↓
Painting Engine
     ↓
Renderer
```

---

## 12. Security Boundary

The application must maintain a strict boundary between visitor functionality and the user's Mac.

Visitor functionality should operate only within the application experience.

It must not provide access to:

- arbitrary files
- Finder
- applications
- system settings
- desktop resources

Local persistence should use the application's sandbox/container.

---

## 13. V1 Architecture Goals

V1 architecture must prioritize:

- simplicity
- testability
- modularity
- Apple-native APIs
- deterministic painting state
- persistent progress
- clear system boundaries

The architecture should not prematurely optimize for future cloud, AI, or multiplayer functionality.
