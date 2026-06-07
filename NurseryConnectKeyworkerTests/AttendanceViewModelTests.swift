//
//  AttendanceViewModelTests.swift
//  NurseryConnectKeyworkerTests
//
//  Unit tests for AttendanceViewModel – verifies attendance marking,
//  summary counts, and mark-all-present functionality.
//

import XCTest
@testable import NurseryConnectKeyworker

@MainActor
final class AttendanceViewModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        DataService.shared.useSampleData = true
    }

    // MARK: - Initial Load

    func test_loadChildren_populatesChildren() {
        let vm = AttendanceViewModel()
        XCTAssertFalse(vm.children.isEmpty, "Sample children should be loaded")
    }

    func test_loadRecords_createsOneRecordPerChild() {
        let vm = AttendanceViewModel()
        XCTAssertEqual(vm.records.count, vm.children.count,
                       "Should have one attendance record per assigned child")
    }

    func test_defaultStatus_isPresent() {
        let vm = AttendanceViewModel()
        let allPresent = vm.records.allSatisfy { $0.status == AttendanceStatus.present.rawValue }
        XCTAssertTrue(allPresent, "All children should default to Present")
    }

    // MARK: - Status Changes

    func test_setStatus_updatesRecord() {
        let vm = AttendanceViewModel()
        guard let first = vm.records.first else {
            XCTFail("No records"); return
        }
        vm.setStatus(.absent, for: first.childId)
        let updated = vm.records.first { $0.childId == first.childId }
        XCTAssertEqual(updated?.status, AttendanceStatus.absent.rawValue)
    }

    func test_setStatus_late_setsArrivalTime() {
        let vm = AttendanceViewModel()
        guard let first = vm.records.first else {
            XCTFail("No records"); return
        }
        vm.setStatus(.late, for: first.childId)
        let updated = vm.records.first { $0.childId == first.childId }
        XCTAssertNotNil(updated?.arrivalTime, "Late status should set an arrival time")
    }

    func test_setStatus_absent_clearsArrivalTime() {
        let vm = AttendanceViewModel()
        guard let first = vm.records.first else {
            XCTFail("No records"); return
        }
        // Set late first, then absent
        vm.setStatus(.late, for: first.childId)
        vm.setStatus(.absent, for: first.childId)
        let updated = vm.records.first { $0.childId == first.childId }
        XCTAssertNil(updated?.arrivalTime, "Absent status should clear arrival time")
    }

    // MARK: - Summary Counts

    func test_presentCount_reflectsRecords() {
        let vm = AttendanceViewModel()
        let expected = vm.records.filter { $0.status == AttendanceStatus.present.rawValue }.count
        XCTAssertEqual(vm.presentCount, expected)
    }

    func test_absentCount_reflectsRecords() {
        let vm = AttendanceViewModel()
        guard let first = vm.records.first else {
            XCTFail("No records"); return
        }
        vm.setStatus(.absent, for: first.childId)
        XCTAssertEqual(vm.absentCount, 1)
    }

    func test_lateCount_reflectsRecords() {
        let vm = AttendanceViewModel()
        guard let first = vm.records.first else {
            XCTFail("No records"); return
        }
        vm.setStatus(.late, for: first.childId)
        XCTAssertEqual(vm.lateCount, 1)
    }

    func test_attendanceRate_isOneWhenAllPresent() {
        let vm = AttendanceViewModel()
        vm.markAllPresent()
        XCTAssertEqual(vm.attendanceRate, 1.0, accuracy: 0.001)
    }

    func test_attendanceRate_isZeroWhenAllAbsent() {
        let vm = AttendanceViewModel()
        vm.records.forEach { vm.setStatus(.absent, for: $0.childId) }
        XCTAssertEqual(vm.attendanceRate, 0.0, accuracy: 0.001)
    }

    // MARK: - Mark All Present

    func test_markAllPresent_setsAllPresent() {
        let vm = AttendanceViewModel()
        // First set some to absent
        vm.records.forEach { vm.setStatus(.absent, for: $0.childId) }
        // Now mark all present
        vm.markAllPresent()
        XCTAssertTrue(vm.records.allSatisfy { $0.status == AttendanceStatus.present.rawValue })
    }

    func test_markAllPresent_presentCountEqualsChildCount() {
        let vm = AttendanceViewModel()
        vm.markAllPresent()
        XCTAssertEqual(vm.presentCount, vm.children.count)
    }

    // MARK: - Note

    func test_setNote_updatesRecord() {
        let vm = AttendanceViewModel()
        guard let first = vm.records.first else {
            XCTFail("No records"); return
        }
        vm.setNote("Collected by grandparent", for: first.childId)
        let updated = vm.records.first { $0.childId == first.childId }
        XCTAssertEqual(updated?.note, "Collected by grandparent")
    }
}
