# AI-Powered Smart Notes App

A Flutter-based smart note-taking application with rich text editing, AI-powered summarization and keyword extraction, voice-to-text support, and cloud synchronization. It integrates local database storage with Drift and Firebase for cloud backup.

---

## Features

- **Rich Text Editor:**
  - Edit notes with formatting: bold, italic, underline, color, undo/redo.
  - Voice-to-text input with start/stop listening controls.
  - Display extracted keywords as interactive chips.
  
- **AI Summarization:**
  - Generate smart summaries of notes using OpenAI API.
  - Display summary results via snackbars.

- **Notes Synchronization:**
  - Sync notes between local database and cloud storage.
  - One-way and two-way sync buttons for manual control.

- **View and Search Notes:**
  - Browse all saved notes in a visually appealing, color-coded list.
  - Expandable note tiles to show full content and timestamp.
  - Real-time search filtering on note content.
  
- **Local Database:**
  - Uses Drift (formerly Moor) for efficient SQLite local storage.
  - Notes include content and timestamps.

- **Cloud Sync:**
  - Sync notes data with Firebase or other cloud storage (configurable in provider).
  
---
## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Firebase project configured (for cloud sync)
- OpenAI API key (for AI features)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Yurembam375/AI-Powered-Smart-Notes-App.git
   cd AI-Powered-Smart-Notes-App
