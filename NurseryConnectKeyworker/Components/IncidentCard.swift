//
//  IncidentCard.swift
//  NurseryConnectKeyworker
//
//  Reusable card component for displaying incident reports.
//  Color-coded by severity with status badges.
//

import SwiftUI

struct IncidentCard: View {
    let incident: IncidentReport
    let onMarkParentNotified: () -> Void
    let onMarkManagerReviewed: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Severity indicator header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: incident.category.icon)
                        .font(.title3)
                        .foregroundStyle(severityColor)
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(incident.category.rawValue)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text(incident.childName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Severity badge
                Text(incident.severity.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(severityColor)
                    .cornerRadius(8)
            }
            
            // Timestamp
            Text(incident.formattedTimestamp)
                .font(.caption)
                .foregroundStyle(.tertiary)
            
            // Description preview
            Text(incident.description)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(3)
            
            Divider()
            
            // Status badges
            HStack(spacing: 8) {
                StatusBadge(
                    text: incident.parentNotified ? "Parent Notified ✓" : "Parent Pending",
                    isComplete: incident.parentNotified,
                    action: incident.parentNotified ? nil : onMarkParentNotified
                )
                
                StatusBadge(
                    text: incident.managerReviewed ? "Manager Reviewed ✓" : "Manager Pending",
                    isComplete: incident.managerReviewed,
                    action: incident.managerReviewed ? nil : onMarkManagerReviewed
                )
            }
            
            // Reporter
            HStack {
                Image(systemName: "person.fill")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text("Reported by \(incident.reportedByStaff)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(severityColor.opacity(0.4), lineWidth: 3)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint(accessibilityHint)
    }
    
    private var severityColor: Color {
        switch incident.severity {
        case .minor: return .yellow
        case .moderate: return .orange
        case .major: return .red
        case .serious: return .red
        }
    }
    
    private var accessibilityText: String {
        """
        \(incident.severity.rawValue) \(incident.category.rawValue) incident for \(incident.childName). \
        \(incident.description). \
        \(incident.statusBadges.joined(separator: ", ")). \
        Reported by \(incident.reportedByStaff) at \(incident.formattedTimestamp).
        """
    }
    
    private var accessibilityHint: String {
        var hints: [String] = []
        if !incident.parentNotified {
            hints.append("Swipe up to mark parent as notified")
        }
        if !incident.managerReviewed {
            hints.append("Swipe down to mark manager review complete")
        }
        return hints.isEmpty ? "" : hints.joined(separator: ". ")
    }
}

struct StatusBadge: View {
    let text: String
    let isComplete: Bool
    let action: (() -> Void)?
    
    var body: some View {
        if let action = action {
            Button(action: action) {
                badgeContent
            }
        } else {
            badgeContent
        }
    }
    
    private var badgeContent: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(isComplete ? .green : .orange)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background((isComplete ? Color.green : Color.orange).opacity(0.2))
            .cornerRadius(8)
    }
}
