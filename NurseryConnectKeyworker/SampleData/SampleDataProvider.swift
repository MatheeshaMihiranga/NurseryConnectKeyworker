//
//  SampleDataProvider.swift
//  NurseryConnectKeyworker
//
//  Provides sample data for testing and demonstration.
//  Owns an in-memory ModelContainer so every @Model object has a valid
//  backing store — preventing SIGABRT at deinit during unit tests.
//

import Foundation
import SwiftData

class SampleDataProvider {
    static let shared = SampleDataProvider()

    // In-memory container that backs ALL sample @Model objects.
    // Created once in init; every object is inserted immediately after construction.
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    private init() {
        let schema = Schema([Child.self, DiaryEntry.self, IncidentReport.self, AlertItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        // Force-unwrap is safe: hard-coded schema always succeeds
        modelContainer = try! ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }

    // MARK: - Current Keyworker

    let currentKeyworkerName = "Sarah Jones"

    // MARK: - Children (lazy — stable references, inserted into context once)

    lazy var sampleChildren: [Child] = {
        let children: [Child] = [
            Child(
                name: "Oliver Taylor", age: 3, room: "Toddlers",
                allergies: ["Peanuts", "Tree nuts"], dietaryRestrictions: [],
                medicalNotes: "", photoName: "person.circle.fill",
                keyworkerName: currentKeyworkerName,
                emergencyContact: "James Taylor", emergencyPhone: "07700 900123"
            ),
            Child(
                name: "Emma Wilson", age: 2, room: "Toddlers",
                allergies: [], dietaryRestrictions: ["Dairy free"],
                medicalNotes: "", photoName: "person.circle.fill",
                keyworkerName: currentKeyworkerName,
                emergencyContact: "Sophie Wilson", emergencyPhone: "07700 900456"
            ),
            Child(
                name: "Noah Brown", age: 3, room: "Toddlers",
                allergies: [], dietaryRestrictions: [],
                medicalNotes: "Asthma - blue inhaler in office, use before outdoor play if wheezy",
                photoName: "person.circle.fill",
                keyworkerName: currentKeyworkerName,
                emergencyContact: "Rachel Brown", emergencyPhone: "07700 900789"
            ),
            Child(
                name: "Ava Davis", age: 2, room: "Toddlers",
                allergies: [], dietaryRestrictions: [],
                medicalNotes: "", photoName: "person.circle.fill",
                keyworkerName: currentKeyworkerName,
                emergencyContact: "Michael Davis", emergencyPhone: "07700 900321"
            )
        ]
        children.forEach { modelContext.insert($0) }
        return children
    }()

    // MARK: - Diary Entries (cached — same instances on every call)

    private lazy var _diaryEntriesCache: [DiaryEntry] = {
        let c = sampleChildren
        guard c.count >= 4 else { return [] }
        let now = Date()
        let cal = Calendar.current
        let entries: [DiaryEntry] = [
            // Today
            DiaryEntry(
                childId: c[0].id, childName: c[0].name, entryType: .meal,
                timestamp: cal.date(byAdding: .hour, value: -2, to: now)!,
                title: "Lunch",
                description: "Fish fingers, mashed potato, peas, and carrot sticks. Drank full cup of water.",
                notes: "Oliver ate very well today!",
                staffName: currentKeyworkerName, portionSize: "All"
            ),
            DiaryEntry(
                childId: c[1].id, childName: c[1].name, entryType: .nap,
                timestamp: cal.date(byAdding: .hour, value: -3, to: now)!,
                title: "Afternoon nap",
                description: "Emma settled quickly and slept peacefully.",
                notes: "", staffName: currentKeyworkerName, duration: 75
            ),
            DiaryEntry(
                childId: c[2].id, childName: c[2].name, entryType: .activity,
                timestamp: cal.date(byAdding: .hour, value: -1, to: now)!,
                title: "Outdoor play",
                description: "Noah built sandcastles and played on the climbing frame with friends.",
                notes: "Used inhaler before play as precaution - no wheezing.",
                staffName: currentKeyworkerName
            ),
            DiaryEntry(
                childId: c[3].id, childName: c[3].name, entryType: .mood,
                timestamp: cal.date(byAdding: .minute, value: -30, to: now)!,
                title: "Happy and engaged",
                description: "Ava has been cheerful all morning, playing well with others.",
                notes: "", staffName: currentKeyworkerName, moodRating: 5
            ),
            // Yesterday
            DiaryEntry(
                childId: c[0].id, childName: c[0].name, entryType: .nappy,
                timestamp: cal.date(byAdding: .day, value: -1, to: now)!,
                title: "Nappy change",
                description: "Clean nappy change at 10:30am. No concerns.",
                notes: "", staffName: "Lucy Smith"
            ),
            DiaryEntry(
                childId: c[1].id, childName: c[1].name, entryType: .meal,
                timestamp: cal.date(byAdding: .day, value: -1, to: now)!,
                title: "Snack time",
                description: "Apple slices and rice cakes (dairy-free compliant).",
                notes: "", staffName: currentKeyworkerName, portionSize: "Most"
            ),
            DiaryEntry(
                childId: c[2].id, childName: c[2].name, entryType: .mood,
                timestamp: cal.date(byAdding: .day, value: -1, to: now)!,
                title: "Slightly upset",
                description: "Noah was upset when mum left this morning but settled quickly after cuddle.",
                notes: "", staffName: currentKeyworkerName, moodRating: 2
            ),
            DiaryEntry(
                childId: c[3].id, childName: c[3].name, entryType: .activity,
                timestamp: cal.date(byAdding: .day, value: -1, to: now)!,
                title: "Arts and crafts",
                description: "Ava painted a rainbow picture and made a collage with tissue paper.",
                notes: "Very focused for 20 minutes!", staffName: "Tom Baker"
            ),
            // 2 days ago
            DiaryEntry(
                childId: c[0].id, childName: c[0].name, entryType: .activity,
                timestamp: cal.date(byAdding: .day, value: -2, to: now)!,
                title: "Story time",
                description: "Oliver listened to 'The Gruffalo' and joined in with the repeated phrases.",
                notes: "", staffName: currentKeyworkerName
            ),
            DiaryEntry(
                childId: c[1].id, childName: c[1].name, entryType: .nap,
                timestamp: cal.date(byAdding: .day, value: -2, to: now)!,
                title: "Morning nap",
                description: "Emma took a short morning nap.",
                notes: "", staffName: currentKeyworkerName, duration: 45
            ),
            // 3 days ago
            DiaryEntry(
                childId: c[2].id, childName: c[2].name, entryType: .meal,
                timestamp: cal.date(byAdding: .day, value: -3, to: now)!,
                title: "Breakfast",
                description: "Porridge with banana and raisins. Drank milk.",
                notes: "", staffName: "Lucy Smith", portionSize: "All"
            ),
            DiaryEntry(
                childId: c[3].id, childName: c[3].name, entryType: .mood,
                timestamp: cal.date(byAdding: .day, value: -3, to: now)!,
                title: "Very happy",
                description: "Ava was delighted to see her friend Mia arrive.",
                notes: "", staffName: currentKeyworkerName, moodRating: 5
            )
        ]
        entries.forEach { modelContext.insert($0) }
        return entries
    }()

    // MARK: - Incidents (cached — same instances on every call)

    private lazy var _incidentsCache: [IncidentReport] = {
        let c = sampleChildren
        guard c.count >= 3 else { return [] }
        let now = Date()
        let cal = Calendar.current
        let reports: [IncidentReport] = [
            // Complete — both notified
            IncidentReport(
                childId: c[0].id, childName: c[0].name,
                category: .injury, severity: .minor,
                timestamp: cal.date(byAdding: .day, value: -3, to: now)!,
                location: "Main playground - climbing frame",
                description: "Oliver slipped on the climbing frame and grazed his left knee. Small graze, no bleeding.",
                immediateActionTaken: "Cleaned graze with water, applied plaster. Oliver comforted and returned to play after 5 minutes.",
                witnessNames: "Sarah Jones, Tom Baker",
                parentNotified: true,
                parentNotificationTime: cal.date(byAdding: .day, value: -3, to: now),
                managerReviewed: true,
                managerReviewTime: cal.date(byAdding: .day, value: -3, to: now),
                reportedByStaff: currentKeyworkerName
            ),
            // Parent notified, manager pending
            IncidentReport(
                childId: c[1].id, childName: c[1].name,
                category: .behavior, severity: .moderate,
                timestamp: cal.date(byAdding: .day, value: -1, to: now)!,
                location: "Toddler room - book corner",
                description: "Emma bit another child (Mia) on the arm during a disagreement over a toy. Small red mark visible, no broken skin.",
                immediateActionTaken: "Separated children immediately. Comforted Mia and applied cold compress. Talked to Emma about using words, not biting.",
                witnessNames: "Sarah Jones, Lucy Smith",
                parentNotified: true,
                parentNotificationTime: cal.date(byAdding: .day, value: -1, to: now),
                managerReviewed: false,
                reportedByStaff: currentKeyworkerName
            ),
            // Both pending
            IncidentReport(
                childId: c[2].id, childName: c[2].name,
                category: .injury, severity: .minor,
                timestamp: cal.date(byAdding: .hour, value: -2, to: now)!,
                location: "Toddler room - construction area",
                description: "Noah bumped his head on the edge of the low shelf while reaching for blocks. Small bump, no cut, child cried briefly.",
                immediateActionTaken: "Applied ice pack wrapped in cloth for 5 minutes. Observed for signs of concussion (none noted). Noah returned to play happily.",
                witnessNames: "Sarah Jones",
                parentNotified: false,
                managerReviewed: false,
                reportedByStaff: currentKeyworkerName
            )
        ]
        reports.forEach { modelContext.insert($0) }
        return reports
    }()

    // MARK: - Alerts (cached — same instances on every call)

    private lazy var _alertsCache: [AlertItem] = {
        let c = sampleChildren
        guard c.count >= 4 else { return [] }
        let now = Date()
        let cal = Calendar.current
        let alerts: [AlertItem] = [
            AlertItem(
                childId: c[0].id, childName: c[0].name,
                alertType: .allergy, priority: .urgent,
                title: "Severe Peanut Allergy",
                message: "Oliver has a severe peanut and tree nut allergy. EpiPen in office. Check all foods before offering.",
                isAcknowledged: false,
                createdAt: cal.date(byAdding: .day, value: -7, to: now)!
            ),
            AlertItem(
                childId: c[1].id, childName: c[1].name,
                alertType: .dietary, priority: .high,
                title: "Dairy Free Diet",
                message: "Emma requires dairy-free alternatives. Use oat milk, dairy-free spread. Check all ingredients.",
                isAcknowledged: true,
                createdAt: cal.date(byAdding: .day, value: -5, to: now)!,
                acknowledgedAt: cal.date(byAdding: .day, value: -5, to: now)!
            ),
            AlertItem(
                childId: c[2].id, childName: c[2].name,
                alertType: .medical, priority: .high,
                title: "Asthma Medication",
                message: "Noah has asthma. Blue inhaler in office. Use before outdoor play if showing signs of wheeze or on high pollen days.",
                isAcknowledged: false,
                createdAt: cal.date(byAdding: .day, value: -3, to: now)!
            ),
            AlertItem(
                childId: c[3].id, childName: c[3].name,
                alertType: .overdueDiary, priority: .medium,
                title: "No Meal Log Today",
                message: "Ava hasn't had a meal log recorded yet today. Please log lunch/snacks.",
                isAcknowledged: false,
                createdAt: cal.date(byAdding: .hour, value: -1, to: now)!
            ),
            AlertItem(
                childId: c[2].id, childName: c[2].name,
                alertType: .pendingIncident, priority: .high,
                title: "Incident Requires Action",
                message: "Noah's head bump incident needs parent notification and manager review.",
                isAcknowledged: false,
                createdAt: cal.date(byAdding: .hour, value: -2, to: now)!
            ),
            AlertItem(
                childName: "All Children",
                alertType: .reminder, priority: .low,
                title: "Outdoor Play Scheduled",
                message: "Weather is good today - aim for 30 minutes outdoor play this afternoon.",
                isAcknowledged: true,
                createdAt: cal.date(byAdding: .hour, value: -4, to: now)!,
                acknowledgedAt: cal.date(byAdding: .hour, value: -3, to: now)!
            )
        ]
        alerts.forEach { modelContext.insert($0) }
        return alerts
    }()

    // MARK: - Legacy function-based API (kept for backward compatibility)

    func sampleDiaryEntries(for children: [Child]) -> [DiaryEntry] {
        return _diaryEntriesCache
    }

    func sampleIncidents(for children: [Child]) -> [IncidentReport] {
        return _incidentsCache
    }

    func sampleAlerts(for children: [Child]) -> [AlertItem] {
        return _alertsCache
    }

    // MARK: - Computed shorthands (backed by caches)

    var sampleDiaryEntries: [DiaryEntry] { _diaryEntriesCache }
    var sampleIncidentReports: [IncidentReport] { _incidentsCache }

    // MARK: - Public API

    func getChildren() -> [Child] { sampleChildren }
    func getAssignedChildren() -> [Child] { sampleChildren }

    func getDiaryEntries() -> [DiaryEntry] { _diaryEntriesCache }
    func getDiaryEntries(for childId: UUID?) -> [DiaryEntry] {
        guard let childId = childId else { return _diaryEntriesCache }
        return _diaryEntriesCache.filter { $0.childId == childId }
    }

    func getIncidents() -> [IncidentReport] { _incidentsCache }
    func getIncidentReports(for childId: UUID?) -> [IncidentReport] {
        guard let childId = childId else { return _incidentsCache }
        return _incidentsCache.filter { $0.childId == childId }
    }

    func getAlerts() -> [AlertItem] { _alertsCache }
    func getUnacknowledgedAlerts() -> [AlertItem] {
        _alertsCache.filter { !$0.isAcknowledged }
    }

    func getUnacknowledgedAlertCount() -> Int {
        _alertsCache.filter { !$0.isAcknowledged }.count
    }

    func getPendingIncidentCount() -> Int {
        _incidentsCache.filter { $0.isPending }.count
    }

    func getTodaysDiaryEntries() -> [DiaryEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return _diaryEntriesCache.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
    }

    func getHighPriorityAlerts() -> [AlertItem] {
        _alertsCache.filter {
            ($0.priority == .high || $0.priority == .urgent) && !$0.isAcknowledged
        }
    }
}
