# SE4020 – Mobile Application Design & Development
## Assignment 01 — NurseryConnect iOS MVP

> **Submission Instructions:** Edit this file directly with your report. No separate documentation is required. Commit all your Swift/Xcode project files to this repository alongside this README.

---

## Student Details

| Field | Details |
|---|---|
| **Student ID** | IT22913692 |
| **Student Name** | Jayasundara A J M M M |
| **Chosen User Role** | Keyworker |
| **Selected Feature 1** | Daily Diary Management |
| **Selected Feature 2** | Incident Report Management |

---

## 01. Feature Selection & Role Justification

### Chosen User Role
A **Keyworker** is a dedicated nursery staff member assigned a specific group of children. Their core responsibilities include observing and recording each child's daily experiences (meals, naps, mood, activities), responding to safeguarding alerts, and formally documenting any incidents that occur during the nursery day. They act as the primary point of contact between the nursery and the child's parent or guardian.

### Selected Features

**Feature 1 — Daily Diary Management**
The Daily Diary feature allows a keyworker to log, view, search, and filter daily observations for their assigned children. Each entry captures a type (Meal, Nap, Activity, Mood/Wellbeing, Nappy, General), a title, a detailed description, optional notes, and is linked to a specific child and timestamped automatically. Entries are grouped by date and displayed in reverse-chronological order. A quick-add flow accessible from both the Diary screen and the My Children screen allows rapid entry creation during a busy nursery day.

**Feature 2 — Incident Report Management**
The Incident Report feature enables a keyworker to create, view, filter, and track formal incident reports. Each report captures the incident category (Injury, Behaviour, Allergic Reaction, Safeguarding, Medical, Other), severity (Minor, Moderate, Serious, Major), a detailed description, the location, and the child involved. Reports carry a dual-acknowledgement status tracking whether the parent has been notified and whether the manager has reviewed the report. The list view separates pending reports from completed ones and supports filtering by category, severity, and free-text search.

### Justification
These two features form the operational backbone of a keyworker's daily workflow. The Daily Diary satisfies the EYFS 2024 requirement that practitioners observe and document each child's learning and development continuously. The Incident Report satisfies the statutory obligation to record, report, and follow up on any accident or safeguarding concern, as required by the Children Act 1989 and Ofsted standards.

Together they create a coherent loop: a keyworker begins the day logging routine diary observations, and if anything significant occurs — a fall, an allergic reaction, a behaviour concern — they immediately raise an incident report. Both features share the same underlying child data model and data service layer, making them naturally complementary and realistic for a four-week MVP.

---

## 02. App Functionality

### Overview
NurseryConnect Keyworker is a native iOS application built with SwiftUI and SwiftData. It provides a keyworker with a single, focused interface to manage their assigned children's daily records. The app launches directly to a Home dashboard showing today's key statistics, then offers four further screens via a tab bar: My Children, Daily Diary, Incident Reports, and Alerts. All data is persisted on-device using SwiftData and a fully populated sample dataset is included for demonstration.

### Screen Descriptions

**Screen 1 — Home**

The Home screen presents a two-by-two stats grid showing today's Diary Entries count, Pending Incidents count, Critical Alerts count, and Overdue Logs count. Below the grid, the three most recent diary entries are shown inline, with a "View All" link to the full Diary screen. High-priority alerts are surfaced in a dedicated section with direct navigation to the Alerts screen. A branded header with the NurseryConnect logo and keyworker name appears at the top.

<img src="resource/screen01.jpeg" width="300">

**Screen 2 — My Children**

The My Children screen lists all children assigned to the current keyworker. Each child card shows the child's avatar, name, age, room, and any allergy or dietary badges. Tapping a card opens a detail sheet. Beneath each card, four quick-action buttons (Log Meal, Log Nap, Log Mood, Incident) allow the keyworker to start a diary or incident entry pre-populated with that child's details. A search bar at the top filters children by name or room in real time.

<img src="resource/screen02.jpeg" width="300">

**Screen 3 — Daily Diary**

The Daily Diary screen shows all diary entries for the keyworker's assigned children, grouped by date in descending order. A horizontal filter chip row allows filtering by entry type (Meal, Nap, Activity, Mood, Nappy). A search bar supports free-text search across child name, entry title, and description. Tapping the `+` button opens the Add Diary Entry sheet. Each entry card is colour-coded by type and displays the entry title, child name, timestamp, relative time, description, and the recording keyworker's name.

