//
//  DiaryViewModelTests.swift
//  NurseryConnectKeyworkerTests
//
//  Unit tests for DiaryViewModel: loading, filtering by type, and search.
//

import XCTest
@testable import NurseryConnectKeyworker

@MainActor
final class DiaryViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DataService.shared.useSampleData = true
    }

    // MARK: - Initial Load

    func test_loadEntries_populatesDiaryEntries() {
        let vm = DiaryViewModel()
        XCTAssertFalse(vm.diaryEntries.isEmpty, "Diary entries should not be empty with sample data")
    }

    // MARK: - Type Filtering

    func test_filteredEntries_returnsAll_whenNoTypeSelected() {
        let vm = DiaryViewModel()
        vm.selectedEntryType = nil
        XCTAssertEqual(vm.filteredEntries.count, vm.diaryEntries.count)
    }

    func test_filteredEntries_onlyMealEntries_whenMealSelected() {
        let vm = DiaryViewModel()
        vm.selectedEntryType = .meal
        let results = vm.filteredEntries
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.entryType == .meal })
    }

    func test_filteredEntries_onlyNapEntries_whenNapSelected() {
        let vm = DiaryViewModel()
        vm.selectedEntryType = .nap
        let results = vm.filteredEntries
        XCTAssertTrue(results.allSatisfy { $0.entryType == .nap })
    }

    func test_filteredEntries_onlyMoodEntries_whenMoodSelected() {
        let vm = DiaryViewModel()
        vm.selectedEntryType = .mood
        let results = vm.filteredEntries
        XCTAssertTrue(results.allSatisfy { $0.entryType == .mood })
    }

    func test_filteredEntries_onlyNappyEntries_whenNappySelected() {
        let vm = DiaryViewModel()
        vm.selectedEntryType = .nappy
        let results = vm.filteredEntries
        XCTAssertTrue(results.allSatisfy { $0.entryType == .nappy })
    }

    // MARK: - Search Filtering

    func test_filteredEntries_returnsAll_whenSearchEmpty() {
        let vm = DiaryViewModel()
        vm.searchText = ""
        XCTAssertEqual(vm.filteredEntries.count, vm.diaryEntries.count)
    }

    func test_filteredEntries_filtersByChildName_caseInsensitive() {
        let vm = DiaryViewModel()
        vm.searchText = "oliver"
        let results = vm.filteredEntries
        XCTAssertTrue(results.allSatisfy {
            $0.childName.localizedCaseInsensitiveContains("oliver") ||
            $0.title.localizedCaseInsensitiveContains("oliver") ||
            $0.description.localizedCaseInsensitiveContains("oliver")
        })
    }

    func test_filteredEntries_returnsEmpty_forNonExistentSearch() {
        let vm = DiaryViewModel()
        vm.searchText = "ZZZNOMATCH999"
        XCTAssertTrue(vm.filteredEntries.isEmpty)
    }

    // MARK: - Combined Filters

    func test_filteredEntries_combinesTypeAndSearch() {
        let vm = DiaryViewModel()
        vm.selectedEntryType = .meal
        vm.searchText = "Oliver"
        let results = vm.filteredEntries
        XCTAssertTrue(results.allSatisfy { $0.entryType == .meal })
    }

    // MARK: - Clear Filters

    func test_clearFilters_resetsTypeAndSearch() {
        let vm = DiaryViewModel()
        vm.selectedEntryType = .nap
        vm.searchText = "test"
        vm.clearFilters()
        XCTAssertNil(vm.selectedEntryType)
        XCTAssertEqual(vm.searchText, "")
    }

    // MARK: - Grouped Entries

    func test_entriesByDate_containsEntries() {
        let vm = DiaryViewModel()
        XCTAssertFalse(vm.entriesByDate.isEmpty)
    }

    func test_sortedDates_descendingOrder() {
        let vm = DiaryViewModel()
        let dates = vm.sortedDates
        for i in 0..<(dates.count - 1) {
            XCTAssertGreaterThanOrEqual(dates[i], dates[i + 1],
                "Dates should be in descending order")
        }
    }

    func test_totalEntriesCount_matchesDiaryEntries() {
        let vm = DiaryViewModel()
        XCTAssertEqual(vm.totalEntriesCount, vm.diaryEntries.count)
    }
}
