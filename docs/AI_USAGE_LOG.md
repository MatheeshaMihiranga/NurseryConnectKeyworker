# SE4020 – Assignment 02: AI Usage Documentation
## NurseryConnect Keyworker — AI Code Generation Prompt & Response Log

| Field | Details |
|---|---|
| **Student ID** | IT22913692 |
| **Student Name** | Jayasundara A J M M M |
| **AI Tool** | GitHub Copilot (Claude Sonnet 4.6 model) via VS Code Copilot Chat |
| **Coverage** | Part A (iOS Extension) + Part B (visionOS Prototype) |
| **Date** | June 2026 |

---

## Preamble

All AI assistance was provided by GitHub Copilot (powered by Claude Sonnet 4.6) accessed through the VS Code Copilot Chat agent. Every AI-generated code block was reviewed, understood, and adapted before being committed. Where AI output was incorrect or incomplete, the underlying reason was investigated and a corrected version was implemented independently.

The log below documents the key AI-assisted interactions in chronological order. Minor style corrections and refactors are omitted for brevity.

---

## Part A — iOS App Extension

---

### Interaction 1 — Adaptive Navigation Layout

**Prompt:**
> "Rewrite ContentView.swift to support NavigationSplitView on iPad (regular size class) with a persistent sidebar showing all navigation destinations, and TabView on iPhone (compact size class). The sidebar should show live badge counts for pending incidents and unread alerts. Use NavDestination enum with allCases. Support notification-based navigation for keyboard shortcuts."

**AI Response Summary:**
Copilot generated a `ContentView` with:
- `@Environment(\.horizontalSizeClass) var sizeClass` branching
- `NavDestination: String, CaseIterable, Identifiable` enum covering all 7 destinations
- `badgeCount(_:)` helper reading from ViewModels
- `NavigationSplitView { sidebar } detail: { destinationView }` for regular
- `TabView` with matching 5 tabs for compact
- `Notification.Name` extensions for `navigateToHome` and `navigateToAlerts`

**Code Review:**
The initial output used `@ObservedObject` ViewModels (old pattern). Corrected to use `@Observable` instances created directly in the view body, consistent with the project's iOS 17 `@Observable` macro pattern. The `badgeCount` function initially used `if/else` chains — simplified to a `switch` statement for clarity.

**Code Used:** Yes, with the above adaptations.

**What I Learned:** `NavigationSplitView` requires `columnVisibility` state for programmatic sidebar toggling on iPadOS; omitting it means the sidebar is not dismissible on narrow iPad widths.

---

### Interaction 2 — AppKeyboardCommands

**Prompt:**
> "Create a Commands struct called AppKeyboardCommands for a SwiftUI app that defines keyboard shortcuts: ⌘1 for Home, ⌘5 for Alerts, and ⌘R for Refresh. Post NotificationCenter notifications so the main ContentView can react. Also define the Notification.Name.refreshData extension."

**AI Response Summary:**
Generated `AppKeyboardCommands: Commands` with three `CommandMenu` + `Button` entries using `.keyboardShortcut(KeyEquivalent("1"), modifiers: .command)`. Posted `NotificationCenter.default.post(name: .navigateToHome, object: nil)` in each action.

**Code Review:**
AI initially wrapped commands in `CommandMenu("Navigation") { }`, which adds an unwanted menu item in the macOS-style menu bar. Changed to `CommandGroup(replacing: .newItem) { }` pattern isn't ideal either — final solution used `CommandMenu` but verified it only appears on the app's Edit menu and is keyboard-only (no menu bar on iPadOS). Acceptable.

**Code Used:** Yes, minor restructuring only.

---

### Interaction 3 — AnalyticsViewModel

**Prompt:**
> "Create an @Observable AnalyticsViewModel in Swift that reads DiaryEntry and IncidentReport data from DataService.shared and produces: (1) daily entry counts for last 7 days as DailyEntryCount (date, count), (2) entry type breakdown as EntryTypeCount (type label, count), (3) mood trend as MoodDataPoint (child name, date, mood score), (4) incident severity counts as IncidentSeverityCount (severity label, count). Include child filter via optional selectedChildId UUID. All supporting types must be Identifiable."

**AI Response Summary:**
Copilot produced a complete `AnalyticsViewModel` with all four data structures, `loadData()`, and computed summary properties (`totalEntriesThisWeek`, `averageMoodThisWeek`, `pendingIncidentCount`, `mostActiveChild`). Data structures were inner structs marked `Identifiable` with `let id = UUID()`.

**Code Review:**
`buildDailyCounts()` initially used `Calendar.current.dateComponents` without specifying a timezone, which could produce off-by-one errors around midnight. Fixed to use `Calendar.current.startOfDay(for:)` consistently. `buildMoodTrend()` initially computed an average across all children — corrected to group by (childId, day) producing one data point per child per day, enabling per-child line series in Charts.

