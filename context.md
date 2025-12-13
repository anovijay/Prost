# Prost - Technical Context & Architecture

## Project Overview

Prost is a minimalist German learning iOS application built with SwiftUI, following a modular, feature-based architecture. The app is designed around four core learning modules: Reading, Listening, Sprechen (Speaking), and Writing.

## Architecture Principles

### 1. Modular Feature-Based Architecture
- Each learning module (Reading, Listening, etc.) is self-contained
- Features are organized in dedicated folders under `Views/`
- Modules share common components but remain independent

### 2. DRY (Don't Repeat Yourself)
- Reusable UI components extracted to `Views/Components/`
- Shared models in `Models/`
- Common theme elements in `Theme.swift`
- Sample data separated into `SampleData/`

### 3. Single Responsibility Principle
- Each file has one clear purpose
- Views handle only presentation logic
- Models contain only data structures and business logic
- Components are focused and composable

### 4. Separation of Concerns
- **Models**: Data structures and domain logic (no UI)
- **Views**: UI presentation (no business logic)
- **SampleData**: Mock data for development/testing
- **Theme**: Design system (colors, typography, spacing)

### 5. Scalability
- Easy to add new modules by following existing patterns
- Components designed for reuse across modules
- Theme system allows consistent styling app-wide

## Project Structure

```
Prost/
├── Prost/                          # Main app target
│   ├── Models/                     # Domain models
│   ├── Views/                      # UI layer
│   │   ├── Reading/                # Reading feature module
│   │   ├── Components/             # Reusable components
│   │   └── PlaceholderTabView.swift
│   ├── SampleData/                 # Mock data
│   ├── Theme.swift                 # Design system
│   ├── ReadingUIComponents.swift   # Theme components
│   ├── ContentView.swift           # App coordinator
│   └── ProstApp.swift              # App entry point
├── ProstTests/                     # Unit tests
├── ProstUITests/                   # UI tests
└── Prost.xcodeproj/               # Xcode project
```

---

## File-by-File Breakdown

### Entry Point

#### `ProstApp.swift`
**Scope**: App lifecycle and window configuration  
**Responsibility**: 
- Define app entry point with `@main`
- Initialize root view (`ContentView`)
- Configure app-level settings (if needed)

**Boundaries**:
- ✅ App lifecycle management
- ✅ Window scene configuration
- ❌ No business logic
- ❌ No UI layout

**Dependencies**: ContentView.swift

---

#### `ContentView.swift`
**Scope**: Top-level navigation coordinator  
**Responsibility**:
- Define TabView with 4 tabs (Reading, Listening, Sprechen, Writing)
- Route users to appropriate feature modules
- Maintain tab selection state

**Boundaries**:
- ✅ Tab navigation structure
- ✅ Tab item configuration (labels, icons)
- ❌ No feature-specific logic
- ❌ No data management

**Business Rules**:
- Exactly 4 tabs: Reading, Listening, Sprechen, Writing
- Reading tab is the first/default tab
- Each tab displays its feature dashboard or placeholder

**Dependencies**: 
- ReadingDashboardView.swift
- PlaceholderTabView.swift

---

### Models Layer

#### `Models/ReadingModels.swift`
**Scope**: Domain models for the Reading feature  
**Responsibility**:
- Define data structures for passages, questions, options, results
- Encapsulate business logic for scoring and validation
- Provide computed properties for derived data

**Boundaries**:
- ✅ Data structures (structs)
- ✅ Business logic (scoring, correctness checks)
- ✅ Computed properties
- ❌ No UI-related code
- ❌ No persistence logic (for now)
- ❌ No networking

**Models Defined**:

1. **`ReadingPassage`**
   - Represents a German text passage with questions
   - Properties: id, title, level, text, questions[]
   - Conforms to: Identifiable, Hashable

2. **`ReadingQuestion`**
   - Represents a single comprehension question
   - Properties: id, prompt, options[], correctOptionID
   - Methods: `isCorrect(selectedOptionID:)` - validates answer
   - Conforms to: Identifiable, Hashable

3. **`ReadingOption`**
   - Represents a multiple-choice option
   - Properties: id, text
   - Conforms to: Identifiable, Hashable

4. **`ReadingQuestionResult`**
   - Encapsulates user's answer and correctness
   - Properties: id, question, selectedOptionID
   - Computed: isCorrect, selectedOptionText, correctOptionText
   - Conforms to: Identifiable, Hashable

5. **`LevelProgress`**
   - Tracks user progress for a CEFR level (A1, A2, etc.)
   - Properties: id, level, passagesCompleted, overallScore
   - Conforms to: Identifiable

