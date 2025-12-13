# Instructions for Claude AI Assistant

## 🚨 CRITICAL: Read This Before Any Activity

This document provides mandatory guidelines for Claude (or any AI assistant) working on the Prost codebase. **Failure to follow these instructions may result in architectural violations or inconsistent code.**

---

## 📋 Pre-Activity Checklist

Before starting **ANY** task (code changes, refactoring, new features, bug fixes), you **MUST**:

### 1. ✅ Read `context.md` Thoroughly
- [ ] Open and read the entire `context.md` file
- [ ] Understand the architecture principles (DRY, SRP, Modular Design)
- [ ] Review the file-by-file breakdown to understand scope and boundaries
- [ ] Identify which files will be affected by your task
- [ ] Verify the business rules relevant to your task
- [ ] Check the extension points if adding new features

**Why**: `context.md` contains the single source of truth for:
- Project structure and organization
- Architecture principles and design patterns
- Scope and boundaries of each file
- Business rules and validation logic
- Code conventions and testing strategy

**Never assume** you know the structure—always verify against `context.md` first.

---

### 2. 🔍 Analyze Impact

After reading `context.md`, you must:

- [ ] List all files that will be modified
- [ ] Verify each modification follows the file's documented scope
- [ ] Check if any business rules will be affected
- [ ] Identify potential violations of architecture principles
- [ ] Assess if the change requires updating `context.md`

**Example Analysis**:
```
Task: Add a new question type (true/false)

Files to modify:
- Models/ReadingModels.swift (add TrueFalseQuestion model)
- Views/Components/QuestionCardView.swift (update to handle new type)
- SampleData/ReadingSamples.swift (add sample data)

Scope verification:
✅ ReadingModels.swift: Adding new model is within scope (data structures)
✅ QuestionCardView.swift: Updating UI for new type is within scope
✅ ReadingSamples.swift: Adding sample data is within scope

Business rules affected:
- Question validation logic needs update
- Scoring logic remains the same (1 correct answer)

context.md updates needed:
- Add TrueFalseQuestion to Models section
- Update QuestionCardView documentation
- Update business rules for question types
```

---

### 3. 🙋 Seek Approval BEFORE Implementation

You **MUST** present your plan to the user and get explicit approval before making **ANY** code changes:

#### Required Information in Approval Request:

1. **Summary**: Brief description of the task
2. **Files to be modified**: Complete list with reasons
3. **Architecture compliance**: Confirm adherence to principles
4. **Business rules impact**: List any affected rules
5. **context.md updates**: What will be updated
6. **Risks**: Any potential breaking changes or concerns

#### Example Approval Request:

```markdown
## 🔍 Proposed Changes: Add True/False Questions

### Summary
Add support for true/false questions in addition to multiple-choice.

### Files to Modify
1. `Models/ReadingModels.swift`
   - Add `TrueFalseQuestion` struct
   - Reason: New question type needs model representation

2. `Views/Components/QuestionCardView.swift`
   - Update to handle both question types
   - Reason: UI must support true/false display

3. `SampleData/ReadingSamples.swift`
   - Add sample true/false questions
   - Reason: Need test data for new type

### Architecture Compliance
✅ Follows Single Responsibility Principle
✅ Maintains modular structure
✅ Reuses existing components where possible

### Business Rules Impact
- New rule: True/false questions have exactly 2 options
- Existing scoring logic unchanged (1 correct answer)
- Validation logic needs minor update

### context.md Updates
Will update:
- Models section: Add TrueFalseQuestion documentation
- QuestionCardView section: Document type handling
- Business rules: Add true/false validation rules

### Risks
⚠️ Existing passages may need migration if structure changes
✅ Mitigated by keeping backward compatibility

**May I proceed with these changes?**
```

**Wait for user approval** before executing any code modifications.

---

## 📝 Mandatory Documentation Updates

### When to Update `context.md`

You **MUST** update `context.md` whenever you:

1. **Add new files**
   - Add complete file documentation (scope, boundaries, dependencies)
   - Update project structure diagram
   - Add to appropriate category (Models, Views, etc.)

2. **Modify file responsibilities**
   - Update scope and boundaries
   - Update business rules if affected
   - Add new dependencies

3. **Add new features**
   - Document new business rules
   - Update navigation flows
   - Add to extension points if applicable

4. **Change architecture patterns**
   - Update architecture principles section
   - Document new patterns or conventions
   - Update code conventions if needed

5. **Add new models or data structures**
   - Document all properties and methods
   - Explain computed properties
   - Document conformances (Identifiable, etc.)

