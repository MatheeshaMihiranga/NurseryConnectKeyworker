//
//  AnalyticsView.swift
//  NurseryConnectKeyworker
//
//  Activity & Mood Analytics screen — Part A iPadOS extension.
//  Uses Swift Charts to visualise diary activity, entry type breakdowns,
//  mood trends, and incident statistics over the last 7 days.
//
//  iPad: renders as a two-column grid of chart cards for efficient use of screen space.
//  iPhone: renders as a single-column scrollable list.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @State private var viewModel = AnalyticsViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Child picker
                    childFilterPicker

                    // Summary stat cards
                    summaryStatsRow

                    if sizeClass == .regular {
                        // iPad: 2-column grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            dailyActivityCard
                            entryTypeBreakdownCard
                            moodTrendCard
                            incidentSeverityCard
                        }
                    } else {
                        // iPhone: single column
                        dailyActivityCard
                        entryTypeBreakdownCard
                        moodTrendCard
                        incidentSeverityCard
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.loadData()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .keyboardShortcut("r", modifiers: .command)
                    .accessibilityLabel("Refresh analytics data")
                }
            }
            .onAppear { viewModel.loadData() }
            .refreshable { viewModel.loadData() }
        }
    }

    // MARK: - Child Filter Picker

    private var childFilterPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter by Child")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    filterChip(label: "All Children", id: nil)
                    ForEach(viewModel.children, id: \.id) { child in
                        filterChip(label: child.name, id: child.id)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private func filterChip(label: String, id: UUID?) -> some View {
        let isSelected = viewModel.selectedChildId == id
        return Button {
            viewModel.selectedChildId = id
            viewModel.loadData()
        } label: {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Summary Stats Row

    private var summaryStatsRow: some View {
        let columns = sizeClass == .regular
            ? [GridItem(.flexible()), GridItem(.flexible()),
               GridItem(.flexible()), GridItem(.flexible())]
            : [GridItem(.flexible()), GridItem(.flexible())]

        return LazyVGrid(columns: columns, spacing: 12) {
            statCard(
                value: "\(viewModel.totalEntriesThisWeek)",
                label: "Diary Entries\nThis Week",
                icon: "book.fill",
                color: .blue
            )
            statCard(
                value: viewModel.averageMoodThisWeek > 0
                    ? String(format: "%.1f/5", viewModel.averageMoodThisWeek)
                    : "–",
                label: "Avg Mood\nRating",
                icon: "face.smiling.fill",
                color: .purple
            )
            statCard(
                value: "\(viewModel.pendingIncidentCount)",
                label: "Pending\nIncidents",
                icon: "exclamationmark.triangle.fill",
                color: viewModel.pendingIncidentCount > 0 ? .orange : .green
            )
            statCard(
                value: viewModel.mostActiveChild,
                label: "Most Active\nChild",
                icon: "star.fill",
                color: .yellow
            )
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label.replacingOccurrences(of: "\n", with: " ")): \(value)")
    }

    // MARK: - Chart Card: Daily Activity (Bar)

    private var dailyActivityCard: some View {
        chartCard(title: "Diary Entries – Last 7 Days", icon: "calendar") {
            if viewModel.dailyEntryCounts.isEmpty {
                emptyChartPlaceholder("No diary entries this week")
            } else {
                Chart(viewModel.dailyEntryCounts) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Entries", item.count)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(4)
                    .annotation(position: .top) {
                        if item.count > 0 {
                            Text("\(item.count)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4))
                }
                .chartYAxisLabel("Count")
                .frame(height: 180)
                .accessibilityLabel("Bar chart showing diary entries logged each day over the last 7 days")
            }
        }
    }

    // MARK: - Chart Card: Entry Type Breakdown (Bar)

    private var entryTypeBreakdownCard: some View {
        chartCard(title: "Entry Type Breakdown", icon: "chart.bar") {
            if viewModel.entryTypeCounts.isEmpty {
                emptyChartPlaceholder("No entries to display")
            } else {
                Chart(viewModel.entryTypeCounts) { item in
                    BarMark(
                        x: .value("Type", item.label),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(item.color.gradient)
                    .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4))
                }
                .chartYAxisLabel("Count")
                .frame(height: 180)
                .accessibilityLabel("Bar chart showing breakdown of diary entry types such as meals, naps, and activities")
            }
        }
    }

    // MARK: - Chart Card: Mood Trend (Line)

    private var moodTrendCard: some View {
        chartCard(title: "Mood Trend – Last 7 Days", icon: "face.smiling") {
            if viewModel.moodTrendPoints.isEmpty {
                emptyChartPlaceholder("No mood entries recorded this week")
            } else {
                Chart(viewModel.moodTrendPoints) { point in
                    LineMark(
                        x: .value("Day", point.day),
                        y: .value("Mood", point.averageMood)
                    )
                    .foregroundStyle(by: .value("Child", point.childName))
                    .symbol(by: .value("Child", point.childName))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Day", point.day),
                        y: .value("Mood", point.averageMood)
                    )
                    .foregroundStyle(by: .value("Child", point.childName))
                }
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text(moodLabel(for: v))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartLegend(position: .bottom, alignment: .center)
                .frame(height: 200)
                .accessibilityLabel("Line chart showing average mood rating per child over the last 7 days")
            }
        }
    }

    private func moodLabel(for rating: Int) -> String {
        switch rating {
        case 1: return "😢 1"
        case 2: return "🙁 2"
        case 3: return "😐 3"
        case 4: return "🙂 4"
        case 5: return "😄 5"
        default: return "\(rating)"
        }
    }

    // MARK: - Chart Card: Incidents by Severity (Bar)

    private var incidentSeverityCard: some View {
        chartCard(title: "Incidents by Severity – Last 7 Days", icon: "exclamationmark.triangle") {
            if viewModel.incidentSeverityCounts.isEmpty {
                emptyChartPlaceholder("No incidents reported this week")
                    .foregroundStyle(.green)
            } else {
                Chart(viewModel.incidentSeverityCounts) { item in
                    BarMark(
                        x: .value("Severity", item.label),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(item.color.gradient)
                    .cornerRadius(4)
                    .annotation(position: .top) {
                        Text("\(item.count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4))
                }
                .chartYAxisLabel("Count")
                .frame(height: 180)
                .accessibilityLabel("Bar chart showing incident count by severity level in the last 7 days")
            }
        }
    }

    // MARK: - Shared Chart Card Container

    private func chartCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.primary)
            content()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func emptyChartPlaceholder(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}

#Preview {
    AnalyticsView()
}
