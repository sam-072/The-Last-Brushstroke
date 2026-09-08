# Animated Painting Lock-Screen

## Project Overview

Animated Painting Lock-Screen is a macOS experience where a virtual painter progressively creates an artwork.

The painting evolves over time.

The core experience is:

1. Painter starts creating a painting.
2. Painting progresses gradually.
3. When the Mac is locked/screen saver becomes active, painting pauses.
4. When the user returns, painting resumes.
5. Progress persists across app restarts.
6. When a painting is completed, a new painting/canvas can eventually begin.

The experience should feel like a small virtual artist living inside the user's Mac.

---

# Product Concept

Working concept/name:

"The Last Brushstroke"

The application presents a virtual studio/painter.

The painter progressively creates a landscape:

1. Sky
2. Mountains
3. Lake
4. Trees
5. Reflections
6. Fine details
7. Final brushstroke

The painting should not simply appear instantly.

The user should be able to observe the painting developing over time.

---

# Core Behavior

The painting engine is driven by painting time rather than wall-clock time.

State machine:

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

Locking/sleeping pauses the painting.

Unlocking/waking resumes it.

The exact progress must persist.

---

# Visitor Feature

When the Mac is locked and another person comes to the user's desk while the owner is away, that person should be able to leave a small message.

The visitor can provide:

- Name
- Message

The visitor should also have a small drawing/painting area where they can draw something.

The visitor's drawing and message are stored locally.

The feature should feel like leaving a note/artwork for the owner.

---

# Initial Architecture

Platform:

macOS

Language:

Swift

UI:

SwiftUI

macOS integration:

AppKit

Rendering:

SpriteKit

Persistence:

Codable + JSON/local files initially

Backend:

None initially

Cloud:

None initially

AI:

None initially

Internet dependency:

None initially

---

# Main Components

Painting Engine

Responsible for:

- Painting progress
- Painting stages
- Brush strokes
- Timing
- Pause/resume
- Completion

Renderer

Responsible for:

- Displaying painting
- Animating brush strokes
- Rendering the canvas
- Showing painter activity

Persistence Layer

Responsible for:

- Saving painting state
- Restoring state
- Saving visitor messages
- Saving visitor drawings

Lock/Screen State Manager

Responsible for:

- Detecting relevant macOS state
- Pausing painting
- Resuming painting

Visitor System

Responsible for:

- Visitor name
- Visitor message
- Visitor drawing
- Saving visitor entries

---

# Core Models

Painting

Layer

BrushStroke

PaintingState

Visitor

Message

VisitorDrawing

---

# Important Design Principle

Build the normal macOS application first.

Do NOT begin with the Screen Saver implementation.

First prove:

1. Painting engine works.
2. Painting progresses correctly.
3. Pause/resume works.
4. Persistence works.
5. Visitor feature works.
6. Renderer works.

Then integrate the experience into the macOS Screen Saver/lock-screen environment.

---

# Development Strategy

Phase 1:
Project skeleton

Phase 2:
Painting engine

Phase 3:
SpriteKit renderer

Phase 4:
Persistence

Phase 5:
Pause/resume

Phase 6:
Virtual painter experience

Phase 7:
Visitor message + drawing

Phase 8:
macOS lock/screen state integration

Phase 9:
Screen Saver integration

Phase 10:
Polish and performance

---

# Important Rule

Do not introduce a backend, database server, authentication system, cloud storage, or AI unless explicitly decided later.

Keep the first version local and lightweight.

---

# Current Goal

Create the first working macOS prototype.

The prototype should:

- Open a window
- Display a canvas
- Show a landscape being painted progressively
- Persist painting progress
- Pause/resume correctly
- Have clean architecture so the Screen Saver can be added later