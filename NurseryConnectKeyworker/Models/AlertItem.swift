//
//  AlertItem.swift
//  NurseryConnectKeyworker
//
//  SwiftData model for alerts and reminders.
//  Includes allergy alerts, overdue logs, pending incidents, etc.
//

import Foundation
import SwiftData

/// Type of alert for the keyworker
enum AlertType: String, Codable, CaseIterable {
    case allergy = "Allergy"
    case dietary = "Dietary Restriction"
    case medical = "Medical Note"
    case overdueDiary = "Overdue Diary Log"
    case pendingIncident = "Pending Incident"
    case pending = "Pending"
    case reminder = "Reminder"
    
    var icon: String {
        switch self {
        case .allergy: return "allergens.fill"
        case .dietary: return "fork.knife "
        case .medical:return "cross.case.fill"
        case .overdueDiary: return "clock.badge.exclamationmark.fill"
        case .pendingIncident: return "exclamationmark.triangle.fill"
        case .pending: return "exclamationmark.circle.fill"
        case .reminder: return "bell.fill"
        }
    }
}

/// Priority level for alert triaging
enum AlertPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    case critical = "Critical"
    
    var color: String {
        switch self {
        case .low: return "blue"
        case .medium: return "yellow"
        case .high: return "orange"
        case .urgent: return "red"
        case .critical: return "red"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .critical: return 5
        case .urgent: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

@Model
class AlertItem {
    @Attribute(.unique) var id: UUID
    var childId: UUID?
    var childName: String
    var alertTypeRaw: String // Store enum as String
    var priorityRaw: String // Store enum as String
    var title: String
    var message: String
    var isAcknowledged: Bool
    var createdAt: Date
    var acknowledgedAt: Date?
    
    init(
        id: UUID = UUID(),
        childId: UUID? = nil,
        childName: String,
        alertType: AlertType,
        priority: AlertPriority,
        title: String,
        message: String,
        isAcknowledged: Bool = false,
        createdAt: Date = Date(),
        acknowledgedAt: Date? = nil
    ) {
        self.id = id
        self.childId = childId
        self.childName = childName
        self.alertTypeRaw = alertType.rawValue
        self.priorityRaw = priority.rawValue
        self.title = title
        self.message = message
        self.isAcknowledged = isAcknowledged
        self.createdAt = createdAt
        self.acknowledgedAt = acknowledgedAt
    }
    
    // Convenience initializer for DataService compatibility
    convenience init(
        id: UUID = UUID(),
        type: AlertType,
        priority: AlertPriority,
        title: String,
        message: String,
        relatedChildId: UUID? = nil,
        relatedChildName: String? = nil,
        timestamp: Date = Date(),
        isAcknowledged: Bool = false,
        acknowledgedAt: Date? = nil
    ) {
        self.init(
            id: id,
            childId: relatedChildId,
            childName: relatedChildName ?? "",
            alertType: type,
            priority: priority,
            title: title,
            message: message,
            isAcknowledged: isAcknowledged,
            createdAt: timestamp,
            acknowledgedAt: acknowledgedAt
        )
    }
    
    // Computed properties for enum access
    var alertType: AlertType {
        get { AlertType(rawValue: alertTypeRaw) ?? .reminder }
        set { alertTypeRaw = newValue.rawValue }
    }
    
    var priority: AlertPriority {
        get { AlertPriority(rawValue: priorityRaw) ?? .low }
        set { priorityRaw = newValue.rawValue }
    }
    
    // Alias for compatibility
    var timestamp: Date {
        get { createdAt }
        set { createdAt = newValue }
    }
    
    var relatedChildName: String? {
        childId != nil && !childName.isEmpty ? childName : nil
    }
    
    // Formatted timestamps
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    // Badge indicator
    var showBadge: Bool {
        !isAcknowledged
    }
    
    // Methods
    func acknowledgeAlert() {
        isAcknowledged = true
        acknowledgedAt = Date()
    }
}

// Extension for sorting
extension AlertItem {
    static func sortByPriority(_ a: AlertItem, _ b: AlertItem) -> Bool {
        a.priority.sortOrder > b.priority.sortOrder
    }
    
    static func sortByTime(_ a: AlertItem, _ b: AlertItem) -> Bool {
        a.createdAt > b.createdAt
    }
}
