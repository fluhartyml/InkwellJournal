// 2025 SEP 26 - 1833 - InkwellJournal_Developer Notes (Michael Fluharty)
//  InkellJournal_DeveloperNotes.swift
//  Inkwell Journal
//
//  Human‑readable developer notes for this project. Keep this file in source control.
//  When you (or ChatGPT) say: "add to developer notes", append the note under the
//  "Developer Notes Log" section below.
//
//  This file is intentionally mostly comments so it does not affect the build.
//


import Foundation

/*
====================================================
Journal App — Developer Notes
====================================================

Purpose
- Single place to capture decisions, TODOs, and workflow tips.
- Append new entries at the bottom in the "Developer Notes Log" section with a timestamp.
- Serves as PERSISTENT MEMORY & VIRTUAL SWAP FILE across AI chat sessions.

How to use this file
- When you want to record something, add a new entry under "Developer Notes Log" like:
  [YYYY-MM-DD HH:MM] (author) Short description of the decision, idea, or TODO.
- Keep entries concise. If longer, add a sub‑bullet list.
- Example: "[2025-09-26 13:00] (MF) GitHub Actions removed - repository now for sync only."

Rules & Guidance for ChatGPT/Claude (Persistent Memory)
- When the user says "check the developer notes" or "add to developer notes", they mean THIS file: JournalApp_DeveloperNotes.swift.
- Do NOT write logs to any runtime-accessible file. Only append comments inside this file.
- Do NOT wire this file into the app at runtime (do not import/read/parse it from app code).
- Append new entries under the section "Developer Notes Log" using this format:
  [YYYY-MM-DD HH:MM] (AUTHOR) Message. Use MF for Michael Fluharty; use Claude for Claude entries; use ChatGPT for ChatGPT entries.
- Newest entries go at the TOP of the Project Status section; the Developer Notes Log can be chronological or reverse — keep newest at the top for quick scanning when requested.
- For multi-line notes, use simple "-" bullets. Avoid images and tables.
- If a note implies code changes, treat that as a separate, explicit task; do not change code unless requested.

CRITICAL WORKFLOW RULES:
- AI ASSISTANTS DO ALL HEAVY LIFTING: AI does 100% of coding, file creation, problem-solving, and technical work.
- USER DOES MINIMAL ACTIONS ONLY: User only performs actions that AI assistants are physically prohibited from doing in Xcode.
- STEP-BY-STEP SCREENSHOT METHODOLOGY:
  * AI gives ONE specific, minimal instruction (e.g., "Click the + button", "Select this menu item")
  * User performs ONLY that single action
  * User takes screenshot showing the result
  * User uploads screenshot to AI
  * AI MUST PAUSE and wait for screenshot before giving next instruction
  * This creates a calm, methodical, stress-free workflow
- USER PREFERS XCODE-ONLY WORKFLOW: No terminal commands ever.
- FOCUS ON BUGS/ERRORS ONLY: Enhancements and new features go in notes only, not implemented unless fixing a bug.

- Commit message style: short, imperative, informative (e.g., "Fix journal entry save bug").
- When asked to "summarize developer notes", summarize ONLY content from this file; do not invent or reference external logs.
- When asked to "clear notes" or remove entries, confirm explicitly before deleting or truncating any log content.
- Treat this file as the single source of truth for decisions, conventions, and project-wide guidance.
- Only ChatGPT and Claude will read and work from this file. Treat it as the collaboration ledger for this project.
- Maintain a running section titled "Project Status & Chat Summary" in this file; after each working session, append a brief summary with timestamp, current context, key changes, and next steps.
- This file serves as continuity between chat sessions since AI assistants don't remember previous conversations.

GitHub & Repository Policy
- GitHub serves ONLY as backup and sync service between multiple development machines
- NO automated builds, testing, or CI/CD pipelines
- NO GitHub Actions workflows
- Repository is purely for: push from Machine A → pull on Machine B
- Keep repository clean and simple for code sync only

HISTORICAL CONTEXT (From Previous Session Files):
- LeftOff.swift revealed Journal App was never successfully launched - stuck in target/scheme configuration phase
- Previous chatbot had created complete 1076+ line iOS journal app (ContentView_iOS.swift) with full features
- App had camera integration, document scanning, iCloud sync, but wouldn't launch due to project configuration issues
- Error: "Cannot preview in this file - No selected scheme" prevented proper testing
- Mac Mini had limited simulators, MacBook had full iOS device provisioning
- MiniNotes files showed coordination challenges between workspace-scoped and project-scoped assistants
- ContentView files were removed from Xcode project (likely by previous chatbot attempting fixes)
- Nuclear rebuild approach chosen to avoid inherited configuration problems

Quick project snapshot
- Platform: Multi-platform SwiftUI app (iOS and macOS intended)
- Testing: Using modern Swift Testing framework
- Current state: Clean rebuild with zombie identification system, testing file accessibility
- Architecture: Standard SwiftUI app structure with platform-specific views
- Main files: Journal_AppApp.swift (main app), ready for ContentView_iOS/macOS implementation

Coding conventions
- Swift 6, prefer SwiftUI and modern Swift patterns
- Use async/await for concurrency
- Keep UI in SwiftUI with NavigationStack and #Preview
- Focus on Apple platform best practices
- Multi-platform compatibility (iOS/macOS)

Data model summary
- JournalEntry: Core model with title, content, date, mood, image support (to be recreated)
- Platform-specific managers for iOS/macOS persistence (to be recreated)
- iCloud Drive integration with local fallback (to be recreated)

Persistence
- iOS: JournalManager with iCloud Drive + local Documents fallback (to be recreated)
- macOS: MacJournalManager with separate file (journal_entries_mac.json) (to be recreated)
- JSON-based storage with automatic migration (to be recreated)

====================================================
Project Status & Chat Summary
- [2025-09-26 19:15] (ChatGPT) Session summary: Documented GitHub setup parameters; ready for Xcode-only sync workflow.
  - Added GitHub setup parameters to Developer Notes Log (private repo, sync-only, Xcode Source Control, no CI/CD).
  - Reaffirmed repository policy: no Actions, no automated builds/tests; keep repo clean and simple.
  - Next steps: Initialize repo in Xcode (if not already), add GitHub remote, first push from Xcode.
- [2025-09-26 18:58] (ChatGPT) Session summary: Confirmed persistent memory via Developer Notes; author tag convention clarified; no runtime changes.
  - Confirmed persistent memory across new chat sessions without retraining.
  - Clarified terminology: "notes" and "log" both refer to Developer Notes; prefer "notes".
  - No runtime changes; comments-only updates to Developer Notes.
- [2025-09-26 16:40] (Claude) Session summary: Testing file creation and accessibility experiment
  - User experimenting with zombie system by marking JournalApp_DeveloperNotes 5.swift
  - Testing what happens when AI creates new unnumbered developer notes file
  - Investigating accessibility patterns between AI tools and Xcode project structure
  - Confirmed: AI can create files but they may not immediately appear in Xcode navigator
  - User's zombie identification system continues to work for systematic cleanup
  - Git workflow completed successfully - all changes version controlled
  - Next steps: Continue testing file system behavior, then implement journal features

- [2025-09-26 16:35] (Claude) Session summary: Git workflow completion and zombie testing
  - User successfully completed fetch, stage, commit, and push to GitHub
  - All zombie markings and clean project foundation now version controlled
  - User testing zombie system functionality with developer notes files
  - Confirmed clean files exist but are not accessible through AI file tools
  - Project ready for journal functionality implementation when testing complete

- [2025-09-26 15:50] (Claude) Session summary: Zombie file cleanup and developer notes recreation
  - User implemented smart zombie identification system using /* Zombie File */ markers
  - Confirmed logic: numbered files = zombies, clean unnumbered files should exist
  - User's zombie marking strategy ensures safe cleanup without losing important content
  - Clean developer notes system established for persistent memory across AI sessions