<img src="resource/screen03.jpeg" width="300">

**Screen 4 — Incident Reports**

The Incident Reports screen separates incidents into a Pending Review section and a Completed section (toggled via a filter menu). Each incident card shows the category icon, child name, severity badge, timestamp, description, and two status badges indicating whether the parent has been notified and whether the manager has reviewed the report. The `+` button opens the Create Incident Report form. A `···` filter menu allows filtering by category and severity.

<img src="resource/screen04.jpeg" width="300">

**Screen 5 — Alerts**

The Alerts screen displays system-generated alerts for the keyworker, including allergy warnings, medical reminders, overdue diary log reminders, and safeguarding notices. Alerts are sorted by priority (Critical → Urgent → High → Normal) and split between unacknowledged and acknowledged. Tapping an alert opens a detail sheet from which it can be acknowledged. The tab bar icon shows a live unread badge count.

<img src="resource/screen05.jpeg" width="300">

### Navigation
The app uses a `TabView` with five tabs as the root navigation container. Within each tab, a `NavigationStack` is used for push navigation (e.g. child detail, incident detail). Modal sheets are used for creation flows (Add Diary Entry, Create Incident Report) and detail inspection (Alert Detail). This matches standard iOS navigation conventions and allows the system back gesture to work naturally throughout.

