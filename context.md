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

1. **`User`**
   - Represents app user identity
   - Properties: id, name, email, createdAt
   - Conforms to: Identifiable, Codable, Hashable
   - Purpose: Track user for completion and progress data

2. **`ReadingPassage`**
   - Represents a German text passage with questions
   - Properties: id, title, level, text, questions[], tags[]
   - New: tags[] - lowercase, hyphenated strings for search (e.g., ["travel", "daily-life"])
   - Conforms to: Identifiable, Codable, Hashable
   - Purpose: Content structure for reading comprehension

3. **`ReadingQuestion`**
   - Represents a single comprehension question
   - Properties: id, prompt, options[], correctOptionID
   - Methods: `isCorrect(selectedOptionID:)` - validates answer
   - Conforms to: Identifiable, Codable, Hashable

4. **`ReadingOption`**
   - Represents a multiple-choice option
   - Properties: id, text
   - Conforms to: Identifiable, Codable, Hashable

5. **`ReadingQuestionResult`**
   - Encapsulates user's answer and correctness
   - Properties: id, question, selectedOptionID
   - Computed: isCorrect, selectedOptionText, correctOptionText
   - Conforms to: Identifiable, Hashable
   - Purpose: Result calculation (not persisted)

6. **`PassageCompletion`**
   - Tracks individual passage completion attempts
   - Properties: id, userId, passageId, **level (CEFR level for filtering)**, score, completedAt, attemptNumber
   - Computed: scorePercentage (0-100), isPerfect (score == 1.0)
   - **Validation**: Score clamped to 0.0-1.0 range, attemptNumber enforced minimum of 1
   - **Critical**: Level field enables per-level statistics aggregation
   - Conforms to: Identifiable, Codable, Hashable
   - Purpose: Record each quiz submission with metadata and level context

7. **`UserProgress`**
   - Aggregates user performance per level
   - Properties: userId, level, completedPassageIds[], totalAttempts, averageScore, bestScore, latestScore, lastActivityAt
   - Computed: completedCount, averageScorePercentage, bestScorePercentage, latestScorePercentage, isValid
   - **Validation**: isValid checks attempts >= completed passages, best >= average, scores in valid range
   - Conforms to: Identifiable, Codable, Hashable
   - Purpose: Dashboard statistics and progress tracking

8. **`LevelProgress`** (Deprecated)
   - Legacy model, replaced by UserProgress
   - Marked with @available(*, deprecated)
   - Kept for backward compatibility during migration

9. **`PassageFilters`** (NEW - Phase 3)
   - Model for passage search, filtering, and sorting state
   - Properties: searchText, selectedTags, completionFilter, sortOption
   - Computed: isActive (checks if any non-default filters applied)
   - Nested enums: CompletionFilter (.all, .completed, .incomplete), SortOption (.title, .dateAdded, .bestScore, .attempts)
   - Conforms to: Codable, Equatable
   - Purpose: Centralize all filtering state in one model

---

### Goethe A1 Exam Models (New File)

#### `Models/GoetheA1ReadingModels.swift` (NEW - Goethe Format)
**Scope**: Official Goethe-Zertifikat A1 Reading exam structure  
**Purpose**: Support the 3-part Goethe A1 Reading format (15 questions, 25 minutes)

**Models (10 total)**:

1. **`GoetheQuestionType`** (Enum)
   - `.trueFalse`: Richtig/Falsch questions (Parts 1 & 3)
   - `.binaryChoice`: A/B selection questions (Part 2)
   - `.multipleChoice`: Future expansion for other formats

2. **`GoetheA1Option`**
   - Answer option for questions
   - Properties: text ("Richtig", "Falsch", "A", "B"), value (description for A/B)
   - Helper extensions: `.richtig`, `.falsch`, `.optionA()`, `.optionB()`

3. **`GoetheA1Question`**
   - Individual question in the exam
   - Properties: questionNumber (1-15), prompt, type, options[], correctOptionID
   - Computed: correctOption

4. **`GoetheA1Text`**
   - Text snippet (email, notice, sign, ad)
   - Properties: title (optional), content, textNumber (optional)
   - Used for passage text in each part

5. **`GoetheA1ReadingPart`**
   - One of 3 exam parts
   - Properties: partNumber (1-3), title, instructions, textType, texts[], questions[]
   - Computed: questionCount, questionRange
   - Each part has ~5 questions

6. **`GoetheA1ReadingExam`**
   - Complete exam with all 3 parts
   - Properties: title, level ("A1"), duration (25min), totalQuestions (15), parts[], tags[]
   - Computed: allQuestions, part1, part2, part3

7. **`GoetheA1QuestionResult`**
   - Result for single question
   - Properties: question, selectedOptionID
   - Computed: isCorrect, selectedOption, correctOption

8. **`GoetheA1PartResult`**
   - Results for one part (5 questions)
   - Properties: partNumber, questionResults[]
   - Computed: correctCount, totalCount, score, scorePercentage

9. **`GoetheA1ExamResult`**
   - Complete exam results
   - Properties: examId, partResults[], completedAt
   - Computed: correctCount, totalCount, overallScore, isPassed (≥60%), part1Result, part2Result, part3Result

10. **`GoetheA1UserProgress`**
    - Track user progress across Goethe A1 exams
    - Properties: userId, level, completedExamIds[], totalAttempts, averageScore, bestScore, latestScore, isPassed, part1AverageScore, part2AverageScore, part3AverageScore, lastActivityAt
    - Computed: completedCount, scorePercentages, partScorePercentages, isStarted
    - All scores validated (clamped 0.0-1.0)