**Code Used:** Yes, with timezone and grouping fixes.

**What I Learned:** Swift Charts `LineMark` with `foregroundStyle(by: .value("Child", childName))` requires the series field to be a `String` (not UUID) — had to add `child.name` alongside the UUID in `MoodDataPoint`.

---

### Interaction 4 — AnalyticsView with Swift Charts

**Prompt:**
> "Create AnalyticsView.swift using Swift Charts. It should display four charts: BarMark daily entry counts (last 7 days), BarMark entry type breakdown, LineMark + PointMark mood trend per child (with foregroundStyle by child name), BarMark incident severity counts. Wrap each chart in a reusable chartCard(title:icon:content:) ViewBuilder. On iPad (regular size class) use a 2-column LazyVGrid; on iPhone use single column. Add a child filter row of Capsule chip buttons at the top. Add 4 stat cards below the charts."

**AI Response Summary:**
Generated complete `AnalyticsView.swift` with all four chart cards, the `@ViewBuilder chartCard` helper, adaptive grid, and child filter chips.

**Code Review:**
`Chart(vm.dailyEntryCounts) { ... }` required `import Charts` — Copilot omitted this import initially. The Capsule chip filter used `.background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))` which was correct. The `LazyVGrid` column count was driven by `sizeClass == .regular ? 2 : 1` — correct pattern. Empty state `.overlay` was added manually since AI left it out.

**Code Used:** Yes, with `import Charts` fix and empty state overlay addition.

---

### Interaction 5 — ObservationNotesView (PencilKit)

**Prompt:**
> "Create ObservationNotesView.swift using PencilKit. It should have a PKCanvasView wrapped in UIViewRepresentable, with PKToolPicker attached and made visible. A save button converts the drawing to PNG Data and saves it to UserDefaults via an ObservationStore class. Show saved observation thumbnails as a horizontal strip at the bottom. Include a clear button with confirmation alert and an animated 'Observation saved!' success banner. Cap observations at 20 per child."

**AI Response Summary:**
Generated `CanvasViewRepresentable: UIViewRepresentable`, `ObservationStore` with UserDefaults persistence, `SavedObservation: Identifiable, Codable`, the thumbnail strip, and the animated banner using `.opacity` + `.animation(.easeInOut)`.

**Code Review:**
`PKToolPicker` initialisation: AI used `PKToolPicker(userInterfaceStyle:)` — this initialiser was deprecated in iOS 16. Corrected to `PKToolPicker()`. The `toolPicker.setVisible(true, forFirstResponder: canvasView)` call needed to be inside `makeUIView` after `canvasView.becomeFirstResponder()`, not in `updateUIView`, to fire correctly on first render. The `cap of 20` logic was initially a warning-only check — hardened to silently drop saves when count reaches 20, with a user-facing message.

**Code Used:** Yes, with PKToolPicker API correction and cap hardening.

**What I Learned:** `PKToolPicker` must be added to the view's window's tool picker pool — not just to the canvas. The correct call chain is `canvas.becomeFirstResponder()` then `picker.setVisible(true, forFirstResponder: canvas)` then `picker.addObserver(canvas)`.

---

### Interaction 6 — AttendanceViewModel & AttendanceStore

**Prompt:**
> "Create AttendanceViewModel.swift with: AttendanceStatus enum (present/absent/late) with icon and color; NurserySession enum (morning/afternoon/fullDay); AttendanceRecord Identifiable Codable struct; @Observable AttendanceViewModel with loadChildren(), setStatus(), setNote(), setArrivalTime(), markAllPresent(); AttendanceStore persisting via UserDefaults keyed by date+session. Add presentCount, absentCount, lateCount, attendanceRate computed properties."

**AI Response Summary:**
Generated the complete file including all enums, `AttendanceRecord`, `AttendanceViewModel`, and `AttendanceStore`.

**Code Review:**
Critical bug: `AttendanceStore` was initially keyed by `"attendance_\(date)"` — a collision when morning and afternoon sessions share the same date. Fixed to `"attendance_\(dateString)_\(session.rawValue)"`. `attendanceRate` initially divided by `records.count` without guarding for zero — added `guard !records.isEmpty else { return 0 }`. `setStatus(.late, ...)` needed to automatically set `arrivalTime = Date()` — added this side-effect.

**Code Used:** Yes, with the three corrections above.

---

### Interaction 7 — AttendanceView