**Business Rules**:
- Each passage belongs to exactly one level (A1, A2, B1, B2, C1, C2)
- Each question has exactly one correct answer
- Score is calculated as: (correct answers / total questions) * 100
- Questions must have at least 2 options (enforced by UI, not model)

**Dependencies**: Foundation

---

### Sample Data Layer

#### `SampleData/ReadingSamples.swift`
**Scope**: Mock data for development and prototyping  
**Responsibility**:
- Provide sample passages for each level
- Provide sample level progress data
- Enable testing without a backend

**Boundaries**:
- ✅ Static sample data extensions
- ✅ Realistic German content
- ❌ No data fetching logic
- ❌ No persistence

**Extensions Provided**:

1. **`ReadingPassage.sampleBerlinDay`**
   - A2-level passage about Lena's day in Berlin
   - 3 comprehension questions with 3 options each
   - Demonstrates proper model structure

2. **`LevelProgress.sampleLevels`**
   - Array of 4 levels (A1, A2, B1, B2)
   - Shows varying completion states
   - A1: 10 passages, 65% score (active user)
   - A2: 5 passages, 58% score (current level)
   - B1/B2: Not started

**Business Rules**:
- Sample passages must follow CEFR level guidelines
- Questions must be answerable from passage content
- Exactly one correct answer per question
- Score percentages should be realistic (40-100%)

**Future Enhancement**: Replace with API calls to backend

**Dependencies**: ReadingModels.swift

---

### Views Layer - Reading Feature

#### `Views/Reading/ReadingDashboardView.swift`
**Scope**: Main entry point for Reading module  
**Responsibility**:
- Display all CEFR levels (A1, A2, B1, B2) with progress
- Navigate to level-specific passage list
- Show completion status and scores

**Boundaries**:
- ✅ Level grid/list layout
- ✅ Navigation to LevelPassagesView
- ❌ No question logic
- ❌ No score calculation (uses model)

**Business Rules**:
- Display exactly 4 levels: A1, A2, B1, B2
- Show "Not started" for levels with 0 completed passages
- Show "X passages completed" and "Overall score: Y%" for active levels
- Levels are always displayed in order: A1 → A2 → B1 → B2

**UI Elements**:
- NavigationStack with title "Reading"
- ScrollView with level cards
- Each card is a NavigationLink to LevelPassagesView

**Dependencies**:
- LevelProgressCard.swift (component)
- LevelPassagesView.swift (navigation target)
- ProstTheme (styling)
- ReadingModels.swift (data)
- ReadingSamples.swift (mock data)

---

#### `Views/Reading/LevelPassagesView.swift`
**Scope**: List of passages for a specific level  
**Responsibility**:
- Display all passages available for the selected level
- Navigate to individual passage reading view
- Show passage metadata (title, question count)

**Boundaries**:
- ✅ Passage list for one level
- ✅ Navigation to ReadingPassageView
- ❌ No passage content display
- ❌ No question logic

**Business Rules**:
- Display passages for the selected level only
- Show passage title and question count
- Currently shows sample data (1 passage per level)
- Future: Load passages dynamically from backend

**UI Elements**:
- NavigationStack with level as title (e.g., "A2")
- ScrollView with passage cards
- Each card is a NavigationLink to ReadingPassageView

**State Management**:
- Receives `levelProgress: LevelProgress` as input
- Stateless (no @State properties)

**Dependencies**:
- ReadingPassageView.swift (navigation target)
- ProstTheme (styling)
- ReadingModels.swift (data)
- ReadingSamples.swift (mock passages)

---

#### `Views/Reading/ReadingPassageView.swift`
**Scope**: Display German text passage for reading  
**Responsibility**:
- Show full passage text
- Enable text selection for studying
- Navigate to questions when user is ready

**Boundaries**:
- ✅ Passage text display
- ✅ "Continue to Questions" CTA
- ❌ No question display
- ❌ No answer collection

**Business Rules**:
- User must read passage before answering questions (enforced by flow)
- Text is selectable for translation/study
- Level indicator shown in navigation bar
- Bottom CTA button is always visible (safeAreaInset)

**UI Elements**:
- ScrollView with passage text in card
- Fixed bottom button: "Continue to Questions"
- Navigation title: Level (e.g., "A2")

**State Management**:
- `@State private var goToQuestions: Bool` - triggers navigation
- Receives `passage: ReadingPassage` as input

**Navigation Flow**:
ReadingPassageView → ReadingQuestionsView

**Dependencies**:
- ReadingQuestionsView.swift (navigation target)
- ProstTheme (styling)
- ReadingModels.swift (data)

---

