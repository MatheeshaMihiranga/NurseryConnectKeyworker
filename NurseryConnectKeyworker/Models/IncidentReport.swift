//
//  IncidentReport.swift
//  NurseryConnectKeyworker
//
//  SwiftData model for incident reporting (safeguarding compliance).
//  Includes all required fields for UK childcare regulations.
//

import Foundation
import SwiftData

/// Category of incident for classification
enum IncidentCategory: String, Codable, CaseIterable {
    case injury = "Injury"
    case illness = "Illness"
    case behavior = "Behavior"
    case accident = "Accident"
    case allergic = "Allergic Reaction"
    case safeguarding = "Safeguarding Concern"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .injury: return "bandage.fill"
        case .illness: return "thermometer"
        case .behavior: return "person.2.fill"
        case .accident: return "exclamationmark.triangle.fill"
        case .allergic: return "allergens.fill"
        case .safeguarding: return "shield.lefthalf.filled"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

/// Severity level for triaging incidents
enum IncidentSeverity: String, Codable, CaseIterable {
    case minor = "Minor"
    case moderate = "Moderate"
    case major = "Major"
    case serious = "Serious"
    
    var color: String {
        switch self {
        case .minor: return "yellow"
        case .moderate: return "orange"
        case .major: return "red"
        case .serious: return "red"
        }
    }
}

@Model
class IncidentReport {
    @Attribute(.unique) var id: UUID
    var childId: UUID
    var childName: String
    // Store enums as raw strings for SwiftData
    var categoryRaw: String
    var severityRaw: String
    var timestamp: Date
    var location: String // e.g., "Main playground", "Toddler room"
    // Avoid reserved name "description" for @Model stored properties
    var incidentDescription: String // Full description of incident
    var immediateActionTaken: String // What was done immediately
    var witnessNames: String // Staff/child witnesses (comma-separated)
    var parentNotified: Bool
    var parentNotificationTime: Date?
    var managerReviewed: Bool
    var managerReviewTime: Date?
    var reportedByStaff: String // Keyworker who created report
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        childName: String,
        category: IncidentCategory,
        severity: IncidentSeverity,
        timestamp: Date = Date(),
        location: String,
        description: String,
        immediateActionTaken: String,
        witnessNames: String = "",
        parentNotified: Bool = false,
        parentNotificationTime: Date? = nil,
        managerReviewed: Bool = false,
        managerReviewTime: Date? = nil,
        reportedByStaff: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.childId = childId
        self.childName = childName
        self.categoryRaw = category.rawValue
        self.severityRaw = severity.rawValue
        self.timestamp = timestamp
        self.location = location
        self.incidentDescription = description
        self.immediateActionTaken = immediateActionTaken
        self.witnessNames = witnessNames
        self.parentNotified = parentNotified
        self.parentNotificationTime = parentNotificationTime
        self.managerReviewed = managerReviewed
        self.managerReviewTime = managerReviewTime
        self.reportedByStaff = reportedByStaff
        self.createdAt = createdAt
    }
    
    // Convenience initializer for DataService compatibility
    convenience init(
        id: UUID = UUID(),
        childId: UUID,
        childName: String,
        category: IncidentCategory,
        severity: IncidentSeverity,
        timestamp: Date = Date(),
        location: String,
        description: String,
        immediateAction: String,
        witnesses: [String],
        parentNotified: Bool = false,
        parentNotificationTime: Date? = nil,
        managerReviewed: Bool = false,
        managerReviewTime: Date? = nil,
        reportedBy: String,
        createdAt: Date = Date()
    ) {
        self.init(
            id: id,
            childId: childId,
            childName: childName,
            category: category,
            severity: severity,
            timestamp: timestamp,
            location: location,
            description: description,
            immediateActionTaken: immediateAction,
            witnessNames: witnesses.joined(separator: ", "),
            parentNotified: parentNotified,
            parentNotificationTime: parentNotificationTime,
            managerReviewed: managerReviewed,
            managerReviewTime: managerReviewTime,
            reportedByStaff: reportedBy,
            createdAt: createdAt
        )
    }
    
    // Computed properties for enum access
    var category: IncidentCategory {
        get { IncidentCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
    
    var severity: IncidentSeverity {
        get { IncidentSeverity(rawValue: severityRaw) ?? .minor }
        set { severityRaw = newValue.rawValue }
    }
    
    // Provide a computed alias named `description` for compatibility
    var description: String {
        get { incidentDescription }
        set { incidentDescription = newValue }
    }
    
    // Status checks
    var isPending: Bool { !parentNotified || !managerReviewed }
    
    var isComplete: Bool { parentNotified && managerReviewed }
    
    var requiresUrgentAction: Bool { severity == .serious || severity == .major }
    
    // Aliases for DataService compatibility
    var reviewDate: Date? {
        get { managerReviewTime }
        set { managerReviewTime = newValue }
    }
    
    var notificationDate: Date? {
        get { parentNotificationTime }
        set { parentNotificationTime = newValue }
    }
    
    // Formatted timestamps
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    // Status badge text
    var statusBadges: [String] {
        var badges: [String] = []
        if parentNotified {
            badges.append("Parent Notified ✓")
        } else {
            badges.append("Parent Pending")
        }
        if managerReviewed {
            badges.append("Manager Reviewed ✓")
        } else {
            badges.append("Manager Pending")
        }
        return badges
    }
}