====================================================
Developer Notes Log
- [2025-09-26 19:20] (MF) Policy: GitHub is sync-only (staging/commit/pull/push via Xcode). No bells & whistles.
  - No GitHub Actions, workflows, badges, issue/PR templates, bots, webhooks, Pages, or CI services.
  - No third-party CI/CD or automation; no release pipelines.
  - Do not add code or dependencies solely to support GitHub features.
  - README stays minimal (no shields). Repository metadata optional.
  - Xcode-only workflow: use Source Control UI; no terminal.
  - Any future automation requires explicit approval in Developer Notes.
- [2025-09-26 19:10] (MF) GitHub setup parameters for this project (sync-only, Xcode-only workflow):
  - Visibility: Private GitHub repository.
  - Purpose: Sync between machines only (no CI/CD, no GitHub Actions, no automated builds/tests).
  - Default branch: main.
  - Remote name: origin.
  - Auth: Xcode > Settings > Accounts with GitHub Personal Access Token (scope: repo). No terminal usage.
  - Workflow: Use Xcode Source Control for commit, pull, push. Avoid force-push.
  - Branching: Single main branch; short-lived feature branches optional; delete after merge.
  - Merge strategy: Xcode default merge; avoid rebase unless necessary.
  - .gitignore guidance: ignore .DS_Store, xcuserdata/, *.xcuserdatad, *.xcscmblueprint, .swiftpm/, .build/, Packages/; never commit DerivedData or user-specific files.
  - LFS: Not used.
  - Binary size: Keep committed files < 100 MB; avoid committing generated artifacts.
  - Issues/PRs: Optional; repo is for sync only.
  - Commit messages: short, imperative, informative (e.g., "Fix journal entry save bug").
  - Conflict resolution: Use Xcode's merge tool; build/tests should pass before pushing.
- [2025-09-26 18:58] (MF) Milestone: Persistent memory working across new chat sessions; assistant recognized context without retraining.
- [2025-09-26 18:50] (MF) Author tag convention: assistant uses (MF); I may write my full name in content as desired.
- [2025-09-26 16:40] (Claude) Created new unnumbered JournalApp_DeveloperNotes.swift file to test AI file creation accessibility in Xcode environment.
- [2025-09-26 16:35] (Claude) User zombified JournalApp_DeveloperNotes 5.swift to test system. Confirmed AI tools cannot access clean unnumbered files that exist in Xcode.
- [2025-09-26 16:30] (Claude) User completed successful Git workflow: fetch, stage, commit, push. All zombie markings and project foundation now version controlled.
- [2025-09-26 15:50] (Claude) Recreated clean developer notes file with zombie identification system documentation and complete historical context.
- [2025-09-26 15:45] (Claude) User implemented smart zombie marking strategy using /* Zombie File */ in numbered duplicates for safe identification and cleanup.
- [2025-09-26 15:30] (Claude) Nuclear rebuild: Created foundational files after user deleted duplicates. Clean slate ready for proper journal app implementation.
- [2025-09-26 14:05] (Claude) Added proper name attribution to timestamps in developer notes.
- [2025-09-26 14:00] (Claude) Added critical workflow rules: AI does all coding/heavy lifting, user does minimal Xcode actions only, screenshot methodology.
- [2025-09-26 13:55] (Claude) Created developer notes file and established persistent memory system for Journal App project.
- [2025-09-26 13:00] (Claude) GitHub Actions workflows removed - repository configured for sync-only usage as requested by user.

// Add new notes above this line. Keep newest entries at the top for quick scanning.
*/

public enum DeveloperNotesAnchor {}

