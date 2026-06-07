//
//  SpatialDashboardView.swift
//  NurseryConnectVision
//
//  Main window view for the visionOS app.
//  Shows an at-a-glance keyworker dashboard with:
//  - Daily summary stats in a horizontal panel
//  - Spatial child cards in a scrollable HStack
//  - Button to open the immersive child panels space
//
//  Uses visionOS glass materials and ornaments for a spatial-native feel.
//

import SwiftUI
import RealityKit

struct SpatialDashboardView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var selectedChild: VisionChild? = nil
    @State private var showChildDetail = false
    @State private var showAddChild = false
    @State private var showManageChildren = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    summaryStatsRow
                    childrenSection
                    activityFeedSection
                }
                .padding(28)
            }
            .navigationTitle("Keyworker Dashboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    immersiveToggleButton
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        showAddChild = true
                    } label: {
                        Label("Add Child", systemImage: "person.badge.plus")
                    }
                    .accessibilityLabel("Add a new child")
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        showManageChildren = true
                    } label: {
                        Label("Manage Children", systemImage: "person.3.sequence.fill")
                    }
                    .accessibilityLabel("Manage children list")
                }
            }
        }
        .sheet(item: $selectedChild) { child in
            SpatialChildDetailView(child: child)
        }
        .sheet(isPresented: $showAddChild) {
            AddEditChildView(editingChild: nil)
                .environment(appModel)
        }
        .sheet(isPresented: $showManageChildren) {
            ChildrenManagementView()
                .environment(appModel)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 16) {
            Image(systemName: "sun.max.fill")
                .font(.largeTitle)
                .foregroundStyle(.yellow)
                .symbolEffect(.pulse)

            VStack(alignment: .leading, spacing: 4) {
                Text("Good Morning, Sarah")
                    .font(.largeTitle.bold())
                Text("Today · \(formattedDate)")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Alert badge ornament
            if appModel.totalPendingIncidents > 0 {
                Label("\(appModel.totalPendingIncidents) pending", systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.orange, in: Capsule())
            }
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: Date())
    }

    // MARK: - Summary Stats

    private var summaryStatsRow: some View {
        HStack(spacing: 16) {
            spatialStatCard(
                value: "\(appModel.children.count)",
                label: "Assigned Children",
                icon: "person.3.fill",
                color: .blue
            )
            spatialStatCard(
                value: "\(appModel.children.map(\.diaryCount).reduce(0, +))",
                label: "Diary Entries Today",
                icon: "book.fill",
                color: .green
            )
            spatialStatCard(
                value: String(format: "%.1f", appModel.averageMoodToday),
                label: "Avg Mood / 5",
                icon: "face.smiling.fill",
                color: .purple
            )
            spatialStatCard(
                value: "\(appModel.totalPendingIncidents)",
                label: "Pending Incidents",
                icon: "exclamationmark.triangle.fill",
                color: appModel.totalPendingIncidents > 0 ? .orange : .green
            )
        }
    }

    private func spatialStatCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            Text(value)
                .font(.title.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Children Section

    private var childrenSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("My Children")
                    .font(.title2.bold())
                Spacer()
                Button {
                    showAddChild = true
                } label: {
                    Label("Add Child", systemImage: "person.badge.plus")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .accessibilityLabel("Add a new child")
            }

            if appModel.children.isEmpty {
                ContentUnavailableView(
                    "No Children Added",
                    systemImage: "person.3",
                    description: Text("Tap "Add Child" to register a child to your keyworker group.")
                )
                .frame(minHeight: 140)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(appModel.children) { child in
                            SpatialChildCard(child: child)
                                .onTapGesture {
                                    selectedChild = child
                                }
                                .hoverEffect(.highlight)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Activity Feed

    private var activityFeedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Activity")
                .font(.title2.bold())

            VStack(spacing: 10) {
                activityRow(icon: "fork.knife", color: .green,
                            title: "Oliver ate all of his lunch", time: "12:15 PM")
                activityRow(icon: "bed.double.fill", color: .blue,
                            title: "Emma is napping – 45 mins", time: "1:00 PM")
                activityRow(icon: "exclamationmark.triangle.fill", color: .orange,
                            title: "Noah – incident report filed", time: "11:30 AM")
                activityRow(icon: "face.smiling.fill", color: .purple,
                            title: "Ava mood: Happy 😄", time: "10:00 AM")
            }
            .padding(16)
            .glassBackgroundEffect()
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func activityRow(icon: String, color: Color, title: String, time: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 28)

            Text(title)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Immersive Space Button

    private var immersiveToggleButton: some View {
        Button {
            Task {
                if appModel.isImmersiveSpaceOpen {
                    await dismissImmersiveSpace()
                    appModel.isImmersiveSpaceOpen = false
                } else {
                    await openImmersiveSpace(id: "immersive")
                    appModel.isImmersiveSpaceOpen = true
                }
            }
        } label: {
            Label(
                appModel.isImmersiveSpaceOpen ? "Exit Spatial View" : "Open Spatial View",
                systemImage: appModel.isImmersiveSpaceOpen
                    ? "arrow.down.right.and.arrow.up.left"
                    : "visionpro"
            )
        }
        .tint(appModel.isImmersiveSpaceOpen ? .orange : .blue)
        .accessibilityLabel(appModel.isImmersiveSpaceOpen
            ? "Exit immersive spatial view"
            : "Open immersive spatial child panels view")
    }
}
