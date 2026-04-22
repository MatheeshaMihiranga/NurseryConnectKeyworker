//
//  ChildrenViewModelTests.swift
//  NurseryConnectKeyworkerTests
//
//  Unit tests for ChildrenViewModel filtering, search, and selection logic.
//

import XCTest
@testable import NurseryConnectKeyworker

@MainActor
final class ChildrenViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Use sample data so no SwiftData container is required in tests
        DataService.shared.useSampleData = true
    }

    // MARK: - Initial Load

    func test_loadChildren_populatesAssignedChildren() {
        let vm = ChildrenViewModel()
        XCTAssertFalse(vm.assignedChildren.isEmpty, "Assigned children should not be empty after load")
    }

    func test_loadChildren_returnsExpectedSampleCount() {
        let vm = ChildrenViewModel()
        // SampleDataProvider has 4 assigned children
        XCTAssertEqual(vm.assignedChildren.count, 4)
    }

    // MARK: - Search Filtering

    func test_filteredChildren_returnsAll_whenSearchEmpty() {
        let vm = ChildrenViewModel()
        vm.searchText = ""
        XCTAssertEqual(vm.filteredChildren.count, vm.assignedChildren.count)
    }

    func test_filteredChildren_filtersByName_caseInsensitive() {
        let vm = ChildrenViewModel()
        vm.searchText = "oliver"
        let results = vm.filteredChildren
        XCTAssertTrue(results.allSatisfy { $0.name.localizedCaseInsensitiveContains("oliver") })
    }

    func test_filteredChildren_returnsEmpty_forNoMatch() {
        let vm = ChildrenViewModel()
        vm.searchText = "ZZZZNONEXISTENT"
        XCTAssertTrue(vm.filteredChildren.isEmpty)
    }

    func test_filteredChildren_filtersByRoom() {
        let vm = ChildrenViewModel()
        vm.searchText = "Toddlers"
        let results = vm.filteredChildren
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.room.localizedCaseInsensitiveContains("Toddlers") })
    }

    func test_filteredChildren_partialNameMatch() {
        let vm = ChildrenViewModel()
        vm.searchText = "Em" // Should match "Emma"
        XCTAssertTrue(vm.filteredChildren.contains { $0.name.hasPrefix("Em") })
    }

    // MARK: - Child Selection

    func test_selectChild_setsSelectedChild() {
        let vm = ChildrenViewModel()
        guard let first = vm.assignedChildren.first else {
            XCTFail("No children to select")
            return
        }
        vm.selectChild(first)
        XCTAssertEqual(vm.selectedChild?.id, first.id)
    }

    func test_clearSelection_nilsSelectedChild() {
        let vm = ChildrenViewModel()
        if let first = vm.assignedChildren.first {
            vm.selectChild(first)
        }
        vm.clearSelection()
        XCTAssertNil(vm.selectedChild)
    }

    // MARK: - Computed Collections

    func test_childrenWithAllergies_onlyContainsAllergyChildren() {
        let vm = ChildrenViewModel()
        let result = vm.childrenWithAllergies
        XCTAssertTrue(result.allSatisfy { $0.hasAllergies })
    }

    func test_childrenWithDietaryRestrictions_onlyContainsDietChildren() {
        let vm = ChildrenViewModel()
        let result = vm.childrenWithDietaryRestrictions
        XCTAssertTrue(result.allSatisfy { $0.hasDietaryRestrictions })
    }

    func test_childrenWithMedicalNotes_onlyContainsMedicalChildren() {
        let vm = ChildrenViewModel()
        let result = vm.childrenWithMedicalNotes
        XCTAssertTrue(result.allSatisfy { $0.hasMedicalNotes })
    }

    func test_childrenCount_matchesAssignedChildren() {
        let vm = ChildrenViewModel()
        XCTAssertEqual(vm.childrenCount, vm.assignedChildren.count)
    }
}

