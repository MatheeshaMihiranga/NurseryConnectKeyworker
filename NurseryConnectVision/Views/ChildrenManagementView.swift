//
//  ChildrenManagementView.swift
//  NurseryConnectVision
//
//  A full management sheet listing all children with the ability to:
//  - Add a new child (+ button)
//  - Edit any child (tap row)
//  - Delete any child (swipe to delete or Edit mode)
//  - View child count summary
//

import SwiftUI

struct ChildrenManagementView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    @State private var showAddChild = false
    @State private var childToEdit: VisionChild? = nil
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            Group {
                if appModel.children.isEmpty {
                    ContentUnavailableView(
                        "No Children",
                        systemImage: "person.3",
                        description: Text("Tap + to add your first assigned child.")
                    )
                } else {
                    List {
                        ForEach(appModel.children) { child in
                            childRow(child)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        appModel.deleteChild(child)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        childToEdit = child
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                        .onDelete { offsets in
                            appModel.deleteChildren(at: offsets)
                        }
                    }
                    .environment(\.editMode, $editMode)
                }
            }
            .navigationTitle("Manage Children (\(appModel.children.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddChild = true
                    } label: {
                        Label("Add Child", systemImage: "person.badge.plus")
                    }
                    .accessibilityLabel("Add a new child")
                }
                ToolbarItem(placement: .secondaryAction) {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showAddChild) {
            AddEditChildView(editingChild: nil)
                .environment(appModel)
        }
        .sheet(item: $childToEdit) { child in
            AddEditChildView(editingChild: child)
                .environment(appModel)
        }
        .frame(minWidth: 500, minHeight: 480)
    }

    // MARK: - Child Row

    private func childRow(_ child: VisionChild) -> some View {
        Button {
            childToEdit = child
        } label: {
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(roomColor(for: child).opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: "figure.child")
                        .font(.headline)
                        .foregroundStyle(roomColor(for: child))
                }

                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(child.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("\(child.displayAge) · \(child.room)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 6) {
                        if child.hasAllergies {
                            Label("Allergies", systemImage: "exclamationmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                        if child.pendingIncidents > 0 {
                            Label("\(child.pendingIncidents) pending",
                                  systemImage: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                }

                Spacer()

                // Mood indicator
                Text(child.moodEmoji)
                    .font(.title3)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(child.name), \(child.displayAge), \(child.room). Tap to edit.")
    }

    private func roomColor(for child: VisionChild) -> Color {
        switch child.room {
        case "Baby Room":  return .pink
        case "Toddlers":   return .blue
        case "Pre-school": return .green
        default:           return .gray
        }
    }
}

#Preview {
    ChildrenManagementView()
        .environment(AppModel())
}