11. **`GoetheA1ExamCompletion`**
    - Completion tracking for Goethe exams
    - Properties: userId, examId, level, score, isPassed, completedAt, attemptNumber, timeSpent (optional)
    - Computed: scorePercentage, isPerfect, timeSpentFormatted
    - Validation: Score clamped, attemptNumber minimum 1

**Official Format Compliance**:
- 3 parts per exam (Goethe-Institut structure)
- Part 1: Informal texts (emails, messages) - 5 True/False questions
- Part 2: Situation-based texts (ads, notices) - 5 A/B choice questions
- Part 3: Signs and notices (opening hours, rules) - 5 True/False questions
- Total: 15 questions, 25 minutes
- Pass threshold: 60% (9/15 correct)

**Dependencies**: Foundation

---

**Business Rules**:
- Each passage belongs to exactly one level (A1, A2, B1, B2, C1, C2)
- Each question has exactly one correct answer
- Score is calculated as: (correct answers / total questions), stored as 0.0-1.0
- Score displayed as percentage (0-100%)
- Questions must have at least 2 options (enforced by UI, not model)
- **Completion tracking**: Auto-complete on submit OR manual "Mark as Complete"
- **Attempt tracking**: Each retake increments attemptNumber (1, 2, 3, ...)
- **Score aggregation**: averageScore = mean of all completions, bestScore = max score
- **Tags**: lowercase, hyphenated, for backend search filtering (not user-facing)
- **Tag search**: AND logic (passage must have all searched tags)
- **Validation**: 
  * Scores automatically clamped to 0.0-1.0 range
  * Attempt numbers enforced minimum of 1
  * UserProgress validated for logical consistency (best >= average, attempts >= passages)

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

1. **`User.sampleUser`**
   - Demo user for prototype testing
   - ID: Fixed UUID for consistency across app
   - Name: "Demo User", Email: "demo@prost.app"
   - Created 30 days ago

2. **`ReadingPassage.sampleBerlinDay`**
   - A2-level passage about Lena's day in Berlin
   - **Fixed UUID**: 00000000-0000-0000-0000-000000000010
   - 3 comprehension questions with 3 options each
   - Tags: ["travel", "daily-life", "food", "culture"]
   - Demonstrates proper model structure with search tags

3. **`PassageCompletion.sampleCompletions`**
   - 2 completion records for A2 sample passage
   - **Uses fixed passage UUID** for proper linking
   - **Includes level field** ("A2") for filtering
   - Attempt 1: 67% score, 5 days ago
   - Attempt 2: 100% score (perfect), 2 days ago
   - Shows progression over attempts

4. **`UserProgress.sampleProgress`**
   - Array of 4 levels (A1, A2, B1, B2) with aggregated data
   - A1: 10 passages completed, avg 65%, best 90%, latest 70% (simulated)
   - **A2: 1 passage completed, 2 attempts, avg 83.5%, best 100%, latest 100%** (realistic)
   - **A2 includes fixed passage UUID** in completedPassageIds
   - B1/B2: Not started (0 passages, 0 attempts)
   - **Demonstrates realistic per-level statistics** matching actual completions
   - Demonstrates proper data linking and completion tracking

5. **`LevelProgress.sampleLevels`** (Deprecated)
   - Legacy sample data, replaced by UserProgress.sampleProgress
   - Marked with @available(*, deprecated)
   - Kept for backward compatibility

**Business Rules**:
- Sample passages must follow CEFR level guidelines
- Questions must be answerable from passage content
- Exactly one correct answer per question
- Score percentages should be realistic (40-100%)
- **Tags**: Use common categories (travel, food, work, daily-life, culture, family, hobbies)
- **Completion history**: Show realistic attempt progression (improving scores)
- **User consistency**: Use same user ID across all sample data

**Future Enhancement**: Replace with API calls to backend

**Dependencies**: ReadingModels.swift

---

#### `SampleData/GoetheA1Samples.swift` (NEW - Goethe Format)
**Scope**: Mock data for official Goethe A1 Reading exams  
**Responsibility**:
- Provide complete sample Goethe A1 exam with all 3 parts
- Provide sample completion and progress data
- Enable testing of official exam format

**Extensions Provided**:

1. **`GoetheA1Option` helpers**
   - `.richtig` / `.falsch`: Pre-built True/False options
   - `.optionA(description)` / `.optionB(description)`: Factory methods for A/B choices

2. **`GoetheA1ReadingExam.sampleExam1`**
   - Complete realistic Goethe A1 Reading exam
   - **Fixed UUID**: 00000000-0000-0000-0000-000000000020
   - **Part 1**: Email from Anna (Berlin trip) - 5 True/False questions
   - **Part 2**: Supermarket ad + Restaurant notice - 5 A/B choice questions
   - **Part 3**: Shop hours + Park rules - 5 True/False questions
   - Total: 15 questions, 25 minutes, A1 level
   - Tags: ["goethe", "a1", "official-format", "practice"]

3. **`GoetheA1ExamCompletion.sampleCompletion`**
   - Sample completion record for exam
   - 80% score (12/15 correct) - Passed
   - Attempt #1, completed 3 days ago
   - Time spent: 22:30 minutes

4. **`GoetheA1UserProgress.sampleProgress`**
   - User who has attempted Goethe A1 exams
   - 1 exam completed, 2 total attempts
   - Overall: avg 75%, best 80%, latest 80%, passed ✓
   - Part 1: 80%, Part 2: 70%, Part 3: 75%

