//
//  AttendanceViewModel.swift
//  NurseryConnectKeyworker
//
//  Part A – New NurseryConnect Feature: Daily Attendance Tracking.
//  Keyworkers can mark each assigned child as Present, Absent, or Late
//  for each session (Morning / Afternoon) and add a short note.
//
//  This is entirely new functionality not present in Assignment 1.
//

import Foundation
import SwiftUI

// MARK: - Enums

enum AttendanceStatus: String, CaseIterable, Codable {
    case present = "Present"
    case absent  = "Absent"
    case late    = "Late"

    var icon: String {
        switch self {
        case .present: return "checkmark.circle.fill"
        case .absent:  return "xmark.circle.fill"
        case .late:    return "clock.badge.exclamationmark.fill"
        }
    }

    var color: Color {
        switch self {
        case .present: return .green
        case .absent:  return .red
        case .late:    return .orange
        }
    }
}

enum NurserySession: String, CaseIterable {
    case morning   = "Morning"
    case afternoon = "Afternoon"
    case fullDay   = "Full Day"
}

// MARK: - Data Model (no SwiftData — stored in UserDefaults, keyed by date+childId)

struct AttendanceRecord: Identifiable, Codable {
    var id: UUID = UUID()
    let childId: UUID
    let childName: String
    let date: String           // ISO8601 yyyy-MM-dd
    var session: String        // NurserySession rawValue
    var status: String         // AttendanceStatus rawValue
    var arrivalTime: Date?
    var note: String

    var attendanceStatus: AttendanceStatus {
        AttendanceStatus(rawValue: status) ?? .present
    }
    var nurserySession: NurserySession {
        NurserySession(rawValue: session) ?? .fullDay
    }
}

// MARK: - ViewModel

@Observable
class AttendanceViewModel {

    var records: [AttendanceRecord] = []
    var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    var selectedSession: NurserySession = .morning
    var children: [Child] = []
    var isEditing = false

    // Daily summary
    var presentCount: Int  { records.filter { $0.status == AttendanceStatus.present.rawValue }.count }
    var absentCount: Int   { records.filter { $0.status == AttendanceStatus.absent.rawValue }.count }
    var lateCount: Int     { records.filter { $0.status == AttendanceStatus.late.rawValue }.count }
    var attendanceRate: Double {
        guard !children.isEmpty else { return 0 }
        return Double(presentCount + lateCount) / Double(children.count)
    }

    private let dataService = DataService.shared

    init() {
        loadChildren()
        loadRecords()
    }

    // MARK: - Load

    func loadChildren() {
        children = dataService.getAssignedChildren()
    }

    func loadRecords() {
        let dateKey = isoDate(from: selectedDate)
        let stored = AttendanceStore.load(for: dateKey, session: selectedSession.rawValue)

        // Merge: ensure every child has a record for this day/session
        var merged: [AttendanceRecord] = []
        for child in children {
            if let existing = stored.first(where: { $0.childId == child.id }) {
                merged.append(existing)
            } else {
                // Default: present unless otherwise marked
                merged.append(AttendanceRecord(
                    childId: child.id,
                    childName: child.name,
                    date: dateKey,
                    session: selectedSession.rawValue,
                    status: AttendanceStatus.present.rawValue,
                    arrivalTime: nil,
                    note: ""
                ))
            }
        }
        records = merged
    }

    // MARK: - Update

    func setStatus(_ status: AttendanceStatus, for childId: UUID) {
        guard let idx = records.firstIndex(where: { $0.childId == childId }) else { return }
        records[idx].status = status.rawValue
        if status == .present || status == .late {
            records[idx].arrivalTime = records[idx].arrivalTime ?? Date()
        } else {
            records[idx].arrivalTime = nil
        }
        saveRecords()
    }

    func setNote(_ note: String, for childId: UUID) {
        guard let idx = records.firstIndex(where: { $0.childId == childId }) else { return }
        records[idx].note = note
        saveRecords()
    }

    func setArrivalTime(_ time: Date, for childId: UUID) {
        guard let idx = records.firstIndex(where: { $0.childId == childId }) else { return }
        records[idx].arrivalTime = time
        saveRecords()
    }

    func markAllPresent() {
        for i in records.indices {
            records[i].status = AttendanceStatus.present.rawValue
        }
        saveRecords()
    }

    // MARK: - Persistence

    private func saveRecords() {
        let dateKey = isoDate(from: selectedDate)
        AttendanceStore.save(records, for: dateKey, session: selectedSession.rawValue)
    }

    private func isoDate(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

// MARK: - Persistence store

enum AttendanceStore {
    private static func key(date: String, session: String) -> String {
        "attendance_\(date)_\(session)"
    }

    static func load(for date: String, session: String) -> [AttendanceRecord] {
        guard let data = UserDefaults.standard.data(forKey: key(date: date, session: session)),
              let decoded = try? JSONDecoder().decode([AttendanceRecord].self, from: data)
        else { return [] }
        return decoded
    }

    static func save(_ records: [AttendanceRecord], for date: String, session: String) {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key(date: date, session: session))
        }
    }
}
