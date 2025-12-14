# Using JSON Seed Data in Prost

## Overview

The app now supports loading Goethe A1 exam data from JSON files instead of using hardcoded sample data. This is an intermediate step before implementing the full REST API.

## What Was Implemented

### New Files

1. **`Prost/Services/GoetheA1JSONLoader.swift`**
   - Loads JSON from app bundle
   - Transforms seed data format → `GoetheA1ReadingExam` model
   - Handles Part 1 data (25 texts with 5 statements each = 125 questions)

2. **Updated: `Prost/SampleData/GoetheA1Samples.swift`**
   - Added `GoetheA1ReadingExam.fromSeedData` property
   - Loads real data from `reading.json`
   - Falls back to hardcoded sample if load fails

### JSON Structure Transformation

**From** (`seed_data/reading.json`):
```json
{
  "exam": "Goethe-Zertifikat A1: Start Deutsch 1",
  "part": 1,
  "tests": [
    {
      "id": "L1",
      "text": "Hallo Tom,...",
      "statements": [
        { "id": 1, "statement": "Sara ist heute bis 15 Uhr im Büro.", "answer": "R" }
      ]
    }
  ]
}
```

**To** (App Models):
```swift
GoetheA1ReadingExam {
    parts: [
        GoetheA1ReadingPart {
            partNumber: 1
            texts: [GoetheA1Text]
            questions: [
                GoetheA1Question {
                    questionNumber: 1
                    prompt: "Sara ist heute bis 15 Uhr im Büro."
                    options: [
                        GoetheA1Option(text: "Richtig"),
                        GoetheA1Option(text: "Falsch")
                    ]
                    correctOptionID: richtig.id
                }
            ]
        }
    ]
}
```

## How to Use

### Option 1: Use JSON Data (Recommended)

```swift
// In any view or view model
let exam = GoetheA1ReadingExam.fromSeedData
```

This will:
1. ✅ Load `Prost/Resources/reading.json`
2. ✅ Transform it to proper models
3. ✅ Generate UUIDs for all entities
4. ✅ Create Richtig/Falsch options automatically
5. ⚠️ Fall back to hardcoded sample if load fails

### Option 2: Use Hardcoded Sample (Legacy)

```swift
let exam = GoetheA1ReadingExam.sampleExam1
```

## Data Available

### Current Data: Part 1 Only

- **File**: `Prost/Resources/reading.json` (also in `seed_data/`)
- **Content**: 25 short informal texts (emails, SMS, notices)
- **Questions**: 125 Richtig/Falsch statements (5 per text)
- **Question Numbers**: 1-125 (continuous across all texts)

### Example Texts:
- L1: Email from Sara about office hours
- L2: SMS about bus delay
- L3: Supermarket opening hours
- ... (25 total)

## Current Limitations

### ⚠️ Only Part 1 is Available

The seed data currently only contains Part 1 of the Goethe A1 exam:
- ✅ **Part 1**: Short informal texts (True/False) - 25 texts
- ❌ **Part 2**: Situation-based (A/B choice) - Not yet available
- ❌ **Part 3**: Signs and notices (True/False) - Not yet available

**Impact**: 
- The exam will only show Part 1
- Total questions: 125 (instead of expected ~15 for a full exam)
- Duration: Still shows 25 minutes

### Solution for Complete Exam

When you have Part 2 and Part 3 data:

1. Add files to `Prost/Resources/`:
   - `reading_part2.json`
   - `reading_part3.json`

2. Update `GoetheA1JSONLoader.swift`:
```swift
static func loadGoetheA1Exams() throws -> [GoetheA1ReadingExam] {
    let part1Data = try loadSeedData(filename: "reading")
    let part2Data = try loadSeedData(filename: "reading_part2")
    let part3Data = try loadSeedData(filename: "reading_part3")
    
    let exam = try transformToExam(parts: [part1Data, part2Data, part3Data], examNumber: 1)
    return [exam]
}
```

## JSON File Requirements

### For Bundle Loading to Work:

1. ✅ File must be in `Prost/Resources/`
2. ✅ File must be added to Xcode project
3. ✅ File must be in the Prost target (Build Phases → Copy Bundle Resources)
4. ✅ File extension must be `.json`

### To Verify File is in Bundle:

Run in simulator/device and check console for:
- ✅ Success: No error messages
- ❌ Failure: "⚠️ Failed to load seed data: file not found"

## Architecture Benefits

### Why This Approach?

1. **Intermediate Step**: Bridge between hardcoded data and REST API
2. **Real Data**: Test with actual exam content
3. **No Backend Required**: Works offline completely
4. **Easy Testing**: Modify JSON files to test edge cases
5. **Model Validation**: Proves transformation logic works

### Migration Path to REST API

```
Phase 1: Hardcoded Sample Data ✅ (Was here)
         ↓
Phase 2: JSON Bundle Loading ✅ (We are here)
         ↓
Phase 3: REST API Loading 🎯 (Next step)
```

When implementing REST API:
1. API should return the **transformed format** (GoetheA1ReadingExam JSON)
2. Reuse the same Codable models
3. Replace `GoetheA1JSONLoader.loadSeedData()` with `APIService.fetchExam()`

## Testing

### Test Loading from JSON:

```swift
// In a view or test
do {
    let exams = try GoetheA1JSONLoader.loadGoetheA1Exams()
    print("✅ Loaded \(exams.count) exam(s)")
    print("   Total questions: \(exams[0].totalQuestions)")
    print("   Parts: \(exams[0].parts.count)")
} catch {
    print("❌ Failed: \(error)")
}
```

### Expected Output:
```
✅ Loaded 1 exam(s)
   Total questions: 125
   Parts: 1
```

## Error Handling

The loader handles these errors:

| Error | When | Fallback |
|-------|------|----------|
| `fileNotFound` | JSON not in bundle | Use hardcoded sample |
| `invalidJSON` | Malformed JSON | Use hardcoded sample |
| `decodingError` | JSON doesn't match structure | Use hardcoded sample |
| `missingParts` | No parts in exam | Throw error |

All errors are logged to console with `⚠️` prefix.

## Future Enhancements

### When REST API is Ready:

1. Create `PassageAPIService.swift`
2. Add endpoint: `GET /api/exams/goethe-a1`
3. Return JSON in same format as bundle files
4. Update views to fetch from API instead of bundle

### When Adding More Exams:

Current: Only `GoetheA1ReadingExam`

Future: 
- `ReadingPassage` for A2/B1/B2 levels
- Different exam types (listening, speaking, writing)

## Files Modified

- ✅ Created: `Prost/Services/GoetheA1JSONLoader.swift`
- ✅ Updated: `Prost/SampleData/GoetheA1Samples.swift`
- ✅ Existing: `Prost/Resources/reading.json` (already in project)
- ✅ Existing: `Prost/Models/GoetheA1ReadingModels.swift` (no changes needed)

## Next Steps for Issue #4

To complete REST API implementation:

1. ✅ Models are ready (`GoetheA1ReadingModels.swift`)
2. ✅ JSON transformation works (this implementation)
3. 🎯 Create `APIService.swift` (generic HTTP client)
4. 🎯 Create `PassageAPIService.swift` (exam endpoints)
5. 🎯 Update views to load from API
6. 🎯 Add loading states and error handling
7. 🎯 Add pull-to-refresh

---

**Created**: December 2024  
**Status**: Phase 2 Complete - Ready for REST API implementation

