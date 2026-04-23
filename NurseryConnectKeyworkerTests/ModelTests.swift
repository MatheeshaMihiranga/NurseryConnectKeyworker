//
//  ModelTests.swift
//  NurseryConnectKeyworkerTests
//
//  Unit tests for all SwiftData model types.
//  Each test class owns an in-memory ModelContainer so @Model objects
//  always have a valid backing store â€” preventing SIGABRT at deinit.
//

import XCTest
import SwiftData
@testable import NurseryConnectKeyworker

// MARK: - Shared schema helper

private func makeTestContainer() -> ModelContainer {
    let schema = Schema([Child.self, DiaryEntry.self, IncidentReport.self, AlertItem.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try! ModelContainer(for: schema, configurations: [config])
}

// MARK: - Child Model Tests

@MainActor
final class ChildModelTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        container = makeTestContainer()
        context = ModelContext(container)
    }

    override func tearDown() {
        context = nil
        container = nil
        super.tearDown()
    }

    // MARK: - displayAge

    func test_displayAge_singularYear() {
        let child = makeChild(age: 1)
        XCTAssertEqual(child.displayAge, "1 year")
    }

    func test_displayAge_pluralYears() {
        let child = makeChild(age: 3)
        XCTAssertEqual(child.displayAge, "3 years")
    }

    func test_displayAge_zero() {
        let child = makeChild(age: 0)
        XCTAssertEqual(child.displayAge, "0 years")
    }

    // MARK: - hasAllergies

    func test_hasAllergies_returnsTrue_whenAllergyPresent() {
        let child = makeChild(allergies: ["Peanuts"])
        XCTAssertTrue(child.hasAllergies)
    }

    func test_hasAllergies_returnsFalse_whenEmpty() {
        let child = makeChild(allergies: [])
        XCTAssertFalse(child.hasAllergies)
    }

    func test_hasAllergies_returnsTrue_forMultipleAllergies() {
        let child = makeChild(allergies: ["Peanuts", "Dairy", "Eggs"])
        XCTAssertTrue(child.hasAllergies)
        XCTAssertEqual(child.allergies.count, 3)
    }

    // MARK: - hasDietaryRestrictions

    func test_hasDietaryRestrictions_returnsTrue() {
        let child = makeChild(dietaryRestrictions: ["Vegetarian"])
        XCTAssertTrue(child.hasDietaryRestrictions)
    }

    func test_hasDietaryRestrictions_returnsFalse_whenEmpty() {
        let child = makeChild()
        XCTAssertFalse(child.hasDietaryRestrictions)
    }

    // MARK: - hasMedicalNotes

    func test_hasMedicalNotes_returnsTrue_whenNotEmpty() {
        let child = makeChild(medicalNotes: "Asthma - inhaler in office")
        XCTAssertTrue(child.hasMedicalNotes)
    }

    func test_hasMedicalNotes_returnsFalse_whenEmpty() {
        let child = makeChild(medicalNotes: "")
        XCTAssertFalse(child.hasMedicalNotes)
    }

    // MARK: - Helpers

    private func makeChild(
        name: String = "Test Child",
        age: Int = 2,
        room: String = "Toddlers",
        allergies: [String] = [],
        dietaryRestrictions: [String] = [],
        medicalNotes: String = ""
    ) -> Child {
        let child = Child(
            name: name,
            age: age,
            room: room,
            allergies: allergies,
            dietaryRestrictions: dietaryRestrictions,
            medicalNotes: medicalNotes,
            keyworkerName: "Test Worker",
            emergencyContact: "Test Parent",
            emergencyPhone: "07700000000"
        )
        context.insert(child)
        return child
    }
}

// MARK: - DiaryEntry Model Tests

