# The Last Brushstroke - Low Level Design

## 1. Purpose

This document defines the initial low-level structure of The Last Brushstroke.

The design is intentionally incremental.

Only components required by the current milestone should be implemented.

---

## 2. Initial Project Structure

```text
The Last Brushstroke/
│
├── App/
│   ├── The_Last_BrushstrokeApp.swift
│   └── AppCoordinator.swift
│
├── Core/
│   ├── Models/
│   │   ├── Painting.swift
│   │   ├── PaintingLayer.swift
│   │   ├── BrushStroke.swift
│   │   ├── PaintingState.swift
│   │   ├── PaintingStatus.swift
│   │   ├── ActivityMode.swift
│   │   ├── Visitor.swift
│   │   ├── VisitorMessage.swift
│   │   └── VisitorDrawing.swift
│   │
│   ├── State/
│   │   └── CanvasStateStore.swift
│   │
│   └── Persistence/
│       ├── PersistenceService.swift
│       └── FileStorage.swift
│
├── Painting/
│   ├── Engine/
│   │   ├── PaintingEngine.swift
│   │   ├── PaintingClock.swift
│   │   └── PaintingProgressCalculator.swift
│   │
│   ├── Renderer/
│   │   ├── PaintingScene.swift
│   │   ├── CanvasNode.swift
│   │   ├── PainterNode.swift
│   │   └── BrushStrokeRenderer.swift
│   │
│   └── Animation/
│       ├── PainterAnimationController.swift
│       └── BrushAnimation.swift
│
├── System/
│   ├── Lifecycle/
│   │   └── AppLifecycleMonitor.swift
│   │
│   ├── Sleep/
│   │   └── SleepMonitor.swift
│   │
│   └── Lock/
│       └── LockMonitor.swift
│
├── Policy/
│   └── ActivityPolicy.swift
│
├── UI/
│   ├── Home/
│   │   └── HomeView.swift
│   │
│   ├── Painting/
│   │   └── PaintingView.swift
│   │
│   ├── Settings/
│   │   └── SettingsView.swift
│   │
│   └── Visitor/
│       ├── VisitorView.swift
│       ├── MessageView.swift
│       └── DrawingView.swift
│
└── Resources/
    ├── Paintings/
    ├── Characters/
    ├── Studio/
    ├── Brushes/
    ├── Sounds/
    └── Preview/
```

This structure is a target architecture.

Do not create every file immediately.

---

## 3. Core Models

### 3.1 Painting

Represents a single painting.

Conceptual properties:

```text
id
title
createdAt
updatedAt
state
accumulatedPaintingTime
progress
layers
```

The exact property types may evolve.

### 3.2 PaintingLayer

Represents one logical layer of the painting.

Examples:

```text
sky
mountains
lake
trees
reflections
details
```

A layer may contain multiple strokes.

### 3.3 BrushStroke

Represents an individual painting operation.

Potential information:

```text
id
layerID
brushType
points
duration
opacity
size
```

The model should contain only information necessary to reproduce the visual result.

### 3.4 PaintingStatus

Suggested enum:

```text
IDLE
PAINTING
PAUSED
COMPLETED
```

### 3.5 ActivityMode

Suggested enum:

```text
LOCK_ONLY
ALWAYS_ACTIVE
```

Default:

```text
LOCK_ONLY
```

---

## 4. PaintingClock

The PaintingClock is responsible for active painting duration.

Required operations:

```text
start()
pause()
resume()
reset()
```

Required information:

```text
accumulatedDuration
isRunning
```

The clock should use a monotonic timing mechanism where appropriate so that system clock changes do not corrupt active-duration calculations.

The clock should not know anything about lock state.

---

## 5. PaintingEngine

The PaintingEngine is the central business component.

Conceptual API:

```text
start()
pause()
resume()
complete()
restore(state)
```

It exposes:

```text
currentPainting
status
progress
accumulatedPaintingTime
```

Responsibilities:

1. manage painting state
2. manage PaintingClock
3. calculate progress
4. trigger completion
5. expose state changes
6. restore persisted state

It does not:

- detect lock state
- detect sleep
- render SpriteKit nodes
- manage visitor data

---

## 6. PaintingProgressCalculator

Input:

```text
accumulatedPaintingTime
```

Output:

```text
progress
currentStage
```

Conceptually:

```text
paintingTime → normalized progress
```

For example:

```text
progress = accumulatedPaintingTime / totalPaintingDuration
```

clamped to:

```text
0.0 ... 1.0
```

Stage mapping can then convert progress into painting stages.

---

## 7. ActivityPolicy

The ActivityPolicy determines whether the PaintingEngine should be active.

Input:

```text
ActivityMode
SystemState
ExperienceState
```

Output:

```text
PAINT
PAUSE
```

### 7.1 LOCK_ONLY

Pseudo-logic:

```text
if sleeping:
    PAUSE

else if locked && lockedExperienceActive:
    PAINT

else:
    PAUSE
```

### 7.2 ALWAYS_ACTIVE

Pseudo-logic:

```text
if sleeping:
    PAUSE

else if experienceActive:
    PAINT

else:
    PAUSE
```

The exact definition of `experienceActive` can evolve as the application and Screen Saver integration mature.

---

## 8. SystemState

Suggested model:

```text
SystemState

lockState:
    LOCKED
    UNLOCKED
    UNKNOWN

powerState:
    AWAKE
    SLEEPING
    UNKNOWN
```

