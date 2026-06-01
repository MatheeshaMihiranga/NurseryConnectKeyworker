//
//  AnalyticsViewModel.swift
//  NurseryConnectKeyworker
//
//  ViewModel for the Analytics screen.
//  Aggregates DiaryEntry and IncidentReport data into chart-ready structures
//  using Swift Charts. All computed over the last 7 calendar days.
//

import Foundation
import SwiftUI

// MARK: - Chart Data Models

/// One bar in the "entries per day" bar chart
struct DailyEntryCount: Identifiable {
    let id = UUID()
    let day: String      // Short weekday label e.g. "Mon"
    let date: Date
    let count: Int
}

/// One segment in the "entry type breakdown" bar chart
struct EntryTypeCount: Identifiable {
    let id = UUID()
    let type: DiaryEntryType
    let count: Int
    var label: String { type.rawValue }
    var color: Color {
        switch type {
        case .meal:     return .green
        case .nap:      return .blue
        case .activity: return .orange
        case .mood:     return .purple
        case .nappy:    return Color(red: 0.6, green: 0.4, blue: 0.2)
        }
    }
}

/// One point on the "mood trend" line chart
struct MoodDataPoint: Identifiable {
    let id = UUID()
    let childName: String
    let day: String
    let date: Date
    let averageMood: Double
}

/// One bar in the "incidents by severity" chart
struct IncidentSeverityCount: Identifiable {
    let id = UUID()
    let severity: IncidentSeverity
    let count: Int
    var label: String { severity.rawValue.capitalized }
    var color: Color {
        switch severity {
        case .minor:    return .green
        case .moderate: return .yellow
        case .serious:  return .orange
        case .major:    return .red
        }
    }
}

// MARK: - ViewModel

@Observable
class AnalyticsViewModel {

    // MARK: - Published Data

    var dailyEntryCounts: [DailyEntryCount] = []
    var entryTypeCounts: [EntryTypeCount] = []
    var moodTrendPoints: [MoodDataPoint] = []
    var incidentSeverityCounts: [IncidentSeverityCount] = []
    var totalEntriesThisWeek: Int = 0
    var averageMoodThisWeek: Double = 0
    var pendingIncidentCount: Int = 0
    var mostActiveChild: String = "–"
    var selectedChildId: UUID? = nil
    var children: [Child] = []

    private let dataService = DataService.shared

    // MARK: - Init

    init() {
        loadData()
    }

    // MARK: - Public

    func loadData() {
        children = dataService.getAssignedChildren()
        let entries = dataService.getDiaryEntries(for: selectedChildId)
        let incidents = dataService.getIncidents()

        buildDailyEntryCounts(from: entries)
        buildEntryTypeCounts(from: entries)
        buildMoodTrend(from: entries)
        buildIncidentSeverityCounts(from: incidents)
        buildSummaryStats(from: entries, incidents: incidents)
    }

    // MARK: - Chart Builders

    private func buildDailyEntryCounts(from entries: [DiaryEntry]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // "Mon", "Tue" …

        dailyEntryCounts = (0..<7).reversed().map { offset -> DailyEntryCount in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
            let count = entries.filter { $0.timestamp >= date && $0.timestamp < nextDate }.count
            return DailyEntryCount(day: formatter.string(from: date), date: date, count: count)
        }
    }

    private func buildEntryTypeCounts(from entries: [DiaryEntry]) {
        entryTypeCounts = DiaryEntryType.allCases.compactMap { type -> EntryTypeCount? in
            let count = entries.filter { $0.entryType == type }.count
            guard count > 0 else { return nil }
            return EntryTypeCount(type: type, count: count)
        }
    }

    private func buildMoodTrend(from entries: [DiaryEntry]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        let moodEntries = entries.filter { $0.entryType == .mood && $0.moodRating != nil }

        // Group by child + day
        var points: [MoodDataPoint] = []

        let childNames = Set(moodEntries.map { $0.childName })
        for childName in childNames.sorted() {
            let childEntries = moodEntries.filter { $0.childName == childName }
            for offset in (0..<7).reversed() {
                let date = calendar.date(byAdding: .day, value: -offset, to: today)!
                let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
                let dayEntries = childEntries.filter { $0.timestamp >= date && $0.timestamp < nextDate }
                guard !dayEntries.isEmpty else { continue }
                let avg = dayEntries.compactMap { $0.moodRating }.map(Double.init).reduce(0, +) / Double(dayEntries.count)
                points.append(MoodDataPoint(
                    childName: childName,
                    day: formatter.string(from: date),
                    date: date,
                    averageMood: avg
                ))
            }
        }

        moodTrendPoints = points
    }

    private func buildIncidentSeverityCounts(from incidents: [IncidentReport]) {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let recentIncidents = incidents.filter { $0.timestamp >= sevenDaysAgo }

        incidentSeverityCounts = IncidentSeverity.allCases.compactMap { severity -> IncidentSeverityCount? in
            let count = recentIncidents.filter { $0.severity == severity }.count
            guard count > 0 else { return nil }
            return IncidentSeverityCount(severity: severity, count: count)
        }
    }

    private func buildSummaryStats(from entries: [DiaryEntry], incidents: [IncidentReport]) {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

        let weekEntries = entries.filter { $0.timestamp >= sevenDaysAgo }
        totalEntriesThisWeek = weekEntries.count

        let moodRatings = weekEntries.compactMap { $0.moodRating }.map(Double.init)
        averageMoodThisWeek = moodRatings.isEmpty ? 0 : moodRatings.reduce(0, +) / Double(moodRatings.count)

        pendingIncidentCount = incidents.filter { $0.isPending }.count

        // Most active child = most diary entries this week
        let counts = Dictionary(grouping: weekEntries, by: \.childName).mapValues(\.count)
        mostActiveChild = counts.max(by: { $0.value < $1.value })?.key ?? "–"
    }
}
