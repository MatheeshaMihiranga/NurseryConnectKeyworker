//
//  SampleDataProvider.swift
//  NurseryConnectKeyworker
//
//  Provides comprehensive sample data for testing and demonstration.
//  Includes 4 assigned children, diverse diary entries, incidents, and alerts.
//

import Foundation
import SwiftData

class SampleDataProvider {
    static let shared = SampleDataProvider()

    // MARK: - In-Memory ModelContainer
    //
    // SwiftData @Model objects MUST live inside a ModelContext.
    // Without one, Swift ARC and SwiftData's internal allocator use
    // different memory regions. When ARC calls free() during deinit,
    // the pointer was allocated by SwiftData's allocator, not malloc,
    // causing: "malloc: pointer being freed was not allocated" SIGABRT.
    //
    // Every @Model object is inserted into this in-memory context
    // immediately after creation. The context then owns the objects
    // and their lifecycle is safe.
    //
    private let _modelContainer: ModelContainer
    private let _modelContext: ModelContext

    private init() {
        let schema = Schema([
            Child.self,
            DiaryEntry.self,
            IncidentReport.self,
            AlertItem.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        _modelContainer = try! ModelContainer(for: schema, configurations: [config])
        _modelContext = ModelContext(_modelContainer)
    }
    
    // MARK: - Current Keyworker
    
    let currentKeyworkerName = "Sarah Jones"
    
    // MARK: - Sample Children

    lazy var sampleChildren: [Child] = {
        let children: [Child] = [
            Child(
                name: "Oliver Taylor",
                age: 3,
                room: "Toddlers",
                allergies: ["Peanuts", "Tree nuts"],
                dietaryRestrictions: [],
                medicalNotes: "",
                photoName: "person.circle.fill",
                keyworkerName: currentKeyworkerName,
                emergencyContact: "James Taylor",
                emergencyPhone: "07700 900123"
            ),
            Child(
                name: "Emma Wilson",
                age: 2,
                room: "Toddlers",
                allergies: [],
                dietaryRestrictions: ["Dairy free"],
                medicalNotes: "",
                photoName: "person.circle.fill",
                keyworkerName: currentKeyworkerName,
                emergencyContact: "Sophie Wilson",
                emergencyPhone: "07700 900456"
            ),
            Child(
                name: "Noah Brown",
                age: 3,
                room: "Toddlers",
                allergies: [],
                dietaryRestrictions: [],
                medicalNotes: "Asthma - blue inhaler in office, use before outdoor play if wheezy",
                photoName: "person.circle.fill",
                keyworkerName: currentKeyworkerName,
                emergencyContact: "Rachel Brown",
                emergencyPhone: "07700 900789"
            ),
            Child(
                name: "Ava Davis",
                age: 2,
                room: "Toddlers",
                allergies: [],
                dietaryRestrictions: [],
                medicalNotes: "",
                photoName: "person.circle.fill",
                keyworkerName: currentKeyworkerName,
                emergencyContact: "Michael Davis",
                emergencyPhone: "07700 900321"
            )
        ]
        // Insert into the in-memory context so ARC + SwiftData lifecycle is safe
        children.forEach { _modelContext.insert($0) }
        return children
    }()
    
    // MARK: - Sample Diary Entries
    
    func sampleDiaryEntries(for children: [Child]) -> [DiaryEntry] {
        guard children.count >= 4 else { return [] }
        
        let now = Date()
        let calendar = Calendar.current
        
        return [
            // Today's entries
            DiaryEntry(
                childId: children[0].id,
                childName: children[0].name,
                entryType: .meal,
                timestamp: calendar.date(byAdding: .hour, value: -2, to: now)!,
                title: "Lunch",
                description: "Fish fingers, mashed potato, peas, and carrot sticks. Drank full cup of water.",
                notes: "Oliver ate very well today!",
                staffName: currentKeyworkerName,
                portionSize: "All"
            ),
            DiaryEntry(
                childId: children[1].id,
                childName: children[1].name,
                entryType: .nap,
                timestamp: calendar.date(byAdding: .hour, value: -3, to: now)!,
                title: "Afternoon nap",
                description: "Emma settled quickly and slept peacefully.",
                notes: "",
                staffName: currentKeyworkerName,
                duration: 75
            ),
            DiaryEntry(
                childId: children[2].id,
                childName: children[2].name,
                entryType: .activity,
                timestamp: calendar.date(byAdding: .hour, value: -1, to: now)!,
                title: "Outdoor play",
                description: "Noah built sandcastles and played on the climbing frame with friends.",
                notes: "Used inhaler before play as precaution - no wheezing.",
                staffName: currentKeyworkerName
            ),
            DiaryEntry(
                childId: children[3].id,
                childName: children[3].name,
                entryType: .mood,
                timestamp: calendar.date(byAdding: .minute, value: -30, to: now)!,
                title: "Happy and engaged",
                description: "Ava has been cheerful all morning, playing well with others.",
                notes: "",
                staffName: currentKeyworkerName,
                moodRating: 5
            ),
            
            // Yesterday's entries
            DiaryEntry(
                childId: children[0].id,
                childName: children[0].name,
                entryType: .nappy,
                timestamp: calendar.date(byAdding: .day, value: -1, to: now)!,
                title: "Nappy change",
                description: "Clean nappy change at 10:30am. No concerns.",
                notes: "",
                staffName: "Lucy Smith"
            ),
            DiaryEntry(
                childId: children[1].id,
                childName: children[1].name,
                entryType: .meal,
                timestamp: calendar.date(byAdding: .day, value: -1, to: now)!,
                title: "Snack time",
                description: "Apple slices and rice cakes (dairy-free compliant).",
                notes: "",
                staffName: currentKeyworkerName,
                portionSize: "Most"
            ),
            DiaryEntry(
                childId: children[2].id,
                childName: children[2].name,
                entryType: .mood,
                timestamp: calendar.date(byAdding: .day, value: -1, to: now)!,
                title: "Slightly upset",
                description: "Noah was upset when mum left this morning but settled quickly after cuddle.",
                notes: "",
                staffName: currentKeyworkerName,
                moodRating: 2
            ),
            DiaryEntry(
                childId: children[3].id,
                childName: children[3].name,
                entryType: .activity,
                timestamp: calendar.date(byAdding: .day, value: -1, to: now)!,
                title: "Arts and crafts",
                description: "Ava painted a rainbow picture and made a collage with tissue paper.",
                notes: "Very focused for 20 minutes!",
                staffName: "Tom Baker"
            ),
            
            // 2 days ago
            DiaryEntry(
                childId: children[0].id,
                childName: children[0].name,
                entryType: .activity,
                timestamp: calendar.date(byAdding: .day, value: -2, to: now)!,
                title: "Story time",
                description: "Oliver listened to 'The Gruffalo' and joined in with the repeated phrases.",
                notes: "",
                staffName: currentKeyworkerName
            ),
            DiaryEntry(
                childId: children[1].id,
                childName: children[1].name,
                entryType: .nap,
                timestamp: calendar.date(byAdding: .day, value: -2, to: now)!,
                title: "Morning nap",
                description: "Emma took a short morning nap.",
                notes: "",
                staffName: currentKeyworkerName,
                duration: 45
            ),
            
            // 3 days ago
            DiaryEntry(
                childId: children[2].id,
                childName: children[2].name,
                entryType: .meal,
                timestamp: calendar.date(byAdding: .day, value: -3, to: now)!,
                title: "Breakfast",
                description: "Porridge with banana and raisins. Drank milk.",
                notes: "",
                staffName: "Lucy Smith",
                portionSize: "All"
            ),
            DiaryEntry(
                childId: children[3].id,
                childName: children[3].name,
                entryType: .mood,
                timestamp: calendar.date(byAdding: .day, value: -3, to: now)!,
                title: "Very happy",
                description: "Ava was delighted to see her friend Mia arrive.",
                notes: "",
                staffName: currentKeyworkerName,
                moodRating: 5
            )
        ]
    }
    
    // MARK: - Sample Incidents
    
    func sampleIncidents(for children: [Child]) -> [IncidentReport] {
        guard children.count >= 3 else { return [] }
        
        let now = Date()
        let calendar = Calendar.current
        
        return [
            // Minor injury - complete
            IncidentReport(
                childId: children[0].id,
                childName: children[0].name,
                category: .injury,
                severity: .minor,
                timestamp: calendar.date(byAdding: .day, value: -3, to: now)!,
                location: "Main playground - climbing frame",
                description: "Oliver slipped on the climbing frame and grazed his left knee. Small graze, no bleeding.",
                immediateActionTaken: "Cleaned graze with water, applied plaster. Oliver comforted and returned to play after 5 minutes.",
                witnessNames: "Sarah Jones, Tom Baker",
                parentNotified: true,
                parentNotificationTime: calendar.date(byAdding: .day, value: -3, to: now),
                managerReviewed: true,
                managerReviewTime: calendar.date(byAdding: .day, value: -3, to: now),
                reportedByStaff: currentKeyworkerName
            ),
            
            // Behavior incident - parent notified, pending manager review
            IncidentReport(
                childId: children[1].id,
                childName: children[1].name,
                category: .behavior,
                severity: .moderate,
                timestamp: calendar.date(byAdding: .day, value: -1, to: now)!,
                location: "Toddler room - book corner",
                description: "Emma bit another child (Mia) on the arm during a disagreement over a toy. Small red mark visible, no broken skin.",
                immediateActionTaken: "Separated children immediately. Comforted Mia and applied cold compress. Talked to Emma about using words, not biting. Both children calmed and re-engaged separately.",
                witnessNames: "Sarah Jones, Lucy Smith",
                parentNotified: true,
                parentNotificationTime: calendar.date(byAdding: .day, value: -1, to: now),
                managerReviewed: false,
                reportedByStaff: currentKeyworkerName
            ),
            
            // Minor injury - pending all reviews
            IncidentReport(
                childId: children[2].id,
                childName: children[2].name,
                category: .injury,
                severity: .minor,
                timestamp: calendar.date(byAdding: .hour, value: -2, to: now)!,
                location: "Toddler room - construction area",
                description: "Noah bumped his head on the edge of the low shelf while reaching for blocks. Small bump, no cut, child cried briefly.",
                immediateActionTaken: "Applied ice pack wrapped in cloth for 5 minutes. Observed for signs of concussion (none noted). Noah returned to play happily.",
                witnessNames: "Sarah Jones",
                parentNotified: false,
                managerReviewed: false,
                reportedByStaff: currentKeyworkerName
            )
        ]
    }
    
    // MARK: - Sample Alerts
    
    func sampleAlerts(for children: [Child]) -> [AlertItem] {
        guard children.count >= 4 else { return [] }
        
        let now = Date()
        let calendar = Calendar.current
        
        return [
            // Allergy alerts
            AlertItem(
                childId: children[0].id,
                childName: children[0].name,
                alertType: .allergy,
                priority: .urgent,
                title: "Severe Peanut Allergy",
                message: "Oliver has a severe peanut and tree nut allergy. EpiPen in office. Check all foods before offering.",
                isAcknowledged: false,
                createdAt: calendar.date(byAdding: .day, value: -7, to: now)!
            ),
            
            // Dietary restriction alert
            AlertItem(
                childId: children[1].id,
                childName: children[1].name,
                alertType: .dietary,
                priority: .high,
                title: "Dairy Free Diet",
                message: "Emma requires dairy-free alternatives. Use oat milk, dairy-free spread. Check all ingredients.",
                isAcknowledged: true,
                createdAt: calendar.date(byAdding: .day, value: -5, to: now)!,
                acknowledgedAt: calendar.date(byAdding: .day, value: -5, to: now)!
            ),
            
            // Medical note alert
            AlertItem(
                childId: children[2].id,
                childName: children[2].name,
                alertType: .medical,
                priority: .high,
                title: "Asthma Medication",
                message: "Noah has asthma. Blue inhaler in office. Use before outdoor play if showing signs of wheeze or on high pollen days.",
                isAcknowledged: false,
                createdAt: calendar.date(byAdding: .day, value: -3, to: now)!
            ),
            
            // Overdue diary log
            AlertItem(
                childId: children[3].id,
                childName: children[3].name,
                alertType: .overdueDiary,
                priority: .medium,
                title: "No Meal Log Today",
                message: "Ava hasn't had a meal log recorded yet today. Please log lunch/snacks.",
                isAcknowledged: false,
                createdAt: calendar.date(byAdding: .hour, value: -1, to: now)!
            ),
            
            // Pending incident
            AlertItem(
                childId: children[2].id,
                childName: children[2].name,
                alertType: .pendingIncident,
                priority: .high,
                title: "Incident Requires Action",
                message: "Noah's head bump incident needs parent notification and manager review.",
                isAcknowledged: false,
                createdAt: calendar.date(byAdding: .hour, value: -2, to: now)!
            ),
            
            // General reminder
            AlertItem(
                childName: "All Children",
                alertType: .reminder,
                priority: .low,
                title: "Outdoor Play Scheduled",
                message: "Weather is good today - aim for 30 minutes outdoor play this afternoon.",
                isAcknowledged: true,
                createdAt: calendar.date(byAdding: .hour, value: -4, to: now)!,
                acknowledgedAt: calendar.date(byAdding: .hour, value: -3, to: now)!
            )
        ]
    }
    
    // MARK: - Object Caches
    //
    // Each cache is a lazy closure that:
    //   1. Creates the @Model objects
    //   2. Inserts them into _modelContext immediately
    //   3. Caches them so the same instances are returned every call
    //
    // Inserting into a ModelContext before any reads/writes prevents the
    // "malloc: pointer being freed was not allocated" SIGABRT that occurs
    // when SwiftData's internal allocator tries to deinit objects that
    // were never registered with a persistent store.
    //
    private lazy var _diaryEntriesCache: [DiaryEntry] = {
        let entries = sampleDiaryEntries(for: sampleChildren)
        entries.forEach { _modelContext.insert($0) }
        return entries
    }()

    private lazy var _incidentsCache: [IncidentReport] = {
        let incidents = sampleIncidents(for: sampleChildren)
        incidents.forEach { _modelContext.insert($0) }
        return incidents
    }()

    private lazy var _alertsCache: [AlertItem] = {
        let alerts = sampleAlerts(for: sampleChildren)
        alerts.forEach { _modelContext.insert($0) }
        return alerts
    }()

    // MARK: - Helper Methods

    var sampleDiaryEntries: [DiaryEntry] {
        return _diaryEntriesCache
    }

    var sampleIncidentReports: [IncidentReport] {
        return _incidentsCache
    }

    var sampleAlerts: [AlertItem] {
        return _alertsCache
    }

    func getChildren() -> [Child] {
        return sampleChildren
    }

    func getAssignedChildren() -> [Child] {
        return sampleChildren
    }

    func getDiaryEntries() -> [DiaryEntry] {
        return _diaryEntriesCache
    }

    func getDiaryEntries(for childId: UUID?) -> [DiaryEntry] {
        guard let childId = childId else { return _diaryEntriesCache }
        return _diaryEntriesCache.filter { $0.childId == childId }
    }

    func getIncidents() -> [IncidentReport] {
        return _incidentsCache
    }

    func getIncidentReports(for childId: UUID?) -> [IncidentReport] {
        guard let childId = childId else { return _incidentsCache }
        return _incidentsCache.filter { $0.childId == childId }
    }

    func getAlerts() -> [AlertItem] {
        return _alertsCache
    }

    func getUnacknowledgedAlerts() -> [AlertItem] {
        return _alertsCache.filter { !$0.isAcknowledged }
    }

    func getUnacknowledgedAlertCount() -> Int {
        return _alertsCache.filter { !$0.isAcknowledged }.count
    }

    func getPendingIncidentCount() -> Int {
        return _incidentsCache.filter { $0.isPending }.count
    }

    func getTodaysDiaryEntries() -> [DiaryEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return _diaryEntriesCache.filter {
            calendar.isDate($0.timestamp, inSameDayAs: today)
        }
    }

    func getHighPriorityAlerts() -> [AlertItem] {
        return _alertsCache.filter {
            ($0.priority == .high || $0.priority == .urgent) && !$0.isAcknowledged
        }
    }
}