SystemState should be observable by the coordinator/policy layer.

---

## 9. LockMonitor

Responsibilities:

- observe relevant macOS lock/unlock state
- publish state changes
- avoid controlling the PaintingEngine directly

The implementation should use supported macOS APIs.

The monitor should be replaceable so that tests can use a mock implementation.

---

## 10. SleepMonitor

Responsibilities:

- observe sleep
- observe wake
- publish state changes

Sleep should always result in:

```text
PAUSE
```

No painting progress should be simulated while sleeping.

---

## 11. Activity Decision Flow

```text
             ┌─────────────────┐
             │  System State   │
             └────────┬────────┘
                      │
                      ▼
             ┌─────────────────┐
             │ Activity Policy │
             └────────┬────────┘
                      │
                PAINT / PAUSE
                      │
                      ▼
             ┌─────────────────┐
             │ Painting Engine │
             └─────────────────┘
```

This is a key architectural boundary.

---

## 12. PersistenceService

Responsibilities:

```text
save(painting)
load()
delete(painting)
```

Initial implementation:

```text
Codable
+
JSON
+
local application storage
```

Persistence should be asynchronous if required by the UI/runtime, but the first implementation should remain simple.

---

## 13. Persistence Model

Persist at minimum:

```text
paintingID
paintingStatus
accumulatedPaintingTime
progress
painting layers/strokes
createdAt
updatedAt
```

If the renderer requires additional deterministic information to recreate the painting, that information should also be persisted.

---

## 14. Renderer

SpriteKit classes:

```text
PaintingScene
CanvasNode
PainterNode
BrushStrokeRenderer
```

### PaintingScene

Responsibilities:

- own SpriteKit scene
- coordinate canvas and painter nodes
- receive painting-state updates

### CanvasNode

Responsibilities:

- display canvas
- contain painting layers
- render landscape

### PainterNode

Responsibilities:

- painter character
- position
- movement
- idle/working animations

### BrushStrokeRenderer

Responsibilities:

- visually render brush strokes
- animate stroke application
- map logical stroke data to SpriteKit visuals

The renderer must not determine authoritative progress.

---

## 15. UI

SwiftUI views should primarily compose the experience.

Example:

```text
PaintingView
      │
      ▼
SpriteKitView
      │
      ▼
PaintingScene
```

Settings:

```text
SettingsView
      │
      ▼
ActivityMode
```

The UI should communicate with application services rather than directly implementing painting rules.

---

## 16. Visitor Models

### Visitor

Conceptual:

```text
id
name
createdAt
message
drawing
```

### VisitorMessage

Conceptual:

```text
text
createdAt
```

### VisitorDrawing

Conceptual:

```text
drawingData
createdAt
```

The drawing representation should be chosen based on the final drawing implementation.

Possible V1 representation:

- vector strokes
- Codable point data

Avoid storing arbitrary executable/file content.

---

## 17. Visitor Storage

Visitor data should be stored separately.

Conceptually:

```text
Visitor UI
     ↓
VisitorService
     ↓
VisitorStorage
     ↓
Local files
```

VisitorStorage must not directly modify PaintingEngine state.

---

## 18. AppCoordinator

The coordinator connects the major systems.

Conceptually:

```text
SystemState
      ↓
ActivityPolicy
      ↓
PaintingEngine
      ↓
Renderer

PaintingEngine
      ↓
PersistenceService
```

The coordinator should:

- initialize dependencies
- observe system state
- evaluate activity policy
- start/pause/resume PaintingEngine
- trigger persistence
- manage application lifecycle

---

## 19. Testing

Priority unit tests:

### PaintingClock

Test:

- start
- pause
- resume
- repeated pause
- repeated resume
- accumulated duration

### PaintingProgressCalculator

Test:

- zero progress
- intermediate progress
- completion
- clamping

### PaintingEngine

Test:

- state transitions
- start
- pause
- resume
- completion
- restoration

### ActivityPolicy

Test all combinations of:

- LOCK_ONLY
- ALWAYS_ACTIVE
- LOCKED
- UNLOCKED
- SLEEPING
- AWAKE

### Persistence

Test:

- save
- load
- restore
- invalid/corrupted data handling

---

## 20. Dependency Direction

Preferred dependency direction:

```text
UI
 ↓
Application / Coordinator
 ↓
Policy / Services
 ↓
Core Models
```

Painting:

```text
Painting Engine
 ↓
Core Models

Renderer
 ↓
Painting State
```

System:

```text
macOS APIs
 ↓
System Monitors
 ↓
Activity Policy
 ↓
Painting Engine
```

The Painting Engine must not depend directly on macOS APIs.

---

## 21. Incremental Implementation

Do not implement this entire LLD in one change.

Recommended order:

### Milestone 1

```text
SwiftUI
+
SpriteKit
+
basic canvas
```

### Milestone 2

```text
PaintingClock
+
PaintingEngine
+
basic progress
```

### Milestone 3

```text
Painter
+
brush animation
+
landscape stages
```

### Milestone 4

```text
Persistence
```

### Milestone 5

```text
ActivityMode
+
ActivityPolicy
```

### Milestone 6

```text
LockMonitor
+
SleepMonitor
```

### Milestone 7

```text
Locked/screen-saver experience
```

### Milestone 8

```text
Visitor System
```

### Milestone 9

```text
Screen Saver packaging
+
polish
```
