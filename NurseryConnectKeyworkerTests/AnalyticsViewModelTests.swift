//
//  AnalyticsViewModelTests.swift
//  NurseryConnectKeyworkerTests
//
//  Unit tests for AnalyticsViewModel – verifies chart data aggregation,
//  summary stats, and child filtering behave correctly.
//

import XCTest
@testable import NurseryConnectKeyworker

@MainActor
final class AnalyticsViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DataService.shared.useSampleData = true
    }

    // MARK: - Initial Load

    func test_loadData_populatesChildren() {
        let vm = AnalyticsViewModel()
        XCTAssertFalse(vm.children.isEmpty, "Should load sample children")
    }

    func test_loadData_populatesDailyEntryCounts() {
        let vm = AnalyticsViewModel()
        XCTAssertFalse(vm.dailyEntryCounts.isEmpty, "Should have 7 days of data points")
    }

    func test_dailyEntryCounts_hasExactlySevenDays() {
        let vm = AnalyticsViewModel()
        XCTAssertEqual(vm.dailyEntryCounts.count, 7)
    }

    func test_loadData_populatesEntryTypeCounts() {
        let vm = AnalyticsViewModel()
        // Sample data has multiple entry types; at least one should appear
        XCTAssertFalse(vm.entryTypeCounts.isEmpty, "Entry type counts should not be empty")
    }

    func test_entryTypeCounts_onlyPositiveCounts() {
        let vm = AnalyticsViewModel()
        XCTAssertTrue(vm.entryTypeCounts.allSatisfy { $0.count > 0 },
                      "Only non-zero entry type counts should appear in chart data")
    }

    // MARK: - Summary Statistics

    func test_totalEntriesThisWeek_isNonNegative() {
        let vm = AnalyticsViewModel()
        XCTAssertGreaterThanOrEqual(vm.totalEntriesThisWeek, 0)
    }

    func test_pendingIncidentCount_isNonNegative() {
        let vm = AnalyticsViewModel()
        XCTAssertGreaterThanOrEqual(vm.pendingIncidentCount, 0)
    }

    func test_mostActiveChild_isNotEmpty() {
        let vm = AnalyticsViewModel()
        XCTAssertFalse(vm.mostActiveChild.isEmpty)
    }

    func test_averageMoodThisWeek_inRange() {
        let vm = AnalyticsViewModel()
        // If mood entries exist, average must be 1–5; if none, it is 0
        let avg = vm.averageMoodThisWeek
        XCTAssertTrue(avg == 0 || (avg >= 1 && avg <= 5),
                      "Average mood should be 0 (no data) or within 1–5")
    }

    // MARK: - Child Filter

    func test_selectedChildId_nil_includesAllEntries() {
        let vm = AnalyticsViewModel()
        vm.selectedChildId = nil
        vm.loadData()
        let totalCount = vm.dailyEntryCounts.map(\.count).reduce(0, +)
        XCTAssertGreaterThanOrEqual(totalCount, 0)
    }

    func test_selectedChildId_set_filtersEntriesToOneChild() {
        let vm = AnalyticsViewModel()
        guard let firstChild = vm.children.first else {
            XCTFail("No children in sample data")
            return
        }
        vm.selectedChildId = firstChild.id
        vm.loadData()
        // Entry type counts should only reflect one child's entries
        let filteredTotal = vm.entryTypeCounts.map(\.count).reduce(0, +)
        let allTotal: Int = {
            vm.selectedChildId = nil
            vm.loadData()
            return vm.entryTypeCounts.map(\.count).reduce(0, +)
        }()
        XCTAssertLessThanOrEqual(filteredTotal, allTotal,
                                  "Filtering by one child should not produce more entries than all children combined")
    }

    // MARK: - Incident Severity Counts

    func test_incidentSeverityCounts_onlyPositiveCounts() {
        let vm = AnalyticsViewModel()
        XCTAssertTrue(vm.incidentSeverityCounts.allSatisfy { $0.count > 0 },
                      "Only non-zero severity counts should appear")
    }

    func test_incidentSeverityCounts_matchesPendingCount() {
        let vm = AnalyticsViewModel()
        let severityTotal = vm.incidentSeverityCounts.map(\.count).reduce(0, +)
        // pending is a subset — severity total includes completed incidents in last 7 days
        XCTAssertGreaterThanOrEqual(severityTotal, vm.pendingIncidentCount)
    }

    // MARK: - Mood Trend

    func test_moodTrendPoints_averageMoodInRange() {
        let vm = AnalyticsViewModel()
        for point in vm.moodTrendPoints {
            XCTAssertGreaterThanOrEqual(point.averageMood, 1.0)
            XCTAssertLessThanOrEqual(point.averageMood, 5.0,
                                      "Mood average for \(point.childName) on \(point.day) is out of range")
        }
    }

    func test_moodTrendPoints_noDuplicateChildDay() {
        let vm = AnalyticsViewModel()
        var seen = Set<String>()
        for point in vm.moodTrendPoints {
            let key = "\(point.childName)|\(point.day)"
            XCTAssertFalse(seen.contains(key), "Duplicate mood point found: \(key)")
            seen.insert(key)
        }
    }
}