@MainActor
final class DiaryEntryModelTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        container = makeTestContainer()
        context = ModelContext(container)
    }

    override func tearDown() {
        context = nil
        container = nil
        super.tearDown()
    }

    // MARK: - entryType computed property

    func test_entryType_returnsCorrectType_forMeal() {
        let entry = makeEntry(typeRaw: "Meal")
        XCTAssertEqual(entry.entryType, .meal)
    }

    func test_entryType_returnsCorrectType_forNap() {
        let entry = makeEntry(typeRaw: "Nap")
        XCTAssertEqual(entry.entryType, .nap)
    }

    func test_entryType_fallsBackToActivity_forUnknownRaw() {
        let entry = makeEntry(typeRaw: "UNKNOWN_TYPE")
        XCTAssertEqual(entry.entryType, .activity)
    }

    // MARK: - durationText

    func test_durationText_nil_whenNoDuration() {
        let entry = makeEntry()
        XCTAssertNil(entry.durationText)
    }

    func test_durationText_shortFormat_underHour() {
        let entry = makeEntry(duration: 45)
        XCTAssertEqual(entry.durationText, "45 mins")
    }

    func test_durationText_hourFormat_exactHour() {
        let entry = makeEntry(duration: 60)
        XCTAssertEqual(entry.durationText, "1h")
    }

    func test_durationText_hourAndMinutes() {
        let entry = makeEntry(duration: 75)
        XCTAssertEqual(entry.durationText, "1h 15m")
    }

    // MARK: - moodEmoji

    func test_moodEmoji_nil_whenNoRating() {
        let entry = makeEntry()
        XCTAssertNil(entry.moodEmoji)
    }

    func test_moodEmoji_veryHappy_forRating5() {
        let entry = makeEntry(moodRating: 5)
        XCTAssertEqual(entry.moodEmoji, "ðŸ˜„")
    }

    func test_moodEmoji_verySad_forRating1() {
        let entry = makeEntry(moodRating: 1)
        XCTAssertEqual(entry.moodEmoji, "ðŸ˜¢")
    }

    func test_moodEmoji_neutral_forRating3() {
        let entry = makeEntry(moodRating: 3)
        XCTAssertEqual(entry.moodEmoji, "ðŸ˜")
    }

    // MARK: - Helpers

    private func makeEntry(
        typeRaw: String = "Activity",
        duration: Int? = nil,
        moodRating: Int? = nil
    ) -> DiaryEntry {
        let entry = DiaryEntry(
            childId: UUID(),
            childName: "Test Child",
            entryType: DiaryEntryType(rawValue: typeRaw) ?? .activity,
            timestamp: Date(),
            title: "Test Entry",
            description: "Test description",
            notes: "",
            staffName: "Test Worker",
            duration: duration,
            moodRating: moodRating
        )
        context.insert(entry)
        return entry
    }
}

// MARK: - IncidentReport Model Tests

