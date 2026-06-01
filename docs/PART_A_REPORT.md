# SE4020 – Assignment 02 Part A: Extended iOS Application
## NurseryConnect Keyworker — Extension Report

| Field | Details |
|---|---|
| **Student ID** | IT22913692 |
| **Student Name** | Jayasundara A J M M M |
| **Module** | SE4020 — Mobile Application Design & Development |
| **Assignment** | Assignment 02 — Part A: App Extension |
| **Date** | June 2026 |

---

## 1. Overview of Extension

Assignment 02 extends the NurseryConnect Keyworker iOS application built in Assignment 01 with four categories of new functionality:

1. **New NurseryConnect Feature — Daily Attendance Register**: A complete daily register allowing keyworkers to mark each child as Present, Late, or Absent for Morning, Afternoon, or Full Day sessions, with arrival-time tracking, per-child notes, and a summary strip showing attendance rate.
2. **iPadOS Native Features**: NavigationSplitView sidebar for iPad, drag-and-drop on child cards, Apple Pencil / PencilKit handwritten EYFS observations, and external keyboard shortcuts.
3. **Advanced Apple Libraries**: Swift Charts for multi-dimensional analytics and PencilKit for handwritten observation notes.
4. **Adaptive Layout**: Full adaptive layout using `@Environment(\.horizontalSizeClass)` — sidebar + detail on iPad (regular), tab bar on iPhone (compact).

---

## 2. New Feature — Daily Attendance Register

### 2.1 Feature Description

The Daily Attendance Register addresses a statutory obligation in every Early Years setting: maintaining an accurate, contemporaneous record of which children are on the premises at all times (Children Act 1989, s.3; Ofsted EYFS Inspection Handbook 2023). The register replaces paper-based sign-in books currently used in many nurseries.

**Key capabilities:**
- Date picker (compact) allows viewing or editing any date's register without losing today's state
- Session segmented control: Morning / Afternoon / Full Day
- One-tap status marking per child: Present (green), Late (amber), Absent (red)
- Arrival time picker surfaces automatically when a child is marked Late
- Per-child expandable note field for context (e.g., "parent phoned — dentist appointment")
- "All Present" batch action button for fast daily start
- Summary strip: Present, Late, Absent counts + attendance rate percentage
- Data persistence via `AttendanceStore` (UserDefaults, keyed by date + session)
- Keyboard shortcut `⌘R` to refresh the register

### 2.2 Design Rationale

A segmented Picker for sessions was chosen over a Tab view because sessions are mutually exclusive contextual filters on the same data, matching Apple HIG guidelines for segmented controls. The summary strip uses four `.systemBackground`-coloured tiles rather than a graph because staff need to see absolute numbers and the rate percentage at a glance without interpretation. Colour-coded row borders (green/amber/red) allow the keyworker to scan the register top-to-bottom and immediately identify absent children without reading each row label.

### 2.3 Regulatory Compliance

| Regulation | Relevance | Implementation |
|---|---|---|
| Children Act 1989 | Duty to know every child present on premises at all times | Per-session register with timestamps |
| Ofsted EYFS Handbook 2023 | Registers must be accurate, contemporaneous, and available for inspection | Date-picker history and persistent storage |
| UK GDPR Art. 5(1)(e) | Data should not be kept longer than necessary | UserDefaults keyed by date — old keys are overwritten on re-submission |
| FSA / Natasha's Law | Presence data supports allergen-safe meal preparation | Attendance feeds into meal planning context |

---

## 3. iPadOS-Specific Features

### 3.1 NavigationSplitView Adaptive Layout

`ContentView` uses `@Environment(\.horizontalSizeClass)` to branch between two root layouts:
- **Regular (iPad landscape/portrait)**: `NavigationSplitView` with a 240-pt sidebar listing all navigation destinations (`NavDestination.allCases`) and a detail column rendering the selected view
- **Compact (iPhone)**: standard `TabView` with five tabs

