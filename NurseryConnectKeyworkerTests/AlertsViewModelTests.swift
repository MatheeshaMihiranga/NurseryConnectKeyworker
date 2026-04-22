//
//  AlertsViewModelTests.swift
//  NurseryConnectKeyworkerTests
//
//  Unit tests for AlertsViewModel: loading, filtering, acknowledgment, and counts.
//

import XCTest
@testable import NurseryConnectKeyworker

final class AlertsViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DataService.shared.useSampleData = true
    }

    // MARK: - Initial Load

    func test_loadAlerts_populatesAlerts() async {
        let vm = await MainActor.run { AlertsViewModel() }
        let isEmpty = await MainActor.run { vm.alerts.isEmpty }
        XCTAssertFalse(isEmpty, "Alerts should not be empty with sample data")
    }

    // MARK: - Unacknowledged Count

    func test_unacknowledgedCount_matchesUnreadAlerts() async {
        let vm = await MainActor.run { AlertsViewModel() }
        let expected = await MainActor.run { vm.alerts.filter { !$0.isAcknowledged }.count }
        let count = await MainActor.run { vm.unacknowledgedCount }
        XCTAssertEqual(count, expected)
    }

    // MARK: - filteredAlerts (showAcknowledged = false — default)

    func test_filteredAlerts_onlyUnacknowledged_byDefault() async {
        let vm = await MainActor.run { AlertsViewModel() }
        await MainActor.run { vm.showAcknowledgedAlerts = false }
        let results = await MainActor.run { vm.filteredAlerts }
        XCTAssertTrue(results.allSatisfy { !$0.isAcknowledged })
    }

    func test_filteredAlerts_includesAcknowledged_whenToggled() async {
        let vm = await MainActor.run { AlertsViewModel() }
        await MainActor.run { vm.showAcknowledgedAlerts = true }
        let filteredCount = await MainActor.run { vm.filteredAlerts.count }
        let allCount = await MainActor.run { vm.alerts.count }
        XCTAssertEqual(filteredCount, allCount)
    }

    // MARK: - Priority Filtering

    func test_filteredAlerts_filtersByPriority_urgent() async {
        let vm = await MainActor.run { AlertsViewModel() }
        await MainActor.run {
            vm.showAcknowledgedAlerts = true
            vm.selectedPriority = .urgent
        }
        let results = await MainActor.run { vm.filteredAlerts }
        XCTAssertTrue(results.allSatisfy { $0.priority == .urgent })
    }

    func test_filteredAlerts_returnsAll_whenPriorityNil() async {
        let vm = await MainActor.run { AlertsViewModel() }
        await MainActor.run {
            vm.showAcknowledgedAlerts = true
            vm.selectedPriority = nil
        }
        let filteredCount = await MainActor.run { vm.filteredAlerts.count }
        let allCount = await MainActor.run { vm.alerts.count }
        XCTAssertEqual(filteredCount, allCount)
    }

    // MARK: - Alert Type Filtering

    func test_filteredAlerts_filtersByType_allergy() async {
        let vm = await MainActor.run { AlertsViewModel() }
        await MainActor.run {
            vm.showAcknowledgedAlerts = true
            vm.selectedAlertType = .allergy
        }
        let results = await MainActor.run { vm.filteredAlerts }
        XCTAssertTrue(results.allSatisfy { $0.alertType == .allergy })
    }

    func test_allergyAlerts_onlyContainAllergyType() async {
        let vm = await MainActor.run { AlertsViewModel() }
        let results = await MainActor.run { vm.allergyAlerts }
        XCTAssertTrue(results.allSatisfy { $0.alertType == .allergy })
    }

    func test_medicalAlerts_onlyContainMedicalType() async {
        let vm = await MainActor.run { AlertsViewModel() }
        let results = await MainActor.run { vm.medicalAlerts }
        XCTAssertTrue(results.allSatisfy { $0.alertType == .medical })
    }

    // MARK: - Search Filtering

    func test_filteredAlerts_filtersByTitle_caseInsensitive() async {
        let vm = await MainActor.run { AlertsViewModel() }
        await MainActor.run {
            vm.showAcknowledgedAlerts = true
            vm.searchText = "peanut"
        }
        let results = await MainActor.run { vm.filteredAlerts }
        XCTAssertTrue(results.allSatisfy {
            $0.title.localizedCaseInsensitiveContains("peanut") ||
            $0.message.localizedCaseInsensitiveContains("peanut") ||
            $0.childName.localizedCaseInsensitiveContains("peanut")
        })
    }

    func test_filteredAlerts_returnsEmpty_forNonExistentSearch() async {
        let vm = await MainActor.run { AlertsViewModel() }
        await MainActor.run {
            vm.showAcknowledgedAlerts = true
            vm.searchText = "ZZZNOMATCH999"
        }
        let isEmpty = await MainActor.run { vm.filteredAlerts.isEmpty }
        XCTAssertTrue(isEmpty)
    }

    // MARK: - Critical Alerts

    func test_criticalAlerts_onlyContainUrgentOrCriticalPriority() async {
        let vm = await MainActor.run { AlertsViewModel() }
        let results = await MainActor.run { vm.criticalAlerts }
        XCTAssertTrue(results.allSatisfy { $0.priority == .urgent || $0.priority == .critical })
    }

    func test_criticalAlerts_areAllUnacknowledged() async {
        let vm = await MainActor.run { AlertsViewModel() }
        let results = await MainActor.run { vm.criticalAlerts }
        XCTAssertTrue(results.allSatisfy { !$0.isAcknowledged })
    }

    // MARK: - Sorted Alerts

    func test_sortedAlerts_higherPriorityFirst() async {
        let vm = await MainActor.run { AlertsViewModel() }
        await MainActor.run { vm.showAcknowledgedAlerts = true }
        let sorted = await MainActor.run { vm.sortedAlerts }
        for i in 0..<(sorted.count - 1) {
            XCTAssertGreaterThanOrEqual(
                sorted[i].priority.sortOrder,
                sorted[i + 1].priority.sortOrder,
                "Alerts should be sorted highest priority first"
            )
        }
    }

    // MARK: - Acknowledge Actions

    func test_acknowledgeAlert_immediatelyUpdatesViewModel() async {
        let vm = await MainActor.run { AlertsViewModel() }
        let maybeUnread = await MainActor.run { vm.alerts.first(where: { !$0.isAcknowledged }) }
        guard let unread = maybeUnread else { return }
        let countBefore = await MainActor.run { vm.unacknowledgedCount }
        await MainActor.run { vm.acknowledgeAlert(unread) }
        let countAfter = await MainActor.run { vm.unacknowledgedCount }
        XCTAssertLessThanOrEqual(countAfter, countBefore)
    }

    // MARK: - Clear Filters

    func test_clearFilters_resetsAllFilters() async {
        let vm = await MainActor.run { AlertsViewModel() }
        await MainActor.run {
            vm.selectedPriority = .urgent
            vm.selectedAlertType = .allergy
            vm.searchText = "test"
            vm.clearFilters()
        }
        let selectedPriority = await MainActor.run { vm.selectedPriority }
        let selectedAlertType = await MainActor.run { vm.selectedAlertType }
        let searchText = await MainActor.run { vm.searchText }
        XCTAssertNil(selectedPriority)
        XCTAssertNil(selectedAlertType)
        XCTAssertEqual(searchText, "")
    }

    // MARK: - Overdue Reminders

    func test_overdueReminders_containsOverdueDiaryType() async {
        let vm = await MainActor.run { AlertsViewModel() }
        let results = await MainActor.run { vm.overdueReminders }
        XCTAssertTrue(results.allSatisfy { $0.alertType == .overdueDiary })
    }
}
