//
//  SpatialChildDetailView.swift
//  NurseryConnectVision
//
//  Detail sheet shown when a child card is tapped in the visionOS dashboard.
//  Shows full child info, diary summary, and quick log actions.
//

import SwiftUI

struct SpatialChildDetailView: View {
    let child: VisionChild
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                overviewTab
                    .tabItem { Label("Overview", systemImage: "person.fill") }
                    .tag(0)

                diaryTab
                    .tabItem { Label("Diary", systemImage: "book.fill") }
                    .tag(1)

                healthTab
                    .tabItem { Label("Health", systemImage: "heart.fill") }
                    .tag(2)
            }
            .navigationTitle(child.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    // MARK: - Overview Tab

    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Avatar header
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.2))
                            .frame(width: 80, height: 80)
                        Image(systemName: child.photoSymbol)
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(child.name)
                            .font(.title.bold())
                        Text("\(child.displayAge) · \(child.room)")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()

                    // Mood display
                    VStack(spacing: 4) {
                        Text(child.moodEmoji)
                            .font(.system(size: 44))
                        Text(String(format: "%.1f / 5", child.moodAverage))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .glassBackgroundEffect()
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Quick stats
                HStack(spacing: 16) {
                    detailStat("Diary Entries", value: "\(child.diaryCount)", icon: "book.fill", color: .green)
                    detailStat("Pending Incidents", value: "\(child.pendingIncidents)", icon: "exclamationmark.triangle.fill",
                               color: child.pendingIncidents > 0 ? .orange : .green)
                    detailStat("Avg Mood", value: String(format: "%.1f", child.moodAverage), icon: "face.smiling.fill", color: .purple)
                }
            }
            .padding()
        }
    }

    private func detailStat(_ label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Diary Tab

    private var diaryTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Today's Diary Entries")
                    .font(.headline)
                    .padding(.horizontal)

                // Sample diary entries for the selected child
                ForEach(sampleDiaryEntries, id: \.0) { entry in
                    HStack(spacing: 14) {
                        Image(systemName: entry.1)
                            .font(.title3)
                            .foregroundStyle(entry.3)
                            .frame(width: 36, height: 36)
                            .background(entry.3.opacity(0.15), in: Circle())

                        VStack(alignment: .leading, spacing: 3) {
                            Text(entry.0)
                                .font(.body.bold())
                            Text(entry.2)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(entry.4)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(14)
                    .glassBackgroundEffect()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    // Lightweight sample entries (title, icon, detail, color, time)
    private var sampleDiaryEntries: [(String, String, String, Color, String)] {
        [
            ("Lunch – \(child.name)", "fork.knife", "Ate most of their meal", .green, "12:15 PM"),
            ("Afternoon Nap", "bed.double.fill", "45 minutes", .blue, "1:00 PM"),
            ("Outdoor Play", "figure.walk", "Enjoyed sand pit activity", .orange, "3:30 PM"),
            ("Mood Check", "face.smiling.fill", "Happy and settled – \(child.moodEmoji)", .purple, "9:30 AM")
        ]
    }

    // MARK: - Health Tab

    private var healthTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if child.hasAllergies {
                    healthSection(
                        title: "Allergies",
                        icon: "exclamationmark.circle.fill",
                        color: .orange,
                        items: child.allergies
                    )
                }

                healthSection(
                    title: "Emergency Contact",
                    icon: "phone.fill",
                    color: .blue,
                    items: ["Parent / Guardian", "07700 900000"]
                )

                healthSection(
                    title: "Medical Notes",
                    icon: "cross.fill",
                    color: .red,
                    items: child.name == "Noah Brown"
                        ? ["Asthma – blue inhaler in office", "Use before outdoor play if wheezy"]
                        : ["No medical notes on record"]
                )
            }
            .padding()
        }
    }

    private func healthSection(title: String, icon: String, color: Color, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                        Text(item)
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