5. **`GoetheA1UserProgress.notStartedProgress`**
   - User who hasn't started Goethe A1
   - All scores 0%, not passed
   - For demo of initial state

**Business Rules**:
- Exam must have exactly 3 parts
- Each part has ~5 questions (15 total)
- Part 1 & 3: True/False format
- Part 2: A/B choice format
- Pass threshold: 60% (9/15 correct)
- Realistic German A1-level content
- Time tracking optional but encouraged

**Dependencies**: GoetheA1ReadingModels.swift, ReadingModels.swift (User)

---

**Business Rules**:

### Services Layer

#### `Services/CompletionService.swift`
**Scope**: Business logic for passage completions and progress aggregation  
**Responsibility**:
- Create PassageCompletion records
- Calculate attempt numbers for passages
- Update UserProgress after completions
- Aggregate scores (average, best, latest)
- Provide completion history
- Compare scores across attempts

**Boundaries**:
- ✅ Pure business logic (no UI)
- ✅ Score calculations
- ✅ Attempt tracking
- ✅ Progress aggregation
- ❌ No state management
- ❌ No persistence (operates on passed data)
- ❌ No navigation

**Public Methods**:

1. **`createCompletion(userId:passageId:level:score:attemptNumber:)`**
   - Creates a new PassageCompletion record
   - **Requires level parameter** (A1, A2, B1, B2) for filtering
   - Validates score (clamped to 0.0-1.0)
   - Validates attempt number (minimum 1)
   - Returns: PassageCompletion

2. **`calculateAttemptNumber(userId:passageId:existingCompletions:)`**
   - Counts existing completions for user + passage
   - Returns: next attempt number (1, 2, 3, ...)

3. **`updateProgress(currentProgress:newCompletion:allCompletions:)`**
   - **CRITICAL FIX**: Filters completions by userId AND level (not just userId)
   - Adds passage to completedPassageIds (if new)
   - Increments totalAttempts (for this level only)
   - Recalculates averageScore (mean of attempts in this level)
   - Updates bestScore (max score in this level)
   - Updates latestScore (new completion score)
   - Sets lastActivityAt to now
   - Returns: Updated UserProgress

4. **`getCompletionHistory(userId:passageId:allCompletions:)`**
   - Filters completions for user + passage
   - Sorts by completedAt (oldest first)
   - Returns: [PassageCompletion]

5. **`getLatestCompletion(userId:passageId:allCompletions:)`**
   - Gets most recent completion
   - Returns: PassageCompletion?

6. **`isCompleted(userId:passageId:allCompletions:)`**
   - Checks if user has completed passage at least once
   - Returns: Bool

7. **`getScoreComparison(newScore:previousCompletions:)`**
   - Compares new score with previous attempts
   - Returns: ScoreComparison enum

**ScoreComparison Enum**:
- `.firstAttempt`: No previous attempts
- `.improved(from:to:)`: Score increased by >1%
- `.decreased(from:to:)`: Score decreased by >1%
- `.same(_)`: Score within 1% of previous
- Provides `.message` property with user-friendly text

**Business Rules**:
- Score automatically clamped to 0.0-1.0 range
- Attempt numbers start at 1 and increment per passage
- **Average score = mean of all attempts IN THIS LEVEL** (per-level aggregation)
- **Best score = highest score IN THIS LEVEL** (per-level aggregation)
- **Latest score = most recent completion IN THIS LEVEL** (per-level aggregation)
- Score comparison uses 1% threshold to avoid noise
- **Score comparison sorts by date** to ensure comparing with most recent
- Celebration emoji (🎉) on improvements
- **Level filtering enabled**: Each level's stats are independent

**Usage Example**:
```swift
// Calculate next attempt
let attemptNum = CompletionService.calculateAttemptNumber(
    userId: user.id,
    passageId: passage.id,
    existingCompletions: allCompletions
)

// Create completion
let completion = CompletionService.createCompletion(
    userId: user.id,
    passageId: passage.id,
    score: 0.67,
    attemptNumber: attemptNum
)

// Update progress
let newProgress = CompletionService.updateProgress(
    currentProgress: currentProgress,
    newCompletion: completion,
    allCompletions: allCompletions
)
```

**Dependencies**:
- ReadingModels.swift (PassageCompletion, UserProgress)
- Foundation (UUID, Date)

