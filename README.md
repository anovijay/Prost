# Prost 🇩🇪

A minimalist German learning app for iOS, built with SwiftUI. Learn German through focused, bite-sized modules covering Reading, Listening, Speaking (Sprechen), and Writing.

## Features

### ✅ Reading Comprehension (Available)
- **Level-based dashboard** (A1, A2, B1, B2) showing progress and scores
- **Read German passages** with natural, contextual content
- **Answer multiple-choice questions** to test comprehension
- **Review wrong answers** with correct options highlighted
- **Retake functionality** to improve scores

### 🚧 Coming Soon
- **Listening** - Audio comprehension exercises
- **Sprechen** - Speaking practice with pronunciation feedback
- **Writing** - Written exercises and essay practice

## Architecture

Prost follows a **modular, feature-based architecture** with strict separation of concerns:

```
Prost/
├── Models/              # Domain models (data structures)
├── Views/               # UI components organized by feature
│   ├── Reading/         # Reading module screens
│   └── Components/      # Reusable UI components
├── SampleData/          # Mock data for prototyping
├── Theme/               # Design system (colors, typography, spacing)
└── ContentView.swift    # App entry point with tab navigation
```

### Design Principles
- **DRY (Don't Repeat Yourself)**: Components are extracted and reusable
- **Single Responsibility**: Each file has one clear purpose
- **Minimalism**: Clean UI with only essential elements
- **Scalability**: Easy to add new modules (Listening, Writing, etc.)

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- macOS 14.0 or later

### Installation

1. Clone the repository:
```bash
git clone https://github.com/anovijay/Prost.git
cd Prost
```

2. Open the project in Xcode:
```bash
open Prost.xcodeproj
```

3. Select your target device/simulator and press `⌘R` to run

### Project Structure

```
Prost/
├── Prost/
│   ├── Models/
│   │   └── ReadingModels.swift           # Reading domain models
│   ├── Views/
│   │   ├── Reading/
│   │   │   ├── ReadingDashboardView.swift   # Level selection
│   │   │   ├── LevelPassagesView.swift      # Passage list
│   │   │   ├── ReadingPassageView.swift     # Read passage
│   │   │   ├── ReadingQuestionsView.swift   # Answer questions
│   │   │   └── ReadingResultsView.swift     # View results
│   │   ├── Components/
│   │   │   ├── LevelProgressCard.swift      # Reusable level card
│   │   │   └── QuestionCardView.swift       # Reusable question UI
│   │   └── PlaceholderTabView.swift         # Placeholder tabs
│   ├── SampleData/
│   │   └── ReadingSamples.swift             # Mock passages & levels
│   ├── Theme.swift                          # Design system
│   ├── ReadingUIComponents.swift            # Theme components
│   ├── ContentView.swift                    # Tab navigation
│   └── ProstApp.swift                       # App entry point
├── ProstTests/                              # Unit tests
└── ProstUITests/                            # UI tests
```

## Usage

### Reading Module Flow

1. **Dashboard** → Select a level (A1, A2, B1, B2)
2. **Passage List** → Choose a passage to read
3. **Read** → Read the German text carefully
4. **Questions** → Answer multiple-choice questions
5. **Results** → Review score and wrong answers
6. **Retake** → Try again to improve

### Current Content

- **A2 Level**: "Ein Tag in Berlin" (A Day in Berlin)
  - 3 comprehension questions
  - Story about Lena's day in Berlin

## Contributing

Contributions are welcome! To add a new module (e.g., Listening):

1. Create `Models/ListeningModels.swift` for domain models
2. Create `Views/Listening/` folder with feature screens
3. Create `SampleData/ListeningSamples.swift` for mock data
4. Update `ContentView.swift` to include the new tab
5. Reuse existing components from `Views/Components/`

## Roadmap

- [ ] Add more passages for each level
- [ ] Implement Listening module with audio playback
- [ ] Add Sprechen (Speaking) module with speech recognition
- [ ] Implement Writing module with text input
- [ ] Add progress persistence (Core Data / CloudKit)
- [ ] Implement spaced repetition algorithm
- [ ] Add vocabulary flashcards
- [ ] Support offline mode
- [ ] Add user authentication
- [ ] Implement leaderboards and achievements

## Design System

### Colors
- **Background**: Light gradient (96-92% white)
- **Cards**: Pure white with subtle shadows
- **Accent**: iOS system accent color
- **Text**: Primary and secondary system colors

### Typography
- **Hero**: Large Title, Bold, Rounded
- **Title**: Headline, Semibold, Rounded
- **Body**: Body, Regular, Rounded
- **Caption**: Footnote, Regular, Rounded

### Spacing
- **Screen padding**: 20pt
- **Section spacing**: 20pt
- **Item spacing**: 12pt

## Tech Stack

- **SwiftUI** - Declarative UI framework
- **Swift 5.9+** - Modern Swift features
- **Xcode 15** - IDE and build tools
- **Git** - Version control

## License

This project is currently private. All rights reserved.

## Contact

**Author**: Anoop Vijayan  
**Repository**: [https://github.com/anovijay/Prost.git](https://github.com/anovijay/Prost.git)

---

**Prost!** 🍻 (Cheers in German!)

