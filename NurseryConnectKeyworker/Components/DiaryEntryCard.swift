//
//  DiaryEntryCard.swift
//  NurseryConnectKeyworker
//
//  Reusable card component for displaying diary entries.
//  Color-coded by entry type with accessible labels.
//

import SwiftUI

struct DiaryEntryCard: View {
    let entry: DiaryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack(spacing: 12) {
                Image(systemName: entry.entryType.icon)
                    .font(.title3)
                    .foregroundStyle(entryColor)
                    .frame(width: 32)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(entry.childName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(entry.formattedTime)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Text(entry.relativeTime)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            // Description
            Text(entry.description)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(3)
            
            // Type-specific info
            if let portionSize = entry.portionSize {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Portion: \(portionSize)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let durationText = entry.durationText {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.blue)
                    Text("Duration: \(durationText)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let moodEmoji = entry.moodEmoji {
                HStack {
                    Text(moodEmoji)
                        .font(.title3)
                    Text("Mood rating: \(entry.moodRating ?? 0)/5")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Footer
            HStack {
                Image(systemName: "person.fill")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(entry.staffName)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                Text(entry.entryType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(entryColor)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(entryColor.opacity(0.3), lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }
    
    private var entryColor: Color {
        switch entry.entryType {
        case .meal: return .green
        case .nap: return .blue
        case .activity: return .orange
        case .mood: return .purple
        case .nappy: return .brown
        }
    }
    
    private var accessibilityText: String {
        var text = "\(entry.entryType.rawValue) entry for \(entry.childName). \(entry.title). \(entry.description). "
        if let portionSize = entry.portionSize {
            text += "Portion: \(portionSize). "
        }
        if let durationText = entry.durationText {
            text += "Duration: \(durationText). "
        }
        if let rating = entry.moodRating {
            text += "Mood rating: \(rating) out of 5. "
        }
        text += "Logged by \(entry.staffName) at \(entry.formattedTime)."
        return text
    }
}