#### `Views/Reading/ReadingQuestionsView.swift`
**Scope**: Multiple-choice question answering interface  
**Responsibility**:
- Display all questions for the passage
- Collect user's answer selections
- Validate all questions are answered
- Navigate to results when submitted

**Boundaries**:
- ✅ Question display and answer collection
- ✅ Validation (all answered)
- ✅ Result generation
- ❌ No scoring logic (delegated to model)
- ❌ No result display

**Business Rules**:
- User must answer ALL questions before submitting
- Only one option can be selected per question
- Submit button disabled until all answered
- Button text updates dynamically: "Answer all questions (X left)" or "Submit Answers"

**UI Elements**:
- ScrollView with question cards
- Fixed bottom submit button
- Navigation title: Level (e.g., "A2")

**State Management**:
- `@State private var selectedOptionByQuestionID: [UUID: UUID]` - tracks selections
- `@State private var showResults: Bool` - triggers navigation
- Computed: `results`, `unansweredCount`
- Receives `passage: ReadingPassage` as input

**Business Logic**:
```swift
// Generate results
results = passage.questions.map { q in
    ReadingQuestionResult(
        question: q,
        selectedOptionID: selectedOptionByQuestionID[q.id]
    )
}

// Check completion
unansweredCount = results.filter { $0.selectedOptionID == nil }.count
```

**Navigation Flow**:
ReadingQuestionsView → ReadingResultsView

**Dependencies**:
- QuestionCardView.swift (component)
- ReadingResultsView.swift (navigation target)
- ProstTheme (styling)
- ReadingModels.swift (data)

---

#### `Views/Reading/ReadingResultsView.swift`
**Scope**: Display quiz results and review wrong answers  
**Responsibility**:
- Show overall score (percentage and fraction)
- Display only wrong answers for review
- Show user's answer vs. correct answer
- Allow retaking the quiz

**Boundaries**:
- ✅ Score display
- ✅ Wrong answer review
- ✅ Retake functionality
- ❌ No answer collection
- ❌ No score calculation (uses model)

**Business Rules**:
- Display score as percentage: (correct / total) × 100
- Only show wrong answers in review section
- Each wrong answer shows:
  - Question text
  - ❌ User's (wrong) answer
  - ✅ Correct answer
- Retake button resets state and navigates back to questions

**UI Elements**:
- ScrollView with score card at top
- "Review" section with wrong answer cards
- Fixed bottom "Retake" button
- Navigation title: Level (e.g., "A2")

**State Management**:
- Receives `passage: ReadingPassage` as input
- Receives `results: [ReadingQuestionResult]` as input
- Receives `onRetake: () -> Void` closure for reset
- Computed: `correctCount`, `wrongResults`, `scorePercentage`

**Business Logic**:
```swift
// Calculate score
scorePercentage = Int((Double(correctCount) / Double(results.count)) * 100)

// Filter wrong answers
wrongResults = results.filter { !$0.isCorrect }
```

**Navigation Flow**:
- Retake → Dismisses back to ReadingQuestionsView (with reset state)

**Dependencies**:
- ProstTheme (styling)
- ReadingModels.swift (data)

---

### Views Layer - Components

#### `Views/Components/LevelProgressCard.swift`
**Scope**: Reusable level progress card component  
**Responsibility**:
- Display level badge (A1, A2, etc.)
- Show progress text (passages completed)
- Show score percentage or "Not started"
- Provide consistent card styling

**Boundaries**:
- ✅ Visual representation of LevelProgress
- ✅ Reusable across any dashboard
- ❌ No navigation logic (parent handles)
- ❌ No data fetching

**Business Rules**:
- Badge shows level text prominently
- If passagesCompleted > 0: Show count and score
- If passagesCompleted == 0: Show "Not started"
- Score displayed as integer percentage (65%, not 0.65)

**UI Elements**:
- HStack with level badge (60x60 rounded square)
- VStack with progress text
- Chevron right icon
- Card background (prostCard modifier)

**Usage**:
```swift
LevelProgressCard(levelProgress: levelProgress)
```

**Dependencies**:
- ProstTheme (styling)
- ReadingModels.swift (LevelProgress)

---

#### `Views/Components/QuestionCardView.swift`
**Scope**: Reusable question and options component  
**Responsibility**:
- Display question number and prompt
- Render all options with selection state
- Handle option selection via binding
- Provide consistent question styling

**Boundaries**:
- ✅ Question display with options
- ✅ Selection state management (via binding)
- ❌ No answer validation
- ❌ No navigation

**Business Rules**:
- Question number shown as "Q1", "Q2", etc.
- Only one option can be selected at a time
- Selected option visually highlighted
- All options tappable with clear hit targets

