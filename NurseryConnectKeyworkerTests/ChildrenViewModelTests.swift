//
//  ChildrenViewModelTests.swift
//  NurseryConnectKeyworkerTests
//
//  Unit tests for ChildrenViewModel filtering, search, and selection logic.
//

import XCTest
@testable import NurseryConnectKeyworker

final class ChildrenViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Use sample data so no SwiftData container is required in tests
        DataService.shared.useSampleData = true
    }

    // MARK: - Initial Load

    func test_loadChildren_populatesAssignedChildren() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        let isEmpty = await MainActor.run { vm.assignedChildren.isEmpty }
        XCTAssertFalse(isEmpty, "Assigned children should not be empty after load")
    }

    func test_loadChildren_returnsExpectedSampleCount() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        let count = await MainActor.run { vm.assignedChildren.count }
        XCTAssertEqual(count, 4)
    }

    // MARK: - Search Filtering

    func test_filteredChildren_returnsAll_whenSearchEmpty() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        await MainActor.run { vm.searchText = "" }
        let filteredCount = await MainActor.run { vm.filteredChildren.count }
        let allCount = await MainActor.run { vm.assignedChildren.count }
        XCTAssertEqual(filteredCount, allCount)
    }

    func test_filteredChildren_filtersByName_caseInsensitive() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        await MainActor.run { vm.searchText = "oliver" }
        let results = await MainActor.run { vm.filteredChildren }
        XCTAssertTrue(results.allSatisfy { $0.name.localizedCaseInsensitiveContains("oliver") })
    }

    func test_filteredChildren_returnsEmpty_forNoMatch() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        await MainActor.run { vm.searchText = "ZZZZNONEXISTENT" }
        let isEmpty = await MainActor.run { vm.filteredChildren.isEmpty }
        XCTAssertTrue(isEmpty)
    }

    func test_filteredChildren_filtersByRoom() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        await MainActor.run { vm.searchText = "Toddlers" }
        let results = await MainActor.run { vm.filteredChildren }
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.room.localizedCaseInsensitiveContains("Toddlers") })
    }

    func test_filteredChildren_partialNameMatch() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        await MainActor.run { vm.searchText = "Em" }
        let containsPrefix = await MainActor.run { vm.filteredChildren.contains { $0.name.hasPrefix("Em") } }
        XCTAssertTrue(containsPrefix)
    }

    // MARK: - Child Selection

    func test_selectChild_setsSelectedChild() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        let first = await MainActor.run { vm.assignedChildren.first }
        guard let first else {
            XCTFail("No children to select")
            return
        }
        await MainActor.run { vm.selectChild(first) }
        let selectedId = await MainActor.run { vm.selectedChild?.id }
        XCTAssertEqual(selectedId, first.id)
    }

    func test_clearSelection_nilsSelectedChild() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        let first = await MainActor.run { vm.assignedChildren.first }
        if let first {
            await MainActor.run { vm.selectChild(first) }
        }
        await MainActor.run { vm.clearSelection() }
        let selected = await MainActor.run { vm.selectedChild }
        XCTAssertNil(selected)
    }

    // MARK: - Computed Collections

    func test_childrenWithAllergies_onlyContainsAllergyChildren() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        let result = await MainActor.run { vm.childrenWithAllergies }
        XCTAssertTrue(result.allSatisfy { $0.hasAllergies })
    }

    func test_childrenWithDietaryRestrictions_onlyContainsDietChildren() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        let result = await MainActor.run { vm.childrenWithDietaryRestrictions }
        XCTAssertTrue(result.allSatisfy { $0.hasDietaryRestrictions })
    }

    func test_childrenWithMedicalNotes_onlyContainsMedicalChildren() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        let result = await MainActor.run { vm.childrenWithMedicalNotes }
        XCTAssertTrue(result.allSatisfy { $0.hasMedicalNotes })
    }

    func test_childrenCount_matchesAssignedChildren() async {
        let vm = await MainActor.run { ChildrenViewModel() }
        let count = await MainActor.run { vm.childrenCount }
        let assigned = await MainActor.run { vm.assignedChildren.count }
        XCTAssertEqual(count, assigned)
    }
}