**Prompt:**
> "Create AttendanceView.swift SwiftUI view for the attendance register. Header with DatePicker (.compact style) and segmented session Picker. Summary strip with 4 tiles (Present/Late/Absent/Rate). List of AttendanceRowView subviews, each showing child name, three icon-buttons for status, expandable arrival time DatePicker (for late), expandable note TextField. All Present button at bottom. Keyboard shortcut ⌘R for refresh. Colour-coded row border per status."

**AI Response Summary:**
Generated `AttendanceView` and `AttendanceRowView` as described.

**Code Review:**
`AttendanceRowView` needed to be extracted to its own subview (AI initially inlined it as a closure inside `ForEach`) to allow `@State var showNote` per row. The `DatePicker` for arrival time needed `.labelsHidden()` to remove the redundant "Arrival Time" text alongside the existing row label. The "All Present" button was positioned in a `.safeAreaInset(edge: .bottom)` overlay rather than as the last `List` item to prevent it scrolling off screen with long child lists.

**Code Used:** Yes, with subview extraction and layout fixes.

---

### Interaction 8 — Unit Tests: AnalyticsViewModelTests

**Prompt:**
> "Write XCTest unit tests for AnalyticsViewModel. The test class must be @MainActor final class. Use DataService.shared.useSampleData = true in setUp(). Cover: loadData populates all arrays, dailyEntryCounts has exactly 7 items, entryTypeCounts only positive, totalEntriesThisWeek matches sum, pendingIncidentCount matches filtered incidents, mostActiveChild non-nil, averageMoodThisWeek in 1...5, child filter reduces scope, moodTrend no duplicates, loadData is idempotent."

**AI Response Summary:**
Generated 14 test methods as specified.

**Code Review:**
All test methods were syntactically correct. Two tests (`test_dailyCounts_datesAreAscending` and `test_buildMoodTrend_noDuplicateDayChildCombinations`) needed manual review of the assertion logic — the ascending date check used `zip(dates, dates.dropFirst()).allSatisfy { $0 <= $1 }` which is correct. The duplicate check used `Set.count == Array.count` — correct.

**Code Used:** Yes, no changes required.

---

### Interaction 9 — Unit Tests: AttendanceViewModelTests

**Prompt:**
> "Write XCTest unit tests for AttendanceViewModel. @MainActor final class. DataService.shared.useSampleData = true in setUp(). Cover: loadChildren populates records, default status is present, setStatus absent updates record, late sets arrivalTime, absent clears arrivalTime, presentCount/absentCount/lateCount, attendanceRate=1 all present, attendanceRate=0 all absent, markAllPresent, setNote persists, changeDate loads new records, changeSession loads new records."

**AI Response Summary:**
Generated 14 test methods.

**Code Review:**
`test_changeDate_loadsNewDayRecords` and `test_changeSession_loadsNewSessionRecords` needed a small adjustment — AI set `vm.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!` which is correct but also required calling `vm.loadChildren()` after the date change, which the AI omitted. Added the `vm.loadChildren()` call in both tests.

**Code Used:** Yes, with `loadChildren()` calls added to date/session change tests.

---

## Part B — visionOS Spatial Prototype

---

### Interaction 10 — visionOS App Entry Point & AppModel

**Prompt:**
> "Create a visionOS SwiftUI app entry point NurseryConnectVisionApp.swift with a WindowGroup showing the main dashboard (900x640 default size, .plain window style) and an ImmersiveSpace with ID 'immersive' and .mixed immersion style. Create AppModel.swift as an @Observable class with a VisionChild struct (not SwiftData — plain struct) containing id, name, age, room, moodScore, incidentCount, allergies. Populate with 4 hard-coded sample children. Add totalPendingIncidents and averageMoodToday computed properties."

**AI Response Summary:**
Generated both files as specified.

**Code Review:**
`ImmersionStyle.mixed` was deprecated — corrected to `.mixed` which is still valid in visionOS 2.0. `@main` annotation was present — correct. `AppModel` used `@State` inside the app struct for the model — corrected to inject it as an environment object via `.environment(AppModel())`.

**Code Used:** Yes, with the `@main` / `.environment` correction.

---

### Interaction 11 — SpatialDashboardView

**Prompt:**
> "Create SpatialDashboardView.swift for visionOS. Glass morphism main window with: top stat cards (Total Children, Pending Incidents, Average Mood), horizontal scroll of SpatialChildCard views, recent activity feed, a button to open the ImmersiveSpace. Use @Environment(\.openImmersiveSpace) and .dismissImmersiveSpace. Use .glassBackgroundEffect() for glass panels."

**AI Response Summary:**
Generated the full dashboard view.