### Data Persistence
The app uses **SwiftData** (Apple's modern replacement for Core Data, introduced in iOS 17) for on-device persistence. Four `@Model` classes are declared: `Child`, `DiaryEntry`, `IncidentReport`, and `AlertItem`. The `ModelContainer` is configured in the app entry point (`NurseryConnectKeyworkerApp.swift`) and injected into the SwiftUI environment. A `PersistenceService` wrapper handles save operations. A `DataService` singleton provides the data-access layer between ViewModels and SwiftData. A `SampleDataProvider` supplies rich pre-populated data for the demo build; in a production build this would be replaced with a backend API.

### Error Handling
All SwiftData `ModelContext.save()` calls are wrapped in `do/try/catch` inside `PersistenceService`. In the production path, the `DataService` methods that mutate `@Model` objects are guarded by `if !useSampleData` to prevent mutations on objects that do not yet have a live `ModelContext` in the test environment, eliminating SIGABRT crashes at deinit. Network-layer errors (future work) would be surfaced via SwiftUI `.alert` modifiers bound to ViewModel error state.

---

## 03. User Interface Design

### Visual Design
The app uses a **dark-mode-first** colour palette with a deep black (`Color(.systemBackground)`) background, giving the interface a professional, focused feel appropriate for a busy nursery environment where the keyworker may be using the device in variable lighting. Accent colours are used semantically: green for diary/meal actions, blue for nap/navigation, purple for mood entries, orange for incidents and warnings, and red for critical alerts. Each entry type has its own consistent icon and colour token defined in the model layer.

Typography follows iOS Dynamic Type, using `.largeTitle` for screen headings, `.headline` for card titles, `.subheadline` for secondary metadata, and `.caption` for timestamps and badges. This ensures legibility for users of all ages and accessibility settings.

The app includes a custom `AppLogoView` SwiftUI component (a circular gradient badge featuring the `figure.and.child.holdinghands` SF Symbol) used in the Home screen header and as the app icon.

### Usability
Each screen provides immediate feedback through live filtering (search results update on every keypress), relative timestamps ("2 hr. ago"), and colour-coded severity/priority badges so the keyworker can triage at a glance. Destructive or status-changing actions (acknowledging an alert, marking a parent as notified) require an explicit tap on the relevant button rather than a swipe-to-delete, preventing accidental changes. Empty state views with descriptive messages are shown whenever a filtered list returns no results.

### UI Components Used

```
NavigationStack, TabView, List, ScrollView, LazyVStack,
Form, Section, TextField, TextEditor, Picker, DatePicker,
Sheet (.sheet modifier), Alert (.alert modifier),
Button, Label, Image (SF Symbols), Circle, RoundedRectangle,
HStack, VStack, ZStack, Spacer, Divider,
SearchBar (.searchable modifier), ScrollView (horizontal, for filter chips),
Badge (.badge modifier on TabItem), ProgressView,
Custom: DiaryEntryCard, IncidentCard, ChildCard, AlertBadge,
        QuickActionButton, SectionHeader, AppLogoView, AppBrandHeader
```

All card components use a consistent rounded-rectangle background with a coloured left-accent border derived from the entry type or severity, creating visual hierarchy without overcrowding the screen.

---

## 04. Swift & SwiftUI Knowledge

### Code Quality
The project is structured using the **MVVM** pattern throughout:

- **Models** (`/Models`) — four `@Model` classes backed by SwiftData; each contains only data properties and simple computed convenience properties (e.g. `hasAllergies`, `isPending`, `displayAge`).
- **ViewModels** (`/ViewModels`) — five `@Observable` classes (one per feature screen plus `HomeViewModel` and `AlertsViewModel`), each owning its own filtered/sorted computed properties and async task methods.
- **Views** (`/Views`) — pure SwiftUI views that read from ViewModels via direct property access; no business logic.
- **Components** (`/Components`) — reusable SwiftUI sub-views extracted from screens (cards, badges, headers).
- **Services** (`/Services`) — `DataService` (data-access singleton) and `PersistenceService` (SwiftData save wrapper).
- **SampleData** (`/SampleData`) — `SampleDataProvider` singleton owning an in-memory `ModelContainer` to safely hold `@Model` objects during testing.

All types follow Swift naming conventions (UpperCamelCase for types, lowerCamelCase for properties/methods). `@MainActor` is applied globally via `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` in the build settings, ensuring all UI state mutations occur on the main thread.

### Code Examples — Best Practices

**Example 1 — `@Observable` ViewModel with filtered computed properties (ChildrenViewModel)**

```swift
@Observable
class ChildrenViewModel {
    var assignedChildren: [Child] = []
    var selectedChild: Child?
    var searchText: String = ""

    private let dataService = DataService.shared

    init() { loadChildren() }

    func loadChildren() {
        assignedChildren = dataService.getAssignedChildren()
    }

    var filteredChildren: [Child] {
        if searchText.isEmpty { return assignedChildren }
        return assignedChildren.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.room.localizedCaseInsensitiveContains(searchText)
        }
    }

    var childrenWithAllergies: [Child] {
        assignedChildren.filter { $0.hasAllergies }
    }
}
```

This follows MVVM cleanly: the View binds `searchText` and reads `filteredChildren`; the ViewModel holds all filtering logic. Using `@Observable` instead of `ObservableObject`/`@Published` eliminates boilerplate and gives the Swift runtime fine-grained change tracking.

**Example 2 — SwiftData `@Model` with computed convenience properties (Child)**

```swift
@Model
class Child {
    @Attribute(.unique) var id: UUID
    var name: String
    var age: Int
    var room: String
    var allergies: [String]
    var dietaryRestrictions: [String]
    var medicalNotes: String
    var keyworkerName: String
    var emergencyContact: String
    var emergencyPhone: String

    var displayAge: String {
        age == 1 ? "1 year" : "\(age) years"
    }

    var hasAllergies: Bool { !allergies.isEmpty }
    var hasDietaryRestrictions: Bool { !dietaryRestrictions.isEmpty }
    var hasMedicalNotes: Bool { !medicalNotes.isEmpty }
}
```

Keeping computed properties inside the model avoids duplicating logic across ViewModels and Views. `@Attribute(.unique)` on `id` guarantees no duplicate records in the SwiftData store.

### Advanced Concepts

- **`@Observable` macro** (iOS 17+): All five ViewModels use the new `@Observable` macro, which replaces the `ObservableObject` + `@Published` pattern with compiler-synthesised observation tracking. Only the specific properties read by a View will trigger a re-render, reducing unnecessary redraws.
- **SwiftData `@Model`**: Persistent models are declared with the `@Model` macro. A single `ModelContainer` is configured at app launch and injected via `.modelContainer()`. The `ModelContext` is accessed through `DataService`.
- **`async`/`await` with `Task`**: Refresh and creation methods in ViewModels are `async` functions called inside `Task { }` blocks from the View layer, keeping the main thread free during data operations.
- **`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`**: Applied at the project level so all classes and structs are implicitly isolated to the main actor, preventing data races on `@Observable` state without needing explicit `@MainActor` annotations on every method.
- **Custom SF Symbol compositions**: `AppLogoView` uses `ZStack` with `Circle`, `LinearGradient`, and a layered SF Symbol to construct a branded logo entirely in SwiftUI code — no image assets required.

---

## 05. Testing & Debugging

### Testing

The project includes **50+ unit tests** across five test files, all using the `XCTest` framework with `@testable import NurseryConnectKeyworker`.

**Unit Tests:**

All ViewModel test classes are annotated `@MainActor` so tests run synchronously on the main actor, matching the app's global actor isolation and avoiding Sendable conflicts with SwiftData `@Model` objects.

```swift
@MainActor
final class ChildrenViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DataService.shared.useSampleData = true  // bypass SwiftData container
    }

    func test_filteredChildren_filtersByRoom() {
        let vm = ChildrenViewModel()
        vm.searchText = "Toddlers"
        let results = vm.filteredChildren
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy {
            $0.room.localizedCaseInsensitiveContains("Toddlers")
        })
    }
}
```

| Test File | Tests | Coverage Area |
|---|---|---|
| `ChildrenViewModelTests.swift` | 13 | Load, search (name + room), selection, computed collections |
| `AlertsViewModelTests.swift` | 17 | Load, filtering (priority, type, search), acknowledge, clear, overdue |
| `DiaryViewModelTests.swift` | 13 | Load, type filter, search, combined filters, grouping, date sort |
| `IncidentViewModelTests.swift` | 16 | Load, pending/complete, category, severity, search, clear, status updates |
| `ModelTests.swift` | 18 | `Child`, `DiaryEntry`, `IncidentReport`, `AlertItem` model properties |

**UI Tests:** Manual testing was performed across all five screens on a physical iPhone running iOS 18 and in the Xcode Simulator (iPhone 16 Pro, iOS 18.4).

**Manual Testing:**

| Scenario | Result |
|---|---|
| Search "oliver" in My Children → only Oliver Taylor shown | ✅ Pass |
| Search "Toddlers" in My Children → room filter works | ✅ Pass |
| Add Diary Entry via quick-action button → entry appears in Diary | ✅ Pass |
| Diary type filter "Meal" → only meal entries shown | ✅ Pass |
| Incident filter by category "Injury" → only injuries shown | ✅ Pass |
| Acknowledge alert → unread badge count decreases | ✅ Pass |
| Home stats grid reflects correct counts | ✅ Pass |
| Dark mode rendering across all screens | ✅ Pass |

### Debugging

**Bug 1 — SIGABRT crash `malloc: pointer being freed was not allocated` in unit tests**

SwiftData `@Model` objects require a live `ModelContext` (which backs their storage) to be present when they are deallocated. In the original test setup, sample `@Model` objects were created as plain Swift objects without being inserted into any `ModelContext`, causing a memory corruption crash at deinit.

**Fix:** `SampleDataProvider` was refactored to own an in-memory `ModelContainer` initialised at singleton creation time. Every sample `@Model` object is immediately inserted into the associated `ModelContext` after construction, ensuring they always have a valid backing store for their entire lifetime.

**Bug 2 — Compile errors: `((Child) throws -> Bool) throws -> Child?` instead of `Child?`**

Test files were rewritten to use `async func` + `await MainActor.run { }`. Because SwiftData `@Model` objects are not `Sendable`, Swift could not transfer `Child?` values across the actor boundary. The type inference engine resolved `array.first` as the `first(where:)` method reference rather than the `first` property, producing a non-optional closure type and cascading type errors.

**Fix:** All ViewModel test classes reverted to `@MainActor final class` with plain synchronous test methods, eliminating all actor-boundary crossings entirely. This is consistent with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.

---

## 06. Regulatory Compliance Report

### Understanding of Regulations

#### UK GDPR
The NurseryConnect Keyworker app handles personal data about children (name, age, room, allergies, medical notes, emergency contacts) and parents (contact details). Under UK GDPR Article 6, the lawful basis for processing this data is **public task / legitimate interests** of the nursery operator. Under Article 9, health and allergy data constitutes **special category data**, requiring explicit consent and stricter access controls. The app currently restricts data access to the assigned keyworker only (`keyworkerName` field on `Child`), which supports the data minimisation principle (Article 5(1)(c)). A production system would require: consent records, a Data Protection Impact Assessment (DPIA), data retention policies, right-to-erasure workflows, and encryption at rest and in transit.

#### EYFS 2024
The Early Years Foundation Stage Statutory Framework (2024) requires practitioners to make regular observations of each child's development and maintain accurate, up-to-date records. The Daily Diary feature directly satisfies this requirement by providing a structured log for meal intake, sleep, mood, physical activity, and general observations, all time-stamped and linked to the individual child. The diary supports the three prime areas of development (Personal, Social & Emotional; Communication & Language; Physical) through its Mood/Wellbeing and Activity entry types.

#### Ofsted
Ofsted's inspection framework evaluates whether a setting maintains accurate, contemporaneous records of incidents and accidents. The Incident Report feature provides the required formal record with: the child's name, the date and time, a description of what happened, the location, the severity, and evidence of follow-up actions (parent notification, manager review). A production system would additionally require a signed paper copy and a log of witness statements.

#### Children Act 1989
The Children Act 1989 places a duty of care on all nursery staff to promote and safeguard the welfare of children. The Incident Report's Safeguarding category and the Alerts feature (which surfaces safeguarding-type alerts to the keyworker) directly support this duty by ensuring that concerns are flagged, recorded, and escalated to the manager without delay. The dual-status tracking (parent notified, manager reviewed) creates an auditable record of the response.

#### FSA Guidelines
Not directly applicable to the Keyworker role. The Meal diary entry type captures what a child ate and any related notes, which indirectly supports allergen management in line with FSA Natasha's Law — particularly important given that `Child.allergies` and allergy-type `AlertItem` records are prominently surfaced throughout the app.

### Compliance by Design

The app embeds several compliance-by-design decisions:

1. **Role-scoped data access**: `DataService.getAssignedChildren()` filters children by `keyworkerName`, so a keyworker only ever sees their own key children — a technical enforcement of the GDPR data minimisation principle.
2. **Special category data visibility**: Allergies and medical notes are displayed contextually (in child detail and on alerts) rather than permanently visible on every list view, reducing inadvertent exposure.
3. **Audit trail via timestamps**: Every `DiaryEntry` and `IncidentReport` is assigned a server-side-quality timestamp at creation, providing a tamper-evident chronological record that Ofsted inspectors can review.
4. **Mandatory fields on incident forms**: The incident creation form requires a child, category, severity, description, and location before submission, ensuring no incomplete records are persisted.

A full production system would additionally require: TLS encryption for all API calls, AES-256 encryption at rest (via iOS Data Protection class `NSFileProtectionComplete`), role-based access control enforced server-side, audit logging of all access and mutations, and a GDPR-compliant data retention and deletion workflow.

### Critical Analysis

**Tension 1 — Data minimisation vs. usability**: Displaying allergy and medical note badges prominently on child cards aids fast triage by the keyworker but increases the surface area of special category data on screen. A production system should require re-authentication (Face ID / Touch ID) before revealing health data, at the cost of some friction.

**Tension 2 — Local persistence vs. data availability and backup**: SwiftData stores all data on-device. This improves performance and works offline (important in settings with poor Wi-Fi), but means data is lost if the device is lost or reset and does not sync across staff members. A production system would require a cloud-backed API with role-based authentication, conflating the need for offline-first architecture with real-time synchronisation.

**Tension 3 — Consent flows**: UK GDPR requires a documented consent record for processing a child's personal data. This MVP assumes consent is collected at enrolment and stored in the nursery's backend system; the app does not surface consent status. A full implementation should display a consent flag on each child record and prevent diary/incident creation for children whose consent has lapsed.

---

## 07. Documentation

### (a) Design Choices

| Decision | Rationale |
|---|---|
| **Dark mode first** | Nursery staff use devices in varying light conditions. Dark backgrounds reduce eye strain during long shifts and give the app a modern, professional appearance. |
| **Tab bar navigation** | Five distinct task areas (Home, Children, Diary, Incidents, Alerts) are of equal priority and accessed frequently throughout the day. A tab bar gives instant access to any screen in one tap, unlike a side drawer which requires two interactions. |
| **Card-based list items** | Cards with colour-coded left borders communicate entry type and priority at a glance without requiring the user to read the full content. This is critical for a keyworker managing multiple children simultaneously. |
| **`@Observable` + `@Model`** | These iOS 17 APIs eliminate boilerplate, provide automatic UI updates, and are the Apple-recommended pattern for new SwiftUI projects. Using them demonstrates current platform knowledge. |
| **Separate service layer** | `DataService` and `PersistenceService` decouple ViewModels from SwiftData internals, making ViewModels independently testable with a `useSampleData` flag. |

### (b) Implementation Decisions

- **SwiftData** was chosen over Core Data because it uses the `@Model` macro for declaration (dramatically less boilerplate), integrates natively with Swift Concurrency, and is the Apple-recommended persistence framework from iOS 17 onwards.
- **No third-party libraries**: The app uses only Apple frameworks (SwiftUI, SwiftData, XCTest). This eliminates dependency management complexity and ensures the project compiles cleanly from a fresh clone.
- **Sample data in a dedicated provider**: Rather than embedding sample data in views or ViewModels, `SampleDataProvider` is a singleton that owns its own in-memory `ModelContainer`. This makes it safe to use in both the app (preview/demo) and unit tests without SIGABRT crashes from ownerless `@Model` objects.
- **`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`** was set at the project level (rather than annotating each class individually) to enforce main-actor isolation globally, consistent with Apple's recommended approach for SwiftUI apps.
- **MVP simplifications**: Authentication is mocked (the keyworker name "Sarah Jones" is hardcoded in `DataService`). Push notifications, cloud sync, PDF export of incident reports, and parent-facing messaging are out of scope for this MVP.

### (c) Challenges

**Challenge 1 — SwiftData `@Model` objects and test isolation**

SwiftData `@Model` objects internally allocate a backing buffer tied to a `ModelContext`. Creating them outside any `ModelContext` (as plain Swift objects) causes a `malloc: pointer being freed was not allocated` SIGABRT on dealloc. This was not obvious from the documentation. The solution was to give `SampleDataProvider` its own in-memory `ModelContainer`/`ModelContext` and insert every sample object into it immediately after creation.

**Challenge 2 — `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and async tests**

Setting global `MainActor` isolation means that attempting to write async tests using `await MainActor.run { }` causes SwiftData `@Model` objects to be inferred as crossing an actor boundary even though they are already on the main actor. Swift's type system resolves `array.first` to the `first(where:)` method reference (a closure) instead of the `first` property, generating confusing type errors. The solution was to use synchronous `@MainActor final class` test classes throughout, which is both simpler and more consistent.

**Challenge 3 — Incident form completeness and picker coverage**

The initial incident form did not include `.allergic` reaction or `.other` categories, nor `.serious` severity — meaning incidents in those categories could not be created from the UI even though the model supported them. These gaps were identified through manual testing and fixed by auditing the form pickers against the full enum cases.

---

## 08. Reflection

### What went well?
The MVVM architecture with `@Observable` proved extremely clean — ViewModels are compact, testable, and free of UIKit references. The SwiftData model layer required careful setup but once the `SampleDataProvider` pattern was established, both the app and the test suite became stable. The unit test suite of 50+ tests gave strong confidence that filtering, search, and computed collection logic worked correctly across all edge cases. The dark-mode-first UI came together quickly because SwiftUI's `Color(.systemBackground)` and semantic colours automatically adapt, leaving only accent colours to define.

### What would you do differently?
I would define the `SampleDataProvider` in-memory container pattern at the very start of the project, before writing any unit tests. The three rounds of debugging SIGABRT crashes consumed significant time that could have been avoided with upfront planning. I would also write the test files in the correct `@MainActor final class` synchronous pattern from the beginning rather than experimenting with `async/await` patterns that are incompatible with non-Sendable `@Model` types. On the design side, I would produce low-fidelity wireframes for all five screens before starting implementation to avoid mid-sprint UI refactoring.

### AI Tool Usage
GitHub Copilot (powered by Claude Sonnet 4.6) was used extensively throughout this assignment via the VS Code Copilot Chat agent. Key uses included:

- Scaffolding the initial MVVM project structure and file organisation
- Generating SwiftData `@Model` class definitions and sample data
- Diagnosing and fixing the SIGABRT crash (3 iterative rounds of debugging)
- Writing and correcting the unit test suite, including identifying the `@MainActor` vs async/await incompatibility
- Implementing UI components (card views, filter chips, quick-action buttons)
- Writing this README documentation

All AI-assisted code was reviewed, understood, and adapted before being committed. Where the AI-generated approach was incorrect (notably the async test pattern), the underlying reason was investigated and a correct alternative was implemented.

---

*SE4020 — Mobile Application Design & Development | Semester 1, 2026 | SLIIT*