@MainActor
final class IncidentReportModelTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        container = makeTestContainer()
        context = ModelContext(container)
    }

    override func tearDown() {
        context = nil
        container = nil
        super.tearDown()
    }

    // MARK: - isPending

    func test_isPending_true_whenBothPending() {
        let report = makeReport(parentNotified: false, managerReviewed: false)
        XCTAssertTrue(report.isPending)
    }

    func test_isPending_true_whenOnlyParentPending() {
        let report = makeReport(parentNotified: false, managerReviewed: true)
        XCTAssertTrue(report.isPending)
    }

    func test_isPending_true_whenOnlyManagerPending() {
        let report = makeReport(parentNotified: true, managerReviewed: false)
        XCTAssertTrue(report.isPending)
    }

    func test_isPending_false_whenBothComplete() {
        let report = makeReport(parentNotified: true, managerReviewed: true)
        XCTAssertFalse(report.isPending)
    }

    // MARK: - isComplete

    func test_isComplete_true_whenBothDone() {
        let report = makeReport(parentNotified: true, managerReviewed: true)
        XCTAssertTrue(report.isComplete)
    }

    func test_isComplete_false_whenPending() {
        let report = makeReport(parentNotified: false, managerReviewed: false)
        XCTAssertFalse(report.isComplete)
    }

    // MARK: - requiresUrgentAction

    func test_requiresUrgentAction_true_forMajorSeverity() {
        let report = makeReport(severity: .major)
        XCTAssertTrue(report.requiresUrgentAction)
    }

    func test_requiresUrgentAction_true_forSeriousSeverity() {
        let report = makeReport(severity: .serious)
        XCTAssertTrue(report.requiresUrgentAction)
    }

    func test_requiresUrgentAction_false_forMinorSeverity() {
        let report = makeReport(severity: .minor)
        XCTAssertFalse(report.requiresUrgentAction)
    }

    func test_requiresUrgentAction_false_forModerateSeverity() {
        let report = makeReport(severity: .moderate)
        XCTAssertFalse(report.requiresUrgentAction)
    }

    // MARK: - category computed property

    func test_category_returnsCorrect_forRawValue() {
        let report = makeReport(categoryRaw: "Injury")
        XCTAssertEqual(report.category, .injury)
    }

    func test_category_fallsBack_forUnknownRaw() {
        let report = makeReport(categoryRaw: "UNKNOWN")
        XCTAssertEqual(report.category, .other)
    }

    // MARK: - statusBadges

    func test_statusBadges_containsPendingLabels_whenBothPending() {
        let report = makeReport(parentNotified: false, managerReviewed: false)
        let badges = report.statusBadges
        XCTAssertTrue(badges.contains("Parent Pending"))
        XCTAssertTrue(badges.contains("Manager Pending"))
    }

    func test_statusBadges_containsSentLabels_whenBothComplete() {
        let report = makeReport(parentNotified: true, managerReviewed: true)
        let badges = report.statusBadges
        XCTAssertTrue(badges.contains("Parent Notified âœ“"))
        XCTAssertTrue(badges.contains("Manager Reviewed âœ“"))
    }

    // MARK: - Helpers

    private func makeReport(
        categoryRaw: String = "Injury",
        severity: IncidentSeverity = .minor,
        parentNotified: Bool = false,
        managerReviewed: Bool = false
    ) -> IncidentReport {
        let report = IncidentReport(
            childId: UUID(),
            childName: "Test Child",
            category: IncidentCategory(rawValue: categoryRaw) ?? .other,
            severity: severity,
            timestamp: Date(),
            location: "Test location",
            description: "Test incident",
            immediateActionTaken: "Test action",
            witnessNames: "",
            parentNotified: parentNotified,
            managerReviewed: managerReviewed,
            reportedByStaff: "Test Worker"
        )
        context.insert(report)
        return report
    }
}

// MARK: - AlertItem Model Tests

@MainActor
final class AlertItemModelTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        container = makeTestContainer()
        context = ModelContext(container)
    }

    override func tearDown() {
        context = nil
        container = nil
        super.tearDown()
    }

    func test_alertType_returnsCorrect_forAllergy() {
        let alert = makeAlert(alertType: .allergy, priority: .urgent, title: "Allergy Alert")
        XCTAssertEqual(alert.alertType, .allergy)
    }

    func test_priority_returnsCorrect_forUrgent() {
        let alert = makeAlert(alertType: .reminder, priority: .urgent, title: "Test")
        XCTAssertEqual(alert.priority, .urgent)
    }

    func test_sortOrder_criticalHigherThanLow() {
        XCTAssertGreaterThan(AlertPriority.critical.sortOrder, AlertPriority.low.sortOrder)
    }

    func test_sortOrder_urgentHigherThanMedium() {
        XCTAssertGreaterThan(AlertPriority.urgent.sortOrder, AlertPriority.medium.sortOrder)
    }

    func test_isAcknowledged_defaultsFalse() {
        let alert = makeAlert(alertType: .reminder, priority: .low, title: "Test")
        XCTAssertFalse(alert.isAcknowledged)
    }

    // MARK: - Helpers

    private func makeAlert(
        alertType: AlertType,
        priority: AlertPriority,
        title: String
    ) -> AlertItem {
        let alert = AlertItem(
            childName: "Test Child",
            alertType: alertType,
            priority: priority,
            title: title,
            message: "Test message"
        )
        context.insert(alert)
        return alert
    }
}