**Code Review:**
`.glassBackgroundEffect()` is the correct visionOS API. `openImmersiveSpace` requires `await` — AI correctly wrapped the call in `Task { await openImmersiveSpace(id: "immersive") }`. The dismiss button needed a `@State var isImmersiveSpaceOpen: Bool` toggle to show/hide correctly — AI included this. `hoverEffect(.highlight)` on child cards is correct for visionOS.

**Code Used:** Yes, no significant changes.

---

### Interaction 12 — ImmersiveChildPanelsView (RealityKit)

**Prompt:**
> "Create ImmersiveChildPanelsView.swift using RealityKit RealityView for visionOS. Build a scene with one Entity panel per child arranged in a parabolic arc (xOffset from -0.6m to +0.6m, zOffset = -0.06 * xOffset²). Each panel is a box mesh (0.25×0.35×0.01m) with SimpleMaterial coloured by mood (green if mood≥4, amber if mood==3, red if mood<3) or red if incidentCount>0. Add a mood sphere (0.04m radius) floating above each panel. Add a floor ring (32 box segments in a circle, radius 1.3m). Add InputTargetComponent + CollisionComponent. Implement TapGesture.targetedToAnyEntity with scale pulse highlight (scale 1.0→1.1→1.0 animation)."

**AI Response Summary:**
Generated `ImmersiveChildPanelsView` with full RealityKit scene construction, parabolic layout, SimpleMaterial colouring, floor ring, input components, and tap gesture handler.

**Code Review:**
`SimpleMaterial(color: .green, isMetallic: false)` is the correct RealityKit API for visionOS. The parabolic arc formula `zOffset = -0.06 * pow(xOffset, 2)` is correct — produces a subtle curve pulling the outer panels slightly closer to the viewer. `SpatialTapGesture().targetedToAnyEntity()` is the correct visionOS gesture API (not `TapGesture`). The scale pulse animation used `withAnimation(.spring(duration: 0.2)) { entity.scale = ... }` — this is incorrect for RealityKit; corrected to `entity.scale = .init(repeating: 1.1)` then `DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { entity.scale = .init(repeating: 1.0) }`.

**Code Used:** Yes, with gesture API and scale animation corrections.

**What I Learned:** RealityKit Entity transforms in visionOS do not participate in SwiftUI's animation system. Scale, position, and rotation animations must be applied via `entity.scale` assignment with manual timing, not `withAnimation {}` blocks.

---

### Interaction 13 — SpatialChildDetailView

**Prompt:**
> "Create SpatialChildDetailView.swift for visionOS. A sheet with a TabView containing three tabs: Overview (name, age, room, allergies, mood score, incident count), Diary (3 hard-coded sample diary entries as a list), Health (medical notes and emergency contact). Use .glassBackgroundEffect(). Style with large SF Symbols and visionOS-appropriate spacing."

**AI Response Summary:**
Generated the complete three-tab detail view.

**Code Review:**
Minor: AI used `TabView(selection:)` with `.tag()` modifiers — correct pattern. Glass background on the sheet required `.presentationBackground(.ultraThinMaterial)` in addition to `.glassBackgroundEffect()` on inner containers — added.

**Code Used:** Yes, with presentation background addition.

---

## Summary

| Interaction | Feature | AI Accuracy | Corrections Needed |
|---|---|---|---|
| 1 | ContentView adaptive navigation | Good | `@Observable` pattern fix |
| 2 | AppKeyboardCommands | Good | CommandMenu placement review |
| 3 | AnalyticsViewModel | Good | Timezone + mood grouping fixes |
| 4 | AnalyticsView (Swift Charts) | Good | Missing `import Charts` |
| 5 | ObservationNotesView (PencilKit) | Moderate | Deprecated PKToolPicker init |
| 6 | AttendanceViewModel | Good | Key collision bug, arrivalTime side-effect |
| 7 | AttendanceView | Good | Subview extraction, layout fixes |
| 8 | AnalyticsViewModelTests | Excellent | No changes |
| 9 | AttendanceViewModelTests | Good | Missing `loadChildren()` calls |
| 10 | visionOS App + AppModel | Good | Environment injection fix |
| 11 | SpatialDashboardView | Excellent | No significant changes |
| 12 | ImmersiveChildPanelsView | Moderate | Gesture API + scale animation |
| 13 | SpatialChildDetailView | Excellent | Presentation background fix |

**Overall assessment:** GitHub Copilot (Claude Sonnet 4.6) was highly effective for scaffolding SwiftUI views and ViewModel boilerplate. It required correction most often on platform-specific APIs (PencilKit deprecated inits, RealityKit animation system) — areas where training data may lag behind the latest SDK documentation. Unit test generation was consistently accurate. All generated code was reviewed against Apple's official documentation before being committed.

---

*SE4020 — Mobile Application Design & Development | Assignment 02 | June 2026 | SLIIT*