**UI Elements**:
- VStack with question header (Q# + prompt)
- VStack with option rows (OptionRowView)
- Card background (prostCard modifier)

**Sub-component: `OptionRowView`**
- Displays single option with selection state
- Button with checkmark icon (selected) or circle (unselected)
- Accent background when selected
- Gray background when unselected

**State Management**:
- Receives `question: ReadingQuestion` as input
- Receives `number: Int` for display
- Receives `@Binding var selectedOptionID: UUID?` for two-way binding

**Usage**:
```swift
QuestionCardView(
    number: 1,
    question: question,
    selectedOptionID: $selectedOptionID
)
```

**Dependencies**:
- ProstTheme (styling)
- ReadingModels.swift (ReadingQuestion, ReadingOption)

---

#### `Views/PlaceholderTabView.swift`
**Scope**: Placeholder for unimplemented tabs  
**Responsibility**:
- Show "Coming soon" message for future features
- Maintain consistent tab structure
- Provide clear expectation setting

**Boundaries**:
- ✅ Simple placeholder UI
- ✅ Reusable for any unimplemented tab
- ❌ No actual feature implementation

**Business Rules**:
- Display tab name prominently
- Show "Coming soon" subtitle
- Match app theme and styling

**UI Elements**:
- VStack with title and subtitle
- Centered layout
- Theme background

**Usage**:
```swift
PlaceholderTabView(title: "Listening")
PlaceholderTabView(title: "Sprechen")
PlaceholderTabView(title: "Writing")
```

**Dependencies**:
- ProstTheme (styling)

---

### Theme & Design System

#### `Theme.swift`
**Scope**: Centralized design system  
**Responsibility**:
- Define app-wide color palette
- Define typography scale
- Define spacing constants
- Define corner radius values
- Define shadow parameters
- Provide background gradient modifier

**Boundaries**:
- ✅ Design tokens and constants
- ✅ View modifiers for theming
- ❌ No UI components
- ❌ No business logic

**Design Tokens**:

**Colors**:
- `backgroundTop`: rgb(0.96, 0.97, 0.98) - Light gradient top
- `backgroundBottom`: rgb(0.92, 0.94, 0.96) - Light gradient bottom
- `card`: White - Card background
- `cardBorder`: Black 8% opacity - Card border
- `chip`: 95% white - Chip background
- `chipBorder`: Black 6% opacity - Chip border
- `accentSoft`: Accent 12% opacity - Selected backgrounds
- `accentBorder`: Accent 30% opacity - Selected borders
- `success`: Green - Correct answer indicator
- `danger`: Red - Wrong answer indicator

**Radius**:
- `card`: 18pt - Card corner radius
- `pill`: 999pt - Fully rounded (chips, buttons)

**Spacing**:
- `screenPadding`: 20pt - Edge padding
- `section`: 20pt - Between major sections
- `item`: 12pt - Between items in a list

**Typography**:
- `hero`: Large Title, Bold, Rounded - Dashboard titles
- `title`: Headline, Semibold, Rounded - Card titles
- `body`: Body, Regular, Rounded - Main content
- `caption`: Footnote, Regular, Rounded - Metadata

**Shadow**:
- `cardRadius`: 12pt - Shadow blur radius
- `cardY`: 4pt - Shadow vertical offset
- `cardOpacity`: 0.08 - Shadow opacity

**View Modifiers**:
- `.prostBackground()` - Apply gradient background to any view

**Usage**:
```swift
// Colors
.fill(ProstTheme.Colors.card)

// Typography
.font(ProstTheme.Typography.title)

// Spacing
.padding(ProstTheme.Spacing.screenPadding)

// Background
SomeView()
    .prostBackground()
```

**Design Philosophy**:
- Light, readable, minimalist aesthetic
- Consistent spacing and typography
- Subtle shadows and borders
- iOS-native feel with rounded design

**Dependencies**: SwiftUI

---

#### `ReadingUIComponents.swift`
**Scope**: Reusable theme-aware UI modifiers  
**Responsibility**:
- Provide card styling modifier
- Ensure consistent component styling
- Reduce code duplication

**Boundaries**:
- ✅ View modifiers for theming
- ✅ Reusable across all features
- ❌ No feature-specific components

**Modifiers Provided**:

**`.prostCard()`**
- Adds white background
- Adds border (8% black)
- Adds subtle shadow
- Adds 16pt padding
- Adds 18pt corner radius
- Usage:
  ```swift
  VStack { ... }
      .prostCard()
  ```

**Business Rules**:
- All cards in the app use this modifier
- Ensures visual consistency
- No custom card styling allowed

**Dependencies**:
- Theme.swift (design tokens)
- SwiftUI

---

## Business Rules Summary

### Reading Module Flow
1. User selects a level (A1-B2)
2. User selects a passage from that level
3. User reads the German text
4. User answers all multiple-choice questions
5. User submits answers (only when all answered)
6. App shows score and wrong answers
7. User can retake to improve score

### Scoring Rules
- Score = (Correct Answers / Total Questions) × 100
- Displayed as integer percentage (e.g., 67%)
- Each question worth equal points
- No partial credit
- No time limits (for now)

### Level Progress Rules
- Progress tracked per level (A1, A2, B1, B2)
- Completion count increments on submit (not on perfect score)
- Overall score = average of all passage scores in that level
- Levels unlocked sequentially (future feature)

### Navigation Rules
- Reading tab is default on app launch
- Back navigation always available
- Level indicator shown in nav bar during quiz
- Bottom CTAs fixed and always visible

### Validation Rules
- All questions must be answered before submit
- Only one option per question
- No answer changing after submit (must retake)
- Retake resets all selections

---

## Extension Points

### Adding a New Module (e.g., Listening)

1. **Create Models** (`Models/ListeningModels.swift`)
   - Define audio clip, question, transcript models
   - Follow same patterns as ReadingModels

2. **Create Sample Data** (`SampleData/ListeningSamples.swift`)
   - Provide mock audio clips and transcripts
   - Use same level structure (A1-B2)

3. **Create Views** (`Views/Listening/`)
   - `ListeningDashboardView` (reuse LevelProgressCard)
   - `AudioPlayerView` (play audio + controls)
   - `ListeningQuestionsView` (reuse QuestionCardView if applicable)
   - `ListeningResultsView` (similar to ReadingResultsView)

4. **Update ContentView**
   - Replace PlaceholderTabView with ListeningDashboardView

5. **Reuse**
   - Theme.swift (colors, typography)
   - LevelProgressCard (dashboard)
   - QuestionCardView (if applicable)

### Adding Persistence
- Create `Services/` folder
- Add `PersistenceService.swift` (Core Data or CloudKit)
- Update models to conform to Codable
- Replace sample data with fetched data

### Adding Authentication
- Create `Models/User.swift`
- Add `Services/AuthService.swift`
- Add login/signup views
- Protect content behind auth

---

## Testing Strategy

### Unit Tests (`ProstTests/`)
- Test model business logic
- Test scoring calculations
- Test validation rules
- Test state management

### UI Tests (`ProstUITests/`)
- Test navigation flows
- Test user interactions
- Test error states
- Test accessibility

### Future: Integration Tests
- Test persistence layer
- Test API calls
- Test authentication

---

## Code Conventions

### Naming
- Files: PascalCase (e.g., `ReadingDashboardView.swift`)
- Types: PascalCase (e.g., `struct ReadingPassage`)
- Variables: camelCase (e.g., `selectedOptionID`)
- Constants: camelCase (e.g., `screenPadding`)

### Organization
- Group by feature, not by type
- Views in `Views/[Feature]/`
- Models in `Models/[Feature]Models.swift`
- Keep file sizes reasonable (< 300 lines)

### SwiftUI Conventions
- Use `@State` for local view state
- Use `@Binding` for two-way communication
- Use `let` for inputs from parent
- Prefer composition over inheritance

### Comments
- Use `// MARK: -` to organize code sections
- Add doc comments for public APIs (future)
- Explain "why", not "what"

---

## Future Enhancements

### Architecture
- [ ] Add dependency injection
- [ ] Implement MVVM or TCA architecture
- [ ] Add repository pattern for data access
- [ ] Implement proper error handling

### Features
- [ ] Spaced repetition algorithm
- [ ] Progress sync across devices (CloudKit)
- [ ] Offline mode with local persistence
- [ ] Dark mode support
- [ ] Accessibility improvements
- [ ] Localization (German UI option)

### Testing
- [ ] Increase unit test coverage
- [ ] Add snapshot tests
- [ ] Add performance tests
- [ ] CI/CD pipeline

---

## Glossary

- **CEFR**: Common European Framework of Reference for Languages (A1-C2)
- **A1/A2**: Beginner levels
- **B1/B2**: Intermediate levels
- **C1/C2**: Advanced levels (not yet implemented)
- **DRY**: Don't Repeat Yourself
- **CTA**: Call-to-Action (button)
- **Prost**: German word for "Cheers!"

---

**Last Updated**: December 13, 2025  
**Version**: 1.0.0 (Initial Prototype)

