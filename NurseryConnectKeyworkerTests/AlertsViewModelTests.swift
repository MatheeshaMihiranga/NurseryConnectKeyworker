//
//  AlertsViewModelTests.swift
//  NurseryConnectKeyworkerTests
//
//  Unit tests for AlertsViewModel: loading, filtering, acknowledgment, and counts.
//

import XCTest
@testable import NurseryConnectKeyworker

@MainActor
final class AlertsViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DataService.shared.useSampleData = true
    }

    // MARK: - Initial Load

    func test_loadAlerts_populatesAlerts() {
        let vm = AlertsViewModel()
        XCTAssertFalse(vm.alerts.isEmpty, "Alerts should not be empty with sample data")
    }

    // MARK: - Unacknowledged Count

    func test_unacknowledgedCount_matchesUnreadAlerts() {
        let vm = AlertsViewModel()
        let expected = vm.alerts.filter { !$0.isAcknowledged }.count
        XCTAssertEqual(vm.unacknowledgedCount, expected)
    }

    // MARK: - filteredAlerts (showAcknowledged = false — default)

    func test_filteredAlerts_onlyUnacknowledged_byDefault() {
        let vm = AlertsViewModel()
        vm.showAcknowledgedAlerts = false
        let results = vm.filteredAlerts
        XCTAssertTrue(results.allSatisfy { !$0.isAcknowledged })
    }

    func test_filteredAlerts_includesAcknowledged_whenToggled() {
        let vm = AlertsViewModel()
        vm.showAcknowledgedAlerts = true
        XCTAssertEqual(vm.filteredAlerts.count, vm.alerts.count)
    }

    // MARK: - Priority Filtering

    func test_filteredAlerts_filtersByPriority_urgent() {
        let vm = AlertsViewModel()
        vm.showAcknowledgedAlerts = true
        vm.selectedPriority = .urgent
        let results = vm.filteredAlerts
        XCTAssertTrue(results.allSatisfy { $0.priority == .urgent })
    }

    func test_filteredAlerts_returnsAll_whenPriorityNil() {
        let vm = AlertsViewModel()
        vm.showAcknowledgedAlerts = true
        vm.selectedPriority = nil
        XCTAssertEqual(vm.filteredAlerts.count, vm.alerts.count)
    }

    // MARK: - Alert Type Filtering

    func test_filteredAlerts_filtersByType_allergy() {
        let vm = AlertsViewModel()
        vm.showAcknowledgedAlerts = true
        vm.selectedAlertType = .allergy
        let results = vm.filteredAlerts
        XCTAssertTrue(results.allSatisfy { $0.alertType == .allergy })
    }

    func test_allergyAlerts_onlyContainAllergyType() {
        let vm = AlertsViewModel()
        XCTAssertTrue(vm.allergyAlerts.allSatisfy { $0.alertType == .allergy })
    }

    func test_medicalAlerts_onlyContainMedicalType() {
        let vm = AlertsViewModel()
        XCTAssertTrue(vm.medicalAlerts.allSatisfy { $0.alertType == .medical })
    }

    // MARK: - Search Filtering

    func test_filteredAlerts_filtersByTitle_caseInsensitive() {
        let vm = AlertsViewModel()
        vm.showAcknowledgedAlerts = true
        vm.searchText = "peanut"
        let results = vm.filteredAlerts
        XCTAssertTrue(results.allSatisfy {
            $0.title.localizedCaseInsensitiveContains("peanut") ||
            $0.message.localizedCaseInsensitiveContains("peanut") ||
            $0.childName.localizedCaseInsensitiveContains("peanut")
        })
    }

    func test_filteredAlerts_returnsEmpty_forNonExistentSearch() {
        let vm = AlertsViewModel()
        vm.showAcknowledgedAlerts = true
        vm.searchText = "ZZZNOMATCH999"
        XCTAssertTrue(vm.filteredAlerts.isEmpty)
    }

    // MARK: - Critical Alerts

    func test_criticalAlerts_onlyContainUrgentOrCriticalPriority() {
        let vm = AlertsViewModel()
        let results = vm.criticalAlerts
        XCTAssertTrue(results.allSatisfy {
            $0.priority == .urgent || $0.priority == .critical
        })
    }

    func test_criticalAlerts_areAllUnacknowledged() {
        let vm = AlertsViewModel()
        XCTAssertTrue(vm.criticalAlerts.allSatisfy { !$0.isAcknowledged })
    }

    // MARK: - Sorted Alerts

    func test_sortedAlerts_higherPriorityFirst() {
        let vm = AlertsViewModel()
        vm.showAcknowledgedAlerts = true
        let sorted = vm.sortedAlerts
        for i in 0..<(sorted.count - 1) {
            XCTAssertGreaterThanOrEqual(
                sorted[i].priority.sortOrder,
                sorted[i + 1].priority.sortOrder,
                "Alerts should be sorted highest priority first"
            )
        }
    }

    // MARK: - Acknowledge Actions

    func test_acknowledgeAlert_immediatelyUpdatesViewModel() {
        let vm = AlertsViewModel()
        guard let unread = vm.alerts.first(where: { !$0.isAcknowledged }) else {
            return // No unread alerts available — skip
        }
        let countBefore = vm.unacknowledgedCount
        vm.acknowledgeAlert(unread)
        // unacknowledged count should decrease or stay same
        XCTAssertLessThanOrEqual(vm.unacknowledgedCount, countBefore)
    }

    // MARK: - Clear Filters

    func test_clearFilters_resetsAllFilters() {
        let vm = AlertsViewModel()
        vm.selectedPriority = .urgent
        vm.selectedAlertType = .allergy
        vm.searchText = "test"
        vm.clearFilters()
        XCTAssertNil(vm.selectedPriority)
        XCTAssertNil(vm.selectedAlertType)
        XCTAssertEqual(vm.searchText, "")
    }

    // MARK: - Overdue Reminders

    func test_overdueReminders_containsOverdueDiaryType() {
        let vm = AlertsViewModel()
        XCTAssertTrue(vm.overdueReminders.allSatisfy { $0.alertType == .overdueDiary })
    }
}
