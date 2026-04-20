//
//  ChildCard.swift
//  NurseryConnectKeyworker
//
//  Reusable component displaying child information with quick action buttons.
//  Fully accessible with VoiceOver support.
//

import SwiftUI

struct ChildCard: View {
    let child: Child
    let onLogMeal: () -> Void
    let onLogNap: () -> Void
    let onLogMood: () -> Void
    let onReportIncident: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with photo and info
            HStack(spacing: 12) {
                Image(systemName: child.photoName)
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(child.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("\(child.displayAge) • \(child.room)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Allergy badges
                    if child.hasAllergies {
                        HStack(spacing: 4) {
                            ForEach(child.allergies, id: \.self) { allergy in
                                Badge(text: allergy, color: .red, icon: "exclamationmark.triangle.fill")
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    // Dietary restriction badges
                    if child.hasDietaryRestrictions {
                        HStack(spacing: 4) {
                            ForEach(child.dietaryRestrictions, id: \.self) { restriction in
                                Badge(text: restriction, color: .orange, icon: "fork.knife")
                            }
                        }
                        .padding(.top, 2)
                    }
                    
                    // Medical note badge
                    if child.hasMedicalNotes {
                        Badge(text: "Medical Note", color: .blue, icon: "cross.case.fill")
                            .padding(.top, 2)
                    }
                }
                
                Spacer()
            }
            
            Divider()
            
            // Quick action buttons
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "fork.knife",
                    label: "Log Meal",
                    color: .green,
                    action: onLogMeal
                )
                
                QuickActionButton(
                    icon: "bed.double.fill",
                    label: "Log Nap",
                    color: .blue,
                    action: onLogNap
                )
                
                QuickActionButton(
                    icon: "face.smiling.fill",
                    label: "Log Mood",
                    color: .purple,
                    action: onLogMood
                )
                
                QuickActionButton(
                    icon: "exclamationmark.triangle.fill",
                    label: "Incident",
                    color: .red,
                    action: onReportIncident
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }
    
    private var accessibilityText: String {
        var text = "Child card for \(child.name), age \(child.age), \(child.room) room"
        if child.hasAllergies {
            text += ", allergies: \(child.allergies.joined(separator: ", "))"
        }
        if child.hasDietaryRestrictions {
            text += ", dietary restrictions: \(child.dietaryRestrictions.joined(separator: ", "))"
        }
        if child.hasMedicalNotes {
            text += ", has medical notes"
        }
        return text
    }
}

// Helper badge component
struct Badge: View {
    let text: String
    let color: Color
    let icon: String?
    
    init(text: String, color: Color, icon: String? = nil) {
        self.text = text
        self.color = color
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundStyle(color)
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
    }
}