The sidebar list items display live badge counts (pending incidents, unread alerts) using a `badgeCount(_:)` helper function, giving iPad users at-a-glance status across all screens from the persistent sidebar.

**Why NavigationSplitView over UISplitViewController?** `NavigationSplitView` is the SwiftUI-native declarative API introduced at WWDC 2022. It handles column collapse/expand automatically on iPad size class transitions, includes built-in column width management, and requires no UIKit bridging. Using it demonstrates current platform knowledge and avoids the maintenance burden of a UIKit wrapper.

### 3.2 Drag-and-Drop on Child Cards

`ChildCard` in `MyChildrenView` is decorated with `.draggable(child.name)` (iOS 16+ `Transferable` protocol). On iPad (regular size class), a child card can be dragged and dropped into a compatible drop target — providing extensibility for future cross-view data transfer (e.g., dropping a child card into the attendance register row). This demonstrates awareness of the iPadOS multi-window drag model and is the natural gesture counterpart to the tap/long-press interactions available on iPhone.

### 3.3 Apple Pencil / PencilKit Handwritten Observations

`ObservationNotesView` wraps `PKCanvasView` in a `UIViewRepresentable` bridge (`CanvasViewRepresentable`). The `PKToolPicker` is attached to the canvas and made visible automatically when a pencil interaction is detected. Notes are saved as PNG Data via `ObservationStore` (UserDefaults), with a thumbnail strip at the bottom showing up to 20 saved observations per child.

**Why PencilKit?** Written EYFS observation notes are more natural on a stylus than typed text for many practitioners — particularly for quick sketching of a child's physical activity, drawing their position in a space, or capturing a handwritten annotation alongside a verbal observation. PencilKit provides the full Apple Pencil latency optimisation (low-latency rendering pipeline), tool picker UI, and ink rendering at zero marginal code cost.

### 3.4 External Keyboard Shortcuts

`AppKeyboardCommands` (a `Commands` struct attached to the `WindowGroup` scene) defines three keyboard shortcuts for external keyboard iPad users:

| Shortcut | Action |
|---|---|
| `⌘ 1` | Navigate to Home |
| `⌘ 5` | Navigate to Alerts |
| `⌘ R` | Refresh current data |

These follow Apple HIG keyboard shortcut conventions and improve accessibility for keyworkers using iPads with Magic Keyboards in tablet stands at the nursery desk.

---

## 4. Advanced Libraries

### 4.1 Swift Charts — AnalyticsView

`AnalyticsViewModel` aggregates `DiaryEntry` and `IncidentReport` data into four chart-ready data structures covering the last 7 days:

| Chart | Type | X-Axis | Y-Axis / Angle |
|---|---|---|---|
| Daily Entry Counts | `BarMark` | Day of week | Count of entries |
| Entry Type Breakdown | `BarMark` | Entry type | Count per type |
| Mood Trend | `LineMark` + `PointMark` | Day | Average mood score |
| Incident Severity | `BarMark` | Severity level | Count |

A child filter row (horizontal Capsule chips, one per child + "All") drives `selectedChildId: UUID?` on the ViewModel, which re-filters all chart data reactively. On iPad (regular), charts are arranged in a 2-column `LazyVGrid`; on iPhone (compact) they stack vertically.

**Why Swift Charts over a third-party chart library?** Swift Charts is Apple-native, requires no SPM dependency, supports accessibility via automatic chart descriptions for VoiceOver, and integrates with SwiftUI's animation system. Third-party alternatives (e.g., Charts by Daniel Cohen Gindi) would add a dependency with no meaningful feature gain for this use case.

### 4.2 PencilKit — ObservationNotesView