6. **Modify UI flows**
   - Update navigation flow diagrams
   - Update state management documentation
   - Update UI elements lists

### How to Update `context.md`

1. **Read the affected section first**
2. **Make precise, surgical updates** (don't rewrite entire sections)
3. **Maintain existing format and structure**
4. **Keep consistent with existing documentation style**
5. **Update "Last Updated" date at bottom**
6. **Increment version number if significant changes**

### Example Update Process

```markdown
Task: Add LevelBadgeView component

Steps:
1. Read context.md Views/Components section
2. Add new subsection after QuestionCardView.swift
3. Follow same format:
   - Scope
   - Responsibility
   - Boundaries (✅/❌)
   - Business Rules
   - UI Elements
   - Usage example
   - Dependencies
4. Update project structure diagram
5. Commit context.md with code changes
```

---

## 🏗️ Architecture Principles (Always Follow)

### 1. **Modular Feature-Based Architecture**
- Features live in `Views/[FeatureName]/`
- Each feature is self-contained
- Shared components in `Views/Components/`
- **Never** mix feature logic across modules

### 2. **DRY (Don't Repeat Yourself)**
- Extract reusable components to `Views/Components/`
- Share theme elements via `Theme.swift`
- Use extensions for sample data in `SampleData/`
- **Never** copy-paste view logic

### 3. **Single Responsibility Principle**
- Each file has **one** clear purpose
- Views = presentation only
- Models = data + business logic
- Components = reusable UI
- **Never** put business logic in views

### 4. **Separation of Concerns**
- Models: No UI imports
- Views: No heavy business logic
- SampleData: No production code
- Theme: Only design tokens
- **Never** cross boundaries

### 5. **Scalability First**
- New modules follow existing patterns
- Components designed for reuse
- Consistent naming and structure
- **Always** think about future extensions

---

## 🚫 Strict Prohibitions

### NEVER Do the Following:

1. **❌ Make code changes without approval**
   - Always present plan first
   - Wait for explicit "yes" or "proceed"

2. **❌ Skip reading context.md**
   - Even for "simple" changes
   - Even if you think you know the structure

3. **❌ Modify files outside their scope**
   - Check boundaries section in context.md
   - Stay within documented responsibilities

4. **❌ Add business logic to views**
   - Views are presentation only
   - Logic belongs in models or view models

5. **❌ Add UI code to models**
   - Models should not import SwiftUI
   - Keep models UI-agnostic

6. **❌ Create duplicate components**
   - Check `Views/Components/` first
   - Reuse or extend existing components

7. **❌ Break naming conventions**
   - Follow conventions in context.md
   - PascalCase for types, camelCase for variables

8. **❌ Create files outside the structure**
   - Follow established folder hierarchy
   - Ask for approval if new folder needed

9. **❌ Modify theme without updating Theme.swift**
   - All design tokens in Theme.swift
   - No hardcoded colors or spacing

10. **❌ Update code without updating context.md**
    - Context.md must always reflect reality
    - Update documentation in same commit

---

## ✅ Workflow Summary

### For Every Task:

```
1. 📖 Read context.md (relevant sections)
2. 🔍 Analyze impact and plan changes
3. 🙋 Present plan and seek approval
4. ⏸️ WAIT for user approval
5. 💻 Implement approved changes
6. 📝 Update context.md if needed
7. ✅ Commit code + documentation together
```

### Example Workflow:

```bash
# Task: Add audio playback to Listening module

# Step 1: Read context.md
# (Read entire file, focus on extension points)

# Step 2: Analyze
Files to modify:
- Models/ListeningModels.swift (new)
- Views/Listening/AudioPlayerView.swift (new)
- Views/Listening/ListeningDashboardView.swift (new)
- ContentView.swift (replace placeholder)

# Step 3: Present plan
(Write detailed approval request as shown above)

# Step 4: Wait for approval
(Do nothing until user says "yes" or "proceed")

# Step 5: Implement
(Only after approval received)

# Step 6: Update context.md
- Add Models/ListeningModels.swift section
- Add Views/Listening/ sections
- Update ContentView.swift section
- Add Listening business rules
- Update extension points

# Step 7: Commit
git add .
git commit -m "feat: Add Listening module with audio playback

- Created ListeningModels.swift with audio domain models
- Built ListeningDashboardView and AudioPlayerView
- Updated ContentView.swift to include Listening tab
- Updated context.md with full Listening documentation"
```

---

## 📚 Key Files Reference

### Must-Read Files
1. **`context.md`** - Technical documentation (read first, always)
2. **`README.md`** - User-facing documentation
3. **`Theme.swift`** - Design system reference

### Critical Sections in context.md
- **Architecture Principles** - Design patterns to follow
- **File-by-File Breakdown** - Scope and boundaries
- **Business Rules Summary** - Logic and validation
- **Code Conventions** - Naming and organization
- **Extension Points** - How to add features

---

## 🎯 Common Tasks & Guidelines

### Adding a New Screen
1. Read context.md Views section
2. Determine which feature module it belongs to
3. Create file in `Views/[FeatureName]/`
4. Follow existing view patterns
5. Reuse components from `Views/Components/`
6. Document in context.md

### Adding a New Model
1. Read context.md Models section
2. Create in `Models/[Feature]Models.swift`
3. Follow struct/class guidelines
4. Implement business logic methods
5. Conform to Identifiable, Hashable if needed
6. Add sample data in `SampleData/`
7. Document fully in context.md

### Adding a New Component
1. Read context.md Components section
2. Check if similar component exists (reuse first!)
3. Create in `Views/Components/`
4. Make it generic and reusable
5. Use Theme.swift for styling
6. Add usage example in comments
7. Document in context.md

### Modifying Existing Code
1. Read context.md for that file
2. Verify change is within scope
3. Check business rules impact
4. Maintain existing patterns
5. Don't break existing functionality
6. Update context.md if scope changes

### Refactoring
1. Read context.md thoroughly
2. Ensure refactoring aligns with architecture
3. Don't break existing tests
4. Update documentation for moved code
5. Commit with clear explanation

---

## 🧪 Testing Requirements

### Before Committing
- [ ] Code compiles without errors
- [ ] No linter warnings introduced
- [ ] Existing functionality still works
- [ ] New functionality tested manually
- [ ] context.md is updated and accurate
- [ ] README.md updated if user-facing changes

### Testing Checklist (If Applicable)
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] No performance regressions
- [ ] Accessibility maintained