**Architecture Notes**:
- Stateless service (all functions are static)
- Operates on passed data (doesn't manage state)
- Pure functions (no side effects)
- Easily testable
- Can be replaced with API calls in future

---

#### `Services/PassageFilterService.swift` (NEW - Phase 3)
**Scope**: Filtering and sorting logic for passage lists  
**Responsibility**:
- Filter passages by search text (title matching)
- Filter passages by tags (AND logic)
- Filter passages by completion status
- Sort passages by various criteria
- Combine filtering and sorting in one call

**Boundaries**:
- ✅ Pure business logic (no UI)
- ✅ Filtering operations
- ✅ Sorting operations
- ❌ No state management
- ❌ No persistence

**Public Methods**:

1. **`filterPassages(_:filters:completionInfo:)`**
   - Filters passage array based on PassageFilters criteria
   - Text search: case-insensitive title matching
   - Tag filter: AND logic (passage must have ALL selected tags)
   - Completion filter: all/completed/incomplete
   - Returns: Filtered [ReadingPassage]

2. **`sortPassages(_:sortOption:completionInfo:)`**
   - Sorts passage array by specified option
   - title: Alphabetical (case-insensitive)
   - dateAdded: Original order (newest first)
   - bestScore: Highest score first, ties broken alphabetically
   - attempts: Most attempts first, ties broken alphabetically
   - Returns: Sorted [ReadingPassage]

3. **`applyFiltersAndSort(to:filters:completionInfo:)`**
   - Convenience method: filter then sort
   - Returns: Filtered and sorted [ReadingPassage]

**Business Rules**:
- **Text search**: Case-insensitive, matches title only (Phase 3)
- **Tag filtering**: AND logic - passage must contain ALL selected tags
- **Completion filtering**: 
  * all: No filtering
  * completed: Only passages with at least 1 completion
  * incomplete: Only passages with 0 completions
- **Sorting tie-breakers**: Always alphabetical by title
- **Empty results**: Returns empty array (UI shows empty state)

**Usage Example**:
```swift
// Build completion info
let completionInfo: [UUID: PassageCompletionInfo] = [...]

// Apply filters and sort
let results = PassageFilterService.applyFiltersAndSort(
    to: passages,
    filters: filters,
    completionInfo: completionInfo
)
```

**Dependencies**:
- ReadingModels.swift (ReadingPassage)
- PassageFilters.swift (filter model)
- Foundation (UUID)

**Architecture Notes**:
- Stateless service (all functions are static)
- Pure functions (deterministic)
- Easily testable with sample data
- No side effects

---

### ViewModels Layer

#### `ViewModels/AppState.swift`
**Scope**: App-wide state management (temporary, in-memory)  
**Responsibility**:
- Manage current user
- Store all PassageCompletions
- Store all UserProgress records
- Provide convenient access methods
- Coordinate with CompletionService

**Boundaries**:
- ✅ ObservableObject for SwiftUI
- ✅ In-memory storage
- ✅ Convenience methods
- ❌ No UI logic
- ❌ No persistence (Phase 4)
- ❌ No network calls

**Published Properties**:
- `currentUser: User` - Currently logged-in user (sample data)
- `completions: [PassageCompletion]` - All completion records
- `userProgress: [UserProgress]` - Progress for each level (A2/B1/B2)
- `goetheA1Progress: GoetheA1UserProgress` - **Special progress for A1 Goethe exams** (NEW)

**Public Methods**:

1. **`addCompletion(_:for:)`**
   - Adds completion to list
   - Updates relevant UserProgress
   - Uses CompletionService for calculations

2. **`getCompletionHistory(for:)`**
   - Returns completion history for passage
   - Delegates to CompletionService

3. **`isCompleted(_:)`**
   - Checks if passage completed
   - Delegates to CompletionService

4. **`getNextAttemptNumber(for:)`**
   - Gets next attempt number for passage
   - Delegates to CompletionService

5. **`getProgress(for:)`**
   - Returns UserProgress for specific level
   - Returns: UserProgress?

**Initialization**:
- Defaults to sample data (User.sampleUser, etc.)
- Can be injected with different data for testing

**Environment Injection**:
```swift
// In ProstApp.swift
@StateObject private var appState = AppState()

ContentView()
    .environmentObject(appState)

// In views
@EnvironmentObject private var appState: AppState
```

**Business Rules**:
- State resets on app restart (no persistence yet)
- All completions stored in single array
- Progress updated immediately after completion
- Current user never changes (single-user app for now)

**Future Migration** (Phase 4):
- Replace with Core Data models
- Add UserDefaults for current user
- Add offline sync
- Add authentication

**Dependencies**:
- ReadingModels.swift (User, PassageCompletion, UserProgress, ReadingPassage)
- CompletionService.swift (business logic)
- Foundation (UUID)
- SwiftUI (ObservableObject, Published)

---

### Views Layer - Reading Feature

#### `Views/Reading/ReadingDashboardView.swift` (ENHANCED - Collapsible + Smart Ordering)
**Scope**: Main entry point for Reading module with intelligent card ordering  
**Responsibility**:
- Display all CEFR levels with progress
- **Smart ordering: current → not started → completed**
- **Collapsible cards** (tap to expand/collapse)
- **Auto-expand current level** on load
- **Special handling for A1** (Goethe format vs regular passages)
- Navigate to level-specific content
- Reflect real-time progress updates

**Boundaries**:
- ✅ Collapsible level cards
- ✅ Smart ordering algorithm
- ✅ A1 Goethe vs A2/B1/B2 regular cards
- ✅ Type-safe navigation
- ✅ Uses AppState for dynamic data
- ❌ No question logic
- ❌ No score calculation (uses model)

**Business Rules**:
- Display exactly 4 levels: A1 (Goethe), A2, B1, B2
- **Smart Ordering**:
  * In Progress (1+ attempts, best < 90%) → **Top**
  * Not Started (0 attempts) → **Middle**
  * Completed (best ≥ 90%) → **Bottom**
- **Default Expansion**:
  * Current level (first in-progress) → Expanded
  * All others → Collapsed
- **A1 Special Treatment**:
  * Uses GoetheA1ProgressCard (3-part structure)
  * Uses GoetheA1UserProgress data
  * Navigates to Goethe exams (future)
- **A2/B1/B2**:
  * Use LevelProgressCard (simple passages)
  * Use UserProgress data
  * Navigate to LevelPassagesView
- Progress updates automatically when user completes

**State Management**:
- `@EnvironmentObject appState: AppState` - Reads userProgress array
- `@State expandedLevels: Set<String>` - Tracks which cards expanded
- `@State navigationPath: NavigationPath` - Type-safe navigation
- Computed: `orderedLevels`, `currentLevel`
- Functions: `levelStatus()`, `goetheStatus()` - Determine order

**Ordering Algorithm**:
```swift
enum LevelStatus: Int {
    case inProgress = 0  // First
    case notStarted = 1  // Second
    case completed = 2   // Last
}

// Determine status for each level
// Sort by status.rawValue
// Render in sorted order
```

**UI Elements**:
- NavigationStack with title "Reading"
- ScrollView with ordered level cards
- A1: GoetheA1ProgressCard
- A2/B1/B2: LevelProgressCard
- Each card is collapsible (header = toggle, button = navigate)

**Navigation**:
- Type-safe NavigationPath
- `.navigationDestination(for: UserProgress.self)` for regular levels
- `.navigationDestination(for: String.self)` for Goethe A1

**Auto-Expand Logic**:
```swift
.onAppear {
    if let current = currentLevel {
        expandedLevels.insert(current)
    }
}
```

**Dependencies**:
- AppState (data source)
- GoetheA1ProgressCard.swift (A1 component)
- LevelProgressCard.swift (A2/B1/B2 component)
- LevelPassagesView.swift (navigation target)
- ProstTheme (styling)
- ReadingModels.swift, GoetheA1ReadingModels.swift (data)

---

---

#### `Views/Reading/LevelPassagesView.swift` (ENHANCED - Phase 3)
**Scope**: Searchable, filterable list of passages with completion status  
**Responsibility**:
- Display all passages for the selected level
- **Search passages by title** (Phase 3)
- **Filter by completion status** (all/completed/incomplete) (Phase 3)
- **Filter by tags** (AND logic) (Phase 3)
- **Sort passages** (title/date/score/attempts) (Phase 3)
- Show completion status for each passage
- Display attempt count and best score
- Navigate to individual passage reading view
- Show empty states when no results

**Boundaries**:
- ✅ Search and filter UI
- ✅ Passage list for one level
- ✅ Completion badges and scores
- ✅ Empty state feedback
- ✅ Navigation to ReadingPassageView
- ❌ No passage content display
- ❌ No question logic
- ❌ No filter persistence (Phase 4)

**Business Rules**:
- **Search**: Case-insensitive title matching
- **Tag filter**: AND logic - passage must have ALL selected tags
- **Completion filter**: all (default), completed (≥1 attempt), incomplete (0 attempts)
- **Sorting**: title (A-Z), dateAdded (newest first), bestScore (highest first), attempts (most first)
- **Empty state**: Show helpful message when no results or filters active
- **Clear filters**: Button appears when any non-default filter active
- Show completion indicators:
  - Empty circle: Not started
  - Checkmark + best score: Completed
  - Star icon: Perfect score (100%)
  - Attempt count: "2 attempts"

**UI Elements** (Phase 3 Enhanced):
- **SearchBar** at top
- **Filter chips** (horizontal scroll):
  - Completion filter: All/Completed/Not Started
  - Sort menu: Title/Recently Added/Best Score/Most Attempts
  - Tags button: Opens TagFilterSheet
  - Clear button: Resets all filters (only when active)
- **Passage cards** (filtered and sorted)
- **Empty state** (when no results)

**State Management**:
- `@EnvironmentObject appState: AppState` - reads completion history
- `@State private var filters: PassageFilters` - search and filter state
- `@State private var showTagFilterSheet: Bool` - sheet presentation
- Receives `progress: UserProgress` as input
- Computed: 
  * `passageCompletionInfo: [UUID: PassageCompletionInfo]` - all passage completion data
  * `filteredAndSortedPassages: [ReadingPassage]` - applies filters and sort
  * `availableTags: [String]` - unique tags from all passages

**Filtering & Sorting** (Phase 3):
- Uses `PassageFilterService.applyFiltersAndSort()` for business logic
- Filters applied first, then sorting
- Reactive: Updates instantly as user types/selects

**Supporting Types**:
- `PassageCompletionInfo` - holds attemptCount and bestScore
- `PassageCardView` - reusable card component with completion info

**Dependencies**:
- AppState (completion history)
- PassageFilterService (filtering/sorting logic)
- SearchBar, FilterChip, TagFilterSheet, EmptyStateView (UI components)
- ReadingPassageView.swift (navigation target)
- ProstTheme (styling)
- ReadingModels.swift, PassageFilters.swift (data)
- ReadingSamples.swift (mock passages)

---

#### `Views/Reading/ReadingPassageView.swift`
**Scope**: Display German text passage for reading with completion options  
**Responsibility**:
- Show full passage text
- Enable text selection for studying
- Navigate to questions when user is ready
- **Allow manual completion (without answering questions)**
- Show completion status badge if already completed

**Boundaries**:
- ✅ Passage text display
- ✅ "Continue to Questions" CTA (primary)
- ✅ "Mark as Complete" CTA (secondary)
- ✅ Completion badge display
- ✅ Manual completion logic
- ❌ No question display
- ❌ No answer collection

**Business Rules**:
- User must read passage before answering questions (enforced by flow)
- Text is selectable for translation/study
- Level indicator shown in navigation bar
- Bottom CTA buttons always visible (safeAreaInset)
- **Manual completion creates record with perfect score (1.0)**
- **"Mark as Complete" button hidden if already completed**
- **Completion confirmation alert before manual complete**
- **Success message after manual completion**
- Completion badge shown at top if passage already completed

**UI Elements**:
- ScrollView with passage text in card
- Completion badge (if completed): green with checkmark icon
- Fixed bottom buttons:
  - Primary: "Continue to Questions" (always visible)
  - Secondary: "Mark as Complete" (only if not completed)
- Navigation title: Level (e.g., "A2")
- Confirmation alert for manual completion
- Success alert after completion

**State Management**:
- `@EnvironmentObject appState: AppState` - checks/updates completion status
- `@State private var goToQuestions: Bool` - triggers navigation
- `@State private var showManualCompleteConfirmation: Bool` - shows alert
- `@State private var showSuccessMessage: Bool` - shows success alert
- Computed: `isAlreadyCompleted` - checks appState
- Receives `passage: ReadingPassage` as input

**Actions**:
- `markAsComplete()` - creates completion with score 1.0, updates appState

**Navigation Flow**:
ReadingPassageView → ReadingQuestionsView

**Dependencies**:
- AppState (completion status + updates)
- CompletionService (create completion)
- ReadingQuestionsView.swift (navigation target)
- ProstTheme (styling)
- ReadingModels.swift (data)

---

#### `Views/Reading/ReadingQuestionsView.swift`
**Scope**: Multiple-choice question answering interface with auto-completion  
**Responsibility**:
- Display all questions for the passage
- Collect user's answer selections
- Validate all questions are answered
- **Calculate score and create completion record**
- **Update user progress automatically**
- Navigate to results with completion data

**Boundaries**:
- ✅ Question display and answer collection
- ✅ Validation (all answered)
- ✅ Result generation
- ✅ Score calculation
- ✅ Completion creation
- ✅ Progress updates
- ❌ No result display

**Business Rules**:
- User must answer ALL questions before submitting
- Only one option can be selected per question
- Submit button disabled until all answered
- Button text updates dynamically: "Answer all questions (X left)" or "Submit Answers"
- **Score calculated as: correctCount / totalQuestions**
- **Completion created automatically on submit**
- **Attempt number calculated from existing completions**
- **Progress updated before navigation to results**

**UI Elements**:
- ScrollView with question cards
- Fixed bottom submit button
- Navigation title: Level (e.g., "A2")

**State Management**:
- `@EnvironmentObject appState: AppState` - creates completion, updates progress
- `@State private var selectedOptionByQuestionID: [UUID: UUID]` - tracks selections
- `@State private var showResults: Bool` - triggers navigation
- `@State private var currentCompletion: PassageCompletion?` - stores completion for results
- Computed: `results`, `unansweredCount`, `score`
- Receives `passage: ReadingPassage` as input

**Actions**:
- `submitAnswers()` - calculates score, creates completion, updates appState, navigates

**Business Logic**:
```swift
// Calculate score
let correctCount = results.filter { $0.isCorrect }.count
let score = Double(correctCount) / Double(passage.questions.count)

// Get attempt number
let attemptNumber = appState.getNextAttemptNumber(for: passage.id)

// Create completion
let completion = CompletionService.createCompletion(
    userId: appState.currentUser.id,
    passageId: passage.id,
    score: score,
    attemptNumber: attemptNumber
)

// Update app state
appState.addCompletion(completion, for: passage)

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
**Scope**: Display quiz results, attempt history, and review wrong answers  
**Responsibility**:
- **Show attempt number badge**
- Show overall score (percentage and fraction)
- **Display score comparison with previous attempts**
- **Show expandable attempt history**
- Display only wrong answers for review
- Show user's answer vs. correct answer
- **Celebrate perfect scores**
- Allow retaking the quiz

**Boundaries**:
- ✅ Score display with comparison
- ✅ Attempt history display
- ✅ Wrong answer review
- ✅ Retake functionality
- ✅ Perfect score celebration
- ❌ No answer collection
- ❌ No score calculation (received from parent)

**Business Rules**:
- Display score as percentage from completion record
- **Show attempt number at top** ("Attempt #2")
- **Compare score with previous attempts**:
  - First attempt: "First attempt complete!"
  - Improved: "Improved from 67% to 100%! 🎉"
  - Decreased: "Score: 67% (previous: 100%)"
  - Same: "Score: 67% (same as before)"
- **Show history button if multiple attempts** (expandable)
- **History shows all attempts** with:
  - Attempt number
  - Date (relative: "2 days ago")
  - Score percentage
  - Star icon for perfect scores
  - Highlight current attempt
- Only show wrong answers in review section
- **If perfect score**: Show celebration message instead of review
- Each wrong answer shows:
  - Question text
  - ❌ User's (wrong) answer
  - ✅ Correct answer
- Retake button resets state and navigates back to questions

**UI Elements**:
- Attempt badge at top (blue with number icon)
- "History" toggle button (if multiple attempts)
- Expandable history section (if toggled)
- ScrollView with score card
- Score comparison message (color-coded):
  - Green for improvements
  - Orange for decreased
  - Primary for first/same
- "Review" section with wrong answer cards
- **Perfect score celebration** (yellow banner with star)
- Fixed bottom "Retake" button
- Navigation title: Level (e.g., "A2")

**State Management**:
- `@EnvironmentObject appState: AppState` - reads completion history
- `@State private var showHistory: Bool` - toggles history display
- Receives `passage: ReadingPassage` as input
- Receives `results: [ReadingQuestionResult]` as input
- **Receives `completion: PassageCompletion` as input**
- Receives `onRetake: () -> Void` closure for reset
- Computed: `correctCount`, `wrongResults`, `scorePercentage`, `completionHistory`, `previousCompletions`, `scoreComparison`

**Business Logic**:
```swift
// Get completion history
completionHistory = appState.getCompletionHistory(for: passage.id)

// Get previous completions (excluding current)
previousCompletions = completionHistory.filter { $0.id != completion.id }

// Get score comparison
scoreComparison = CompletionService.getScoreComparison(
    newScore: completion.score,
    previousCompletions: previousCompletions
)
```

**Navigation Flow**:
- Retake → Dismisses back to ReadingQuestionsView (with reset state)

**Dependencies**:
- AppState (completion history)
- CompletionService (score comparison)
- ProstTheme (styling)
- ReadingModels.swift (data)

---

### Views Layer - Components

#### `Views/Components/LevelProgressCard.swift` (ENHANCED - Collapsible)
**Scope**: Reusable collapsible level progress card for A2/B1/B2  
**Responsibility**:
- Display level badge and summary
- **Expand/collapse to show details** (NEW)
- Show current score and completion count
- Provide navigation to passages
- Clean, minimal design

**Boundaries**:
- ✅ Visual representation of UserProgress
- ✅ Collapsible interaction
- ✅ Navigation button
- ❌ No data fetching

**Collapsed State** (Default):
- Level badge (60x60)
- Text: "5 passages • 100%" (if started) or just level name
- Status: "In Progress" or "Not Started"
- Chevron down icon (tap to expand)

**Expanded State**:
- All collapsed content
- Divider
- Current Score: 100%
- Completed: 5 passages
- "Continue Practice" button (navigation)
- Chevron up icon (tap to collapse)

**Business Rules**:
- Collapsed by default (unless current level)
- Scores displayed as integer percentages
- "Continue Practice" for all states (consistent CTA)
- Chevron rotates 180° with smooth spring animation

**State Management**:
- Receives `progress: UserProgress` as input
- Receives `@Binding isExpanded: Bool` for collapse state
- Receives `onNavigate: () -> Void` closure for navigation

**UI Elements**:
- Header button (tap to expand/collapse)
- Expanded section with stats
- "Continue Practice" action button (accent color)
- StatItem subcomponent (label + value pairs)

**Usage**:
```swift
LevelProgressCard(
    progress: userProgress,
    isExpanded: $isExpanded,
    onNavigate: { /* navigate */ }
)
```

**Dependencies**:
- ProstTheme (styling)
- ReadingModels.swift (UserProgress)

---

#### `Views/Components/GoetheA1ProgressCard.swift` (NEW - Goethe Format)
**Scope**: Special collapsible card for Goethe A1 exam format  
**Responsibility**:
- Display A1 badge and readiness status
- **Show 3-part exam structure** (unique to Goethe)
- **Expand/collapse to show part scores**
- Color-code performance per part
- Provide navigation to Goethe exams

**Boundaries**:
- ✅ Visual representation of GoetheA1UserProgress
- ✅ Collapsible interaction
- ✅ 3-part breakdown
- ✅ Readiness indicators
- ❌ No data fetching

**Collapsed State**:
- A1 badge (60x60)
- Text: "Current: 80% Ready ✓" (if started) or "Not Started"
- Chevron down icon

**Expanded State (Started)**:
- Current score + readiness status
- Divider
- Part 1: 85% ✓
- Part 2: 70% ⚠️
- Part 3: 85% ✓
- "Continue Practice" button

**Expanded State (Not Started)**:
- "Not Started" status
- Divider
- Exam structure: "3 Parts • 15 Questions • 25min"
- Part descriptions:
  * 1. Informal Texts - 5 True/False
  * 2. Situations - 5 A/B Choices
  * 3. Signs & Notices - 5 True/False
- Pass threshold: 60%
- "Start First Exam" button

**Readiness Status**:
- ≥80%: "Ready ✓" (green)
- 60-79%: "Almost Ready" (orange)
- <60%: "Keep Practicing" (orange)

**Part Status Icons**:
- ≥80%: ✓ (green)
- 60-79%: ⚠️ (orange)
- <60%: ⚠️ (red)

**State Management**:
- Receives `progress: GoetheA1UserProgress` as input
- Receives `@Binding isExpanded: Bool` for collapse state
- Receives `onNavigate: () -> Void` closure for navigation

**Supporting Components**:
- `PartScoreRow`: Part number + title + score + status icon
- `ExamPartDescription`: Numbered part list for not-started state

**Usage**:
```swift
GoetheA1ProgressCard(
    progress: goetheProgress,
    isExpanded: $isExpanded,
    onNavigate: { /* navigate to exams */ }
)
```

**Dependencies**:
- ProstTheme (styling)
- GoetheA1ReadingModels.swift (GoetheA1UserProgress)

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

#### `Views/Components/SearchBar.swift` (NEW - Phase 3)
**Scope**: Reusable search bar component  
**Responsibility**:
- Text input for searching
- Search icon indicator
- Clear button when text present
- iOS standard design

**Boundaries**:
- ✅ Search input UI
- ✅ Clear functionality
- ❌ No search logic (parent handles)

**UI Elements**:
- Magnifying glass icon (left)
- TextField (center)
- X circle button (right, when text present)
- Gray background (#systemGray6)
- 10pt corner radius

**Usage**:
```swift
SearchBar(text: $searchText, placeholder: "Search passages...")
```

---

#### `Views/Components/FilterChip.swift` (NEW - Phase 3)
**Scope**: Reusable filter chip/tag component  
**Responsibility**:
- Display filter option
- Show selected/unselected state
- Handle tap interaction
- Consistent chip styling

**Boundaries**:
- ✅ Chip UI with selection state
- ✅ Icon + text layout
- ❌ No filter logic (parent handles)

**UI Elements**:
- HStack with optional icon + text
- Rounded pill shape (20pt radius)
- Selected: Accent color background, white text
- Unselected: Gray background, primary text

**Usage**:
```swift
FilterChip(
    title: "Completed",
    systemImage: "checkmark.circle.fill",
    isSelected: true,
    action: { /* toggle filter */ }
)
```

---

#### `Views/Components/EmptyStateView.swift` (NEW - Phase 3)
**Scope**: Reusable empty state component  
**Responsibility**:
- Show icon + message when no content
- Provide clear feedback
- Consistent empty state design

**Boundaries**:
- ✅ Empty state UI
- ✅ Icon + title + message layout
- ❌ No retry/action buttons (can be added)

**UI Elements**:
- Large SF Symbol icon (48pt)
- Title text (primary)
- Message text (secondary)
- Centered layout

**Usage**:
```swift
EmptyStateView(
    icon: "magnifyingglass",
    title: "No passages found",
    message: "Try adjusting your filters"
)
```

---

#### `Views/Components/TagFilterSheet.swift` (NEW - Phase 3)
**Scope**: Tag selection sheet  
**Responsibility**:
- Display all available tags
- Multi-select functionality
- Clear selected tags
- Show AND logic hint

**Boundaries**:
- ✅ Tag selection UI
- ✅ Multi-select state management
- ❌ No tag creation

**UI Elements**:
- NavigationStack with list
- Checkmark for selected tags
- "Clear" button (toolbar, left)
- "Done" button (toolbar, right)
- Footer hint for AND logic
- Medium/Large presentation detents

**State Management**:
- Receives `availableTags: [String]` as input
- Receives `@Binding var selectedTags: Set<String>` for two-way binding

**Usage**:
```swift
.sheet(isPresented: $showSheet) {
    TagFilterSheet(
        availableTags: ["travel", "food", "culture"],
        selectedTags: $selectedTags
    )
}
```

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

## App Assets

### App Icon

#### `Assets.xcassets/AppIcon.appiconset/AppIcon.png`
**Purpose**: Official app icon for Prost  
**Dimensions**: 1024x1024 pixels (iOS universal requirement)

**Design Elements**:
- 🍺 **Beer mug with foam** - Represents "Prost!" (German for "Cheers!")
- 📋 **Papers with checkmarks** - Learning and testing
- ✏️ **Pencil** - Writing and practice
- 🇩🇪 **German flag colors** - Black, red, gold background
- ⭐ **Sparkles** - Achievement and excellence

**Symbolism**:
- **German culture**: Beer mug + flag colors
- **Celebration**: "Prost" = toast to progress
- **Learning**: Papers, checkmarks, pencil
- **Success**: Sparkles, achievement

**Technical Specs**:
- Format: PNG
- Size: 1024x1024 (required by Apple)
- Location: `Assets.xcassets/AppIcon.appiconset/`
- Configuration: `Contents.json` (universal iOS icon)
- Auto-scaling: iOS generates all sizes from 1024x1024

**Where it appears**:
- Home screen
- App Store
- Settings app
- Spotlight search
- Multitasking view
- Notifications

**Design Principles**:
- Clean, recognizable at small sizes
- Culturally relevant (German theme)
- Represents app purpose (learning + celebration)
- Professional yet friendly

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

### Completed in v2.2.0 ✅
- [x] Goethe A1 official exam format (3 parts, 15 questions)
- [x] Collapsible dashboard cards with smart ordering
- [x] Per-level progress tracking and aggregation
- [x] Search, filtering, and sorting for passages
- [x] Completion tracking (manual + automatic)
- [x] Attempt history and score comparison
- [x] App icon (Prost beer mug design)

### Architecture (Planned)
- [ ] Add dependency injection
- [ ] Implement MVVM or TCA architecture
- [ ] Add repository pattern for data access
- [ ] Implement proper error handling
- [ ] Backend API integration
- [ ] Data persistence (Core Data or SwiftData)

### Features (Planned)
- [ ] Complete Goethe A1 exam flow (not just data models)
- [ ] Other exam formats (A2, B1, B2)
- [ ] Audio support for Listening module
- [ ] Speaking practice with recording
- [ ] Writing exercises with feedback
- [ ] Spaced repetition algorithm
- [ ] Progress sync across devices (CloudKit)
- [ ] Offline mode with local persistence
- [ ] Dark mode support
- [ ] Accessibility improvements (VoiceOver, Dynamic Type)
- [ ] Localization (German UI option)
- [ ] Achievements and badges
- [ ] Study reminders and notifications

### Testing (Planned)
- [ ] Increase unit test coverage
- [ ] Add snapshot tests
- [ ] Add UI tests
- [ ] Add performance tests
- [ ] CI/CD pipeline

---

## Glossary

- **CEFR**: Common European Framework of Reference for Languages (A1-C2)
- **A1/A2**: Beginner levels
- **B1/B2**: Intermediate levels
- **C1/C2**: Advanced levels (not yet implemented)
- **Goethe-Institut**: German cultural association that administers official German language exams
- **Goethe-Zertifikat A1**: Official beginner-level German certification exam
- **Start Deutsch 1**: Alternative name for Goethe A1 exam
- **Richtig/Falsch**: German for "True/False" (question format in exam)
- **DRY**: Don't Repeat Yourself
- **CTA**: Call-to-Action (button)
- **Prost**: German word for "Cheers!"
- **SwiftUI**: Apple's modern declarative UI framework for iOS
- **Combine**: Apple's framework for reactive programming (used with @Published)
- **NavigationPath**: Type-safe navigation state in SwiftUI

---

**Last Updated**: December 13, 2025  
**Version**: 2.2.0 (Goethe A1 exam format + collapsible dashboard)