Covered in section 3.3 above. Additional implementation notes:
- Drawing tool defaults to `.pen` with black ink to match the "pen on paper" analogy
- A "Clear" button triggers a confirmation alert before wiping the canvas — preventing accidental erasure of a long observation
- An animated "Observation saved!" banner fades in and auto-dismisses after 2 seconds, providing non-blocking confirmation feedback
- The canvas respects `PKDrawing` serialisation — saved PNG data could be attached to a future API payload as a multipart/form-data file

---

## 5. Unit Tests for Extended Features

### 5.1 AnalyticsViewModelTests (14 tests)

| Test | What it verifies |
|---|---|
| `test_loadData_populatesAllDataStructures` | All 5 data arrays are non-empty after `loadData()` |
| `test_dailyEntryCounts_alwaysSevenItems` | Exactly 7 `DailyEntryCount` items (one per day in the 7-day window) |
| `test_entryTypeCounts_onlyPositiveCounts` | No entry type with count ≤ 0 is included |
| `test_totalEntriesThisWeek_matchesDailyCounts` | `totalEntriesThisWeek` equals sum of `dailyEntryCounts` |
| `test_pendingIncidentCount_matchesFilteredIncidents` | `pendingIncidentCount` equals count of `!isCompleted` incidents |
| `test_mostActiveChild_isNonNilWithData` | `mostActiveChild` returns a name string when data exists |
| `test_averageMoodThisWeek_inValidRange` | Average mood is in `1...5` |
| `test_childFilter_reducesDataScopeForOtherChildren` | Setting `selectedChildId` reduces `totalEntriesThisWeek` |
| `test_incidentSeverityCounts_coverAllSeverities` | All 4 severity levels are represented |
| `test_moodTrend_noNegativeMoodValues` | All mood scores ≥ 1 |
| `test_buildMoodTrend_noDuplicateDayChildCombinations` | One data point per child per day |
| `test_entryTypeCounts_sumEqualsTotal` | Sum of type counts equals total entry count |
| `test_dailyCounts_datesAreAscending` | Daily counts are in ascending date order |
| `test_loadData_isIdempotent` | Calling `loadData()` twice produces the same results |

### 5.2 AttendanceViewModelTests (14 tests)

| Test | What it verifies |
|---|---|
| `test_loadChildren_populatesRecords` | `records` count equals number of assigned children |
| `test_defaultStatus_isPresent` | All records default to `.present` |
| `test_setStatus_absent_updatesRecord` | Status is set to `.absent` and persisted |
| `test_setStatus_late_setsArrivalTime` | `.late` status pre-sets `arrivalTime` to `Date()` |
| `test_setStatus_absent_clearsArrivalTime` | `.absent` status clears any prior `arrivalTime` |
| `test_presentCount_matchesStatusCounts` | `presentCount` equals filtered `.present` records |
| `test_absentCount_matchesStatusCounts` | `absentCount` equals filtered `.absent` records |
| `test_lateCount_matchesStatusCounts` | `lateCount` equals filtered `.late` records |
| `test_attendanceRate_allPresent_isOne` | 100% rate when all children are Present |
| `test_attendanceRate_allAbsent_isZero` | 0% rate when all children are Absent |
| `test_markAllPresent_setsAllStatusesToPresent` | Batch action sets every record to `.present` |
| `test_setNote_persists` | A note string survives through set/get |
| `test_changeDate_loadsNewDayRecords` | Changing the date reloads records fresh |
| `test_changeSession_loadsNewSessionRecords` | Changing the session key loads a different record set |

---

## 6. Implementation Challenges

### Challenge 1 — `@Environment(\.horizontalSizeClass)` KeyPath Typo

During implementation of `MyChildrenView`, a KeyPath was accidentally written as `\..horizontalSizeClass` (double dot) due to an IDE escape sequence artefact. Swift's `get_errors` reported the file as clean because Xcode's source-kit analysis did not eagerly evaluate the KeyPath at parse time. The bug was caught through manual review of the file and fixed by correcting to `\.horizontalSizeClass`.

