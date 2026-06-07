//
//  SpatialChildCard.swift
//  NurseryConnectVision
//
//  A glass-material card displaying one assigned child in the visionOS dashboard.
//  Uses hover effects and depth cues to give the card a spatial feel.
//

import SwiftUI

struct SpatialChildCard: View {
    let child: VisionChild
    @Environment(AppModel.self) private var appModel

    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Avatar + name row
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(roomColor.opacity(0.2))
                        .frame(width: 56, height: 56)
                    Image(systemName: child.photoSymbol)
                        .font(.title2)
                        .foregroundStyle(roomColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(child.name)
                        .font(.headline.bold())
                    Text(child.room)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // Stats row
            HStack(spacing: 16) {
                childStat(value: child.displayAge, icon: "birthday.cake.fill", color: .blue)
                childStat(value: "\(child.diaryCount) entries", icon: "book.fill", color: .green)
                childStat(value: child.moodEmoji, icon: nil, color: .purple)
            }

            // Allergy badge
            if child.hasAllergies {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                    Text("Allergies: \(child.allergies.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.orange.opacity(0.12), in: Capsule())
            }

            // Pending incident badge
            if child.pendingIncidents > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text("\(child.pendingIncidents) pending incident\(child.pendingIncidents == 1 ? "" : "s")")
                        .font(.caption.bold())
                        .foregroundStyle(.red)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.red.opacity(0.12), in: Capsule())
            }
        }
        .padding(20)
        .frame(width: 260)
        .glassBackgroundEffect()
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        // Context menu: Edit / Delete
        .contextMenu {
            Button {
                showEditSheet = true
            } label: {
                Label("Edit Child", systemImage: "pencil")
            }

            Divider()

            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Remove Child", systemImage: "person.badge.minus")
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddEditChildView(editingChild: child)
                .environment(appModel)
        }
        .confirmationDialog(
            "Remove \(child.name)?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                appModel.deleteChild(child)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove \(child.name) from your assigned children list.")
        }
    }

    // MARK: - Helpers

    private func childStat(value: String, icon: String?, color: Color) -> some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var roomColor: Color {
        switch child.room {
        case "Baby Room":  return .pink
        case "Toddlers":   return .blue
        case "Pre-school": return .green
        default:           return .gray
        }
    }

    private var accessibilityDescription: String {
        var desc = "\(child.name), age \(child.displayAge), \(child.room). "
        desc += "\(child.diaryCount) diary entries today. Mood: \(child.moodEmoji). "
        if child.hasAllergies { desc += "Has allergies: \(child.allergies.joined(separator: ", ")). " }
        if child.pendingIncidents > 0 { desc += "\(child.pendingIncidents) pending incident reports." }
        return desc
    }
}
