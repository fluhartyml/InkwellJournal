/*
====================================================
Developer Notes Log
====================================================
- [2025-10-02 10:20] (ChatGPT) Workflow communication improvement: User clarified that explicit, unambiguous "Ready for Clean Build Folder and Rebuild" messages are required after code updates. Going forward, assistant will always confirm when changes are implemented and testing can safely begin. Status will be clearly communicated at each step to prevent waiting confusion. EntryDetailView navigation fix is complete; user is now clear to test and verify back chevron.
- [2025-10-02 10:13] (ChatGPT) Regression: EntryDetailView now traps user—system back chevron is missing, so there is no way to navigate back to the previous screen after viewing an entry. This occurred after recent toolbar and layout fixes. Plan: Restore system back navigation by reverting to standard NavigationStack push/pop behavior for EntryDetailView; ensure .navigationBarBackButtonHidden(false) is set (or removed if present). User cannot exit detail view without force-quitting. Next: immediate code fix.
- [2025-10-02 08:55] (ChatGPT) UI fix session start—Entry Detail/Modal Fix Sequence initiated from screenshots.
  - Issue: Entry detail view displays both Edit and Done in toolbar at the same time, with oversized typography/layout. New Entry sheet layout is mostly correct, but typography should be reviewed for consistency.
  - Plan: 1) Refactor EntryDetailView button logic so Edit/Done are mutually exclusive and follow UX spec, 2) Adjust entry title/mood/date typography to match iOS standards, 3) Confirm and relax text style/layout in NewEntryView. All changes will be logged here as chat resets occur.
  - Waiting for user to confirm if NewEntryView also needs tweaks or if detail view is priority.
- [2025-10-01 18:50] (ChatGPT) UX decision recorded: New Entry uses a sheet (Cancel/Done); Existing Entry uses a push detail with back chevron and Cancel/Done while editing.
  - New Entry (Option A): Present modal editor; prefer create-on-Done (no pre-insert). On Done, create and insert `JournalEntry`; on Cancel, just dismiss (no ghost rows). Alternative: pre-insert then delete on Cancel if reusing a bound editor.
  - Existing Entry: Push in NavigationStack; show the system back chevron when not editing. While editing, hide the back button and show leading Cancel (discard drafts) and trailing Done (apply drafts). Maintain a local draft buffer (title/content/mood) and write to the model on Done only.
  - Next steps (when approved): add `NewEntryView` sheet and update the detail view’s toolbar/back behavior; keep all other behavior unchanged.
- [2025-10-01 12:00] (ChatGPT) LaunchScreen.storyboard not found on disk in InkwellJournal group. Plan: create it via Xcode UI (File > New > File > iOS > User Interface > Storyboard, name `LaunchScreen.storyboard`, add to target InkwellJournal), then clean/reinstall.
- [2025-10-01 11:52] (ChatGPT) LaunchScreen.storyboard must be added to the target via Xcode UI; tool cannot add files to target membership. User will add file to project (no copy), ensure Target Membership checked, then clean/reinstall.
- [2025-10-01 11:47] (ChatGPT) UILaunchStoryboardName set via Info tab; proceeding with membership check and reinstall.
  - Set Info → Custom iOS Target Properties: `UILaunchStoryboardName` (Launch screen interface file base name) = `LaunchScreen` (String).
  - Next steps: 1) Verify `LaunchScreen.storyboard` Target Membership includes InkwellJournal, 2) Clean Build Folder, 3) Delete app, 4) Build & Run.
  - Expected: No letterboxing; logo launch appears briefly before home list.
- [2025-10-01 11:28] (ChatGPT) Applying first-open plan: all code-side changes done; awaiting target setting flip to enable LaunchScreen.
  - Implemented: Opaque nav bars (all screens), large title on home, empty-state copy, logo asset + LaunchScreen.storyboard + blank fallback storyboard. Preview helper added for logo.
  - Blocking step (requires Xcode UI): Set Build Settings → Info.plist File (INFOPLIST_FILE) to `InkwellJournal/Info.plist`, ensure LaunchScreen.storyboard is in Target Membership, then Clean Build Folder and reinstall the app.
  - After you flip the setting and reinstall, we should see no black bars and the logo launch. If not, I’ll triage with a screenshot of the Build Settings row.
- [2025-10-01 11:20] (ChatGPT) First-opening experience plan + letterboxing status.
  - Current: App still appears letterboxed on device (black bars top/bottom). Launch screen not applied yet — likely target still using generated Info.plist instead of InkwellJournal/Info.plist that contains `UILaunchStoryboardName = LaunchScreen`. Both LaunchScreen.storyboard (logo) and LaunchScreenBlank.storyboard exist and are in the project.
  - Desired first-open UX (agreed proposal):
    1) Launch Screen: system background with centered journal logo (no text), matching app background; instant handoff.
    2) First Frame: `NavigationStack` list with large title “My Journal”, trailing + button; opaque navigation bar; content begins immediately under the bar (no oversized header card).
    3) Empty State (when no entries): icon + “Start Your Journal” headline + “Tap the + button…” helper text.
    4) Non-empty State: recent entries list (current UI), keeps image thumbnails and chips. 
  - Action items to remove letterboxing (blocking):
    1) Point Build Settings → Info.plist File (INFOPLIST_FILE) to `InkwellJournal/Info.plist`.
    2) Ensure `LaunchScreen.storyboard` is in Target Membership.
    3) Product → Clean Build Folder; delete app; build & run.
    4) If still letterboxed, capture screenshot of Build Settings (Info.plist File row) + device model/iOS version for triage.
  - Next implementation after letterboxing resolves:
    - Confirm nav bar opacity across views (already added).
    - Widen/relax `NewEntryView` text editor area and keyboard behavior.
    - Optional: Onboarding overlay with one-time “Add your first entry” nudge.
- [2025-09-27 11:26] (ChatGPT) Safety guard: ModelContainer? with conditional .modelContainer; shows a simple error UI if all stores fail (CloudKit/local/memory). Prevents app crash during provisioning.
- [2025-09-27 11:22] (ChatGPT) Startup crash fix: removed remaining try! and added in‑memory final fallback. Console logs indicate which store is active (CloudKit/local/memory) for debugging.
- [2025-09-27 11:15] (ChatGPT) Hotfix: try! on CloudKit ModelContainer caused fatal error (loadIssueModelContainer). Now using do/catch with local fallback; logs the error for triage. Once container is fully provisioned, app will use CloudKit automatically on next launch.
- [2025-09-27 11:12] (MF) TL;DR style policy: concise answers (one short paragraph unless more is requested), single‑action instructions with screenshot pauses, number batched steps as 1) 2) 3), avoid tables and long preambles.
- [2025-09-27 10:38] (MF) Backlog: Add "Angry" emotion to mood list before App Store submission.
  - Update moods arrays in NewEntryView and EntryDetailView to include "Angry".
  - Add color mapping/chip style for "Angry".
  - Smoke test: create/edit entries and verify CloudKit sync + UI display across devices.
- [2025-09-27 10:27] (ChatGPT) Correction: Some SwiftData versions don’t accept the configurations parameter in the .modelContainer(for:) modifier; we now create a CloudKit-backed ModelContainer in App.init and pass it with .modelContainer(container).
- [2025-09-27 10:20] (ChatGPT) Switched SwiftData to CloudKit-backed container: .modelContainer(for: JournalEntry.self, configurations: ModelConfiguration(cloudKitDatabase: .automatic)). Ensure iCloud is enabled for the app ID and both test devices are logged into the same Apple ID.
- [2025-09-27 10:12] (MF) Added first journal entry successfully (title + mood). Proceeding to persistence check on relaunch.
- [2025-09-27 10:10] (MF) Backlog (pre‑release): "Selfie" option should open front camera by default; currently opens rear camera and requires manual switch. Camera flow otherwise works; defer fix until core stability is confirmed.
- [2025-09-27 09:55] (ChatGPT) Switched NewEntryView presentation from .sheet to .fullScreenCover to address device freeze when tapping +.
- [2025-09-27 09:48] (ChatGPT) Removed info (i) button from iOS splash/navigation bar and deleted related alert/state; not required for App Review. Only the + button remains on the landing screen.
- [2025-09-27 09:40] (MF) Preference: Keep assistant responses to one or two short paragraphs; I will ask for more detail if needed (TL;DR style).
- [2025-09-27 09:37] (MF) App installed successfully on iPhone; landing screen visible. Next: test + create flow, confirm permissions, and verify data persists across relaunch.
- [2025-09-27 09:18] (ChatGPT) Policy added: Number batched steps as 1) 2) 3) with a close parenthesis; continue single-paragraph recaps.
- [2025-09-27 09:00] (ChatGPT) Policy added: Keep all recaps of instructions and steps within a single paragraph; developer notes remain private and excluded from the app build.
- [2025-09-27 08:45] (MF) Automatic Signing ON with correct Team; bundle identifier set to com.inkwell.InkwellJournal.
- [2025-09-27 08:45] (MF) Next two steps: Build Settings — confirm PRODUCT_BUNDLE_IDENTIFIER for Debug/Release and set INFOPLIST_FILE to InkwellJournal/Info.plist (avoid root duplicate). Then Clean Build Folder and re-run on device.
- [2025-09-27 08:34] (MF) Set Display Name to "Inkwell Journal" and confirmed Bundle Identifier = com.inkwell.InkwellJournal. Using "inkwell" as org prefix moving forward.
- [2025-09-27 08:34] (MF) Next actions: Verify Automatic Signing + Team; in Build Settings confirm PRODUCT_BUNDLE_IDENTIFIER for all configs and set INFOPLIST_FILE to InkwellJournal/Info.plist (avoid duplicate root Info.plist).
- [2025-09-27 08:21] (MF) Policy reaffirmed: Focus on bug/error fixes only; track enhancements in notes until app is running; implement before release.
- [2025-09-27 08:21] (MF) Error triage: Device install failed with "The item at InkwellJournal.app is not a valid bundle" and suggestion to ensure CFBundleIdentifier in Info.plist. Duplicate Info.plist files visible in navigator; will point build setting to correct file or rely on generated Info.
- [2025-09-27 08:21] (MF) First two fix steps:
  - General tab: set a reverse‑DNS Bundle Identifier and enable Automatic Signing with the correct Team.
  - Build Settings: verify PRODUCT_BUNDLE_IDENTIFIER matches and INFOPLIST_FILE points to the app target’s Info.plist (e.g., InkwellJournal/Info.plist).
- [2025-09-26 19:50] (MF) Enhancement backlog (post-stabilization, pre-release):
  - Live word/character count in Compose.
  - Mood color mapping for chips.
  - Debug-only "Add Sample Data" button.
- [2025-09-26 19:50] (MF) Policy reaffirmed: Focus on bug/error fixes only; track enhancements in notes until app is running; implement before release.
- [2025-09-26 19:40] (MF) GitHub push successful: main branch now tracking origin/main; repo intentionally public for transparency; personal name removed from source.
- [2025-09-26 19:40] (MF) PII policy: Keep personal name out of source/UI; assistant uses MF, I sign as MLF.
- [2025-09-26 19:20] (MF) Policy: GitHub is sync-only (staging/commit/pull/push via Xcode). No GitHub Actions, workflows, badges, issue/PR templates, bots, webhooks, Pages, or CI services.
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