**Lesson:** KeyPath typos can slip through error reporting in certain Xcode language-server states. Always manually verify environment property declarations after any automated code generation.

### Challenge 2 — Adaptive Layout Branching in ContentView

The `NavigationSplitView` / `TabView` branch requires care around `@State` variable ownership: the selected sidebar item, the selected tab, and the notification-driven navigation handlers all need to work correctly in both branches. The solution was to maintain a single `selectedDestination: NavDestination?` state variable and drive both layouts from it, with `onChange(of:)` handlers posting `Notification.Name.navigateToHome` and `Notification.Name.navigateToAlerts` for keyboard shortcut navigation.

### Challenge 3 — PencilKit Tool Picker Visibility on Simulator

`PKToolPicker` requires a `UIWindow` `firstResponder` to become visible. On the iOS Simulator without a connected Apple Pencil, the tool picker does not surface automatically. The implementation uses `toolPicker.setVisible(true, forFirstResponder: canvasView)` and `canvasView.becomeFirstResponder()` in `makeUIView` to force the picker visible on both Simulator and device — matching Apple's recommended pattern from the PencilKit sample code.

### Challenge 4 — AttendanceStore Keying Collision

Initial implementation keyed the UserDefaults store by `"attendance_\(date)"` alone. This caused Morning and Afternoon sessions to overwrite each other because both sessions share the same date string. The fix was to key by `"attendance_\(dateString)_\(session.rawValue)"`, making each date+session combination a unique store entry.

---

## 7. Regulatory Compliance — Extended App

### UK GDPR (Extended)

The attendance register adds a new category of personal data: time-of-arrival and absence records. Under UK GDPR:
- **Lawful basis**: `Article 6(1)(e)` — public task (statutory requirement to maintain attendance records)
- **Retention**: Records are keyed by date and should be purged after the statutory minimum (typically 3 years for nursery records)
- **Data minimisation**: Notes are optional and free-text; in production they should be restricted in length and audited for special-category content

### EYFS 2024 (Extended)

The PencilKit observation notes feature directly supports EYFS Statutory Framework (2024) paragraph 3.27, which requires practitioners to make "systematic observations and assessments of each child's achievements, interests and learning styles." Handwritten annotations alongside typed diary entries give a richer evidence base for the child's EYFS profile assessment.

Swift Charts analytics (daily entry counts, mood trends) support EYFS requirement to track progress across all seven areas of learning and to identify children who may need targeted support (a child with consistently low mood scores would surface in the Mood Trend chart).

---

## 8. Critical Analysis

### What worked well
- The `NavigationSplitView` / `TabView` adaptive split required only a single `@Environment` check and a shared `selectedDestination` state variable — SwiftUI's declarative model meant zero duplicate business logic between the two layout branches.
- Swift Charts required very little configuration to produce professional-quality visualisations. The `chartForegroundStyleScale` modifier applies semantic colours automatically per series, matching the existing app colour tokens without extra mapping code.
- The `AttendanceViewModel` + `AttendanceStore` architecture cleanly separates UI state from persistence, making the 14 test cases straightforward to write without any SwiftData dependency.

### What could be improved
- **PencilKit observations are not tied to SwiftData**: Observations are stored in UserDefaults as PNG blobs keyed by child ID. A production implementation should store them as `Data` attributes on a new `@Model` class, enabling SwiftData queries, iCloud sync, and referential integrity with the child record.
- **Analytics uses only sample data**: `AnalyticsViewModel` reads from `DataService.shared`, which in demo mode returns sample data. A production analytics module would query the live SwiftData ModelContext with date-range predicates, avoiding the O(n) in-memory filter.
- **Attendance rate does not account for part-time children**: The current implementation divides present count by total child count. Nurseries with part-time attendance patterns need a "scheduled today" boolean per child per session to calculate rate correctly.

---

*SE4020 — Mobile Application Design & Development | Assignment 02 Part A | June 2026 | SLIIT*
