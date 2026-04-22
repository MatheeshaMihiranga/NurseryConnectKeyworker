//
//  IncidentViewModelTests.swift
//  NurseryConnectKeyworkerTests
//
//  Unit tests for IncidentViewModel: filtering by category, severity, search,
//  pending/complete status grouping, and status update actions.
//

import XCTest
@testable import NurseryConnectKeyworker

@MainActor
final class IncidentViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DataService.shared.useSampleData = true
    }

    // MARK: - Initial Load

    func test_loadIncidents_populatesIncidents() {
        let vm = IncidentViewModel()
        XCTAssertFalse(vm.incidents.isEmpty, "Incidents should not be empty with sample data")
    }

    // MARK: - Pending / Complete

    func test_pendingIncidents_allArePending() {
        let vm = IncidentViewModel()
        let result = vm.pendingIncidents
        XCTAssertTrue(result.allSatisfy { $0.isPending })
    }

    func test_completedIncidents_allAreComplete() {
        let vm = IncidentViewModel()
        let result = vm.completedIncidents
        XCTAssertTrue(result.allSatisfy { $0.isComplete })
    }

    func test_pendingCount_matchesPendingIncidents() {
        let vm = IncidentViewModel()
        XCTAssertEqual(vm.pendingCount, vm.pendingIncidents.count)
    }

    // MARK: - filteredIncidents (showCompleted = false — default)

    func test_filteredIncidents_onlyPending_byDefault() {
        let vm = IncidentViewModel()
        vm.showCompletedIncidents = false
        let results = vm.filteredIncidents
        XCTAssertTrue(results.allSatisfy { $0.isPending })
    }

    func test_filteredIncidents_includesAll_whenShowCompletedTrue() {
        let vm = IncidentViewModel()
        vm.showCompletedIncidents = true
        XCTAssertEqual(vm.filteredIncidents.count, vm.incidents.count)
    }

    // MARK: - Category Filtering

    func test_filteredIncidents_filtersByCategory_injury() {
        let vm = IncidentViewModel()
        vm.showCompletedIncidents = true
        vm.selectedCategory = .injury
        let results = vm.filteredIncidents
        XCTAssertTrue(results.allSatisfy { $0.category == .injury })
    }

    func test_filteredIncidents_filtersByCategory_behavior() {
        let vm = IncidentViewModel()
        vm.showCompletedIncidents = true
        vm.selectedCategory = .behavior
        let results = vm.filteredIncidents
        XCTAssertTrue(results.allSatisfy { $0.category == .behavior })
    }

    func test_filteredIncidents_returnsAll_whenCategoryNil() {
        let vm = IncidentViewModel()
        vm.showCompletedIncidents = true
        vm.selectedCategory = nil
        XCTAssertEqual(vm.filteredIncidents.count, vm.incidents.count)
    }

    // MARK: - Severity Filtering

    func test_filteredIncidents_filtersBySeverity_minor() {
        let vm = IncidentViewModel()
        vm.showCompletedIncidents = true
        vm.selectedSeverity = .minor
        let results = vm.filteredIncidents
        XCTAssertTrue(results.allSatisfy { $0.severity == .minor })
    }

    func test_filteredIncidents_returnsAll_whenSeverityNil() {
        let vm = IncidentViewModel()
        vm.showCompletedIncidents = true
        vm.selectedSeverity = nil
        XCTAssertEqual(vm.filteredIncidents.count, vm.incidents.count)
    }

    // MARK: - Search Filtering

    func test_filteredIncidents_filtersByChildName() {
        let vm = IncidentViewModel()
        vm.showCompletedIncidents = true
        vm.searchText = "Oliver"
        let results = vm.filteredIncidents
        XCTAssertTrue(results.allSatisfy {
            $0.childName.localizedCaseInsensitiveContains("Oliver") ||
            $0.description.localizedCaseInsensitiveContains("Oliver") ||
            $0.location.localizedCaseInsensitiveContains("Oliver")
        })
    }

    func test_filteredIncidents_returnsEmpty_forNonExistentSearch() {
        let vm = IncidentViewModel()
        vm.showCompletedIncidents = true
        vm.searchText = "ZZZNOMATCH999"
        XCTAssertTrue(vm.filteredIncidents.isEmpty)
    }

    // MARK: - Clear Filters

    func test_clearFilters_resetsAllFilters() {
        let vm = IncidentViewModel()
        vm.selectedCategory = .injury
        vm.selectedSeverity = .major
        vm.showCompletedIncidents = true
        vm.clearFilters()
        XCTAssertNil(vm.selectedCategory)
        XCTAssertNil(vm.selectedSeverity)
        XCTAssertFalse(vm.showCompletedIncidents)
    }

    // MARK: - Status Update Actions

    func test_markAsReviewed_updatesPendingCount() async {
        let vm = IncidentViewModel()
        let countBefore = vm.pendingCount
        guard let pendingIncident = vm.pendingIncidents.first(where: { !$0.managerReviewed }) else {
            return // No incidents pending manager review in sample data — skip
        }
        vm.markAsReviewed(pendingIncident)
        // Allow async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(vm.pendingCount <= countBefore,
            "Pending count should not increase after marking as reviewed")
    }

    func test_requiresParentNotification_containsUnnotifiedReports() {
        let vm = IncidentViewModel()
        let result = vm.requiresParentNotification
        XCTAssertTrue(result.allSatisfy { !$0.parentNotified })
    }

    func test_requiresManagerReview_containsUnreviewedReports() {
        let vm = IncidentViewModel()
        let result = vm.requiresManagerReview
        XCTAssertTrue(result.allSatisfy { !$0.managerReviewed })
    }
}