---

## 💬 Communication Guidelines

### When Presenting Plans
- Be specific and detailed
- List all files to be modified
- Explain architectural alignment
- Identify risks and mitigations
- Make it easy for user to approve/reject

### When Asking Questions
- Reference specific files and line numbers
- Quote relevant sections from context.md
- Provide context for the question
- Suggest potential solutions

### When Reporting Issues
- Describe expected vs actual behavior
- List steps to reproduce
- Include relevant code snippets
- Check if it's a documented business rule

---

## 🔄 Version Control Guidelines

### Commit Messages
Follow conventional commits:
```
feat: Add new feature
fix: Bug fix
docs: Documentation only
refactor: Code refactoring
test: Adding tests
chore: Maintenance tasks
```

### Always Include
- What changed (code)
- Why it changed (reason)
- context.md updates (if applicable)

### Example Good Commit
```
feat: Add pagination to passage list

- Added PagedPassageList component
- Updated LevelPassagesView to use pagination
- Added pagination controls to UI
- Updated context.md with new component docs

Business rule: Show 10 passages per page
```

---

## 🆘 When in Doubt

### If you're unsure about:
1. **Architecture** → Check context.md Architecture Principles
2. **File scope** → Check context.md File-by-File Breakdown
3. **Business rules** → Check context.md Business Rules Summary
4. **Styling** → Check Theme.swift
5. **Conventions** → Check context.md Code Conventions
6. **Anything else** → **ASK THE USER** (don't guess)

### Default Response
```
"I want to [do X], but I need clarification:
- context.md says [Y] for this file
- Your request seems to [potentially conflict/extend beyond scope]
- Should I:
  Option A: [conservative approach within scope]
  Option B: [broader approach, may need architecture change]

Please advise."
```

---

## ✨ Summary: The Golden Rules

1. **📖 Always read context.md first**
2. **🙋 Always seek approval before coding**
3. **📝 Always update context.md with changes**
4. **🏗️ Always follow architecture principles**
5. **🚫 Never violate file boundaries**
6. **♻️ Always reuse before creating new**
7. **✅ Always verify changes compile**
8. **📚 Always maintain documentation accuracy**

---

## 📌 Remember

> "The code is temporary, but the architecture is permanent. Respect the structure, follow the principles, and keep documentation in sync."

**Your job is not just to write code—it's to maintain the integrity of the codebase while implementing features.**

---

**This is a living document. Update it if you identify missing guidelines or common mistakes.**

**Last Updated**: December 13, 2025  
**Version**: 1.0.0

