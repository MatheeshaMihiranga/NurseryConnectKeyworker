//
//  DiaryEntry.swift
//  NurseryConnectKeyworker
//
//  SwiftData model for daily diary entries.
//  Supports meal, nap, activity, mood, and nappy/toilet logging.
//

import Foundation
import SwiftData

/// Type of diary entry for daily child monitoring
enum DiaryEntryType: String, Codable, CaseIterable {
    case meal = "Meal"
    case nap = "Nap"
    case activity = "Activity"
    case mood = "Mood/Wellbeing"
    case nappy = "Nappy/Toilet"
    
    var icon: String {
        switch self {
        case .meal: return "fork.knife"
        case .nap: return "bed.double.fill"
        case .activity: return "figure.walk"
        case .mood: return "face.smiling.fill"
        case .nappy: return "toilet.fill"
        }
    }
    
    var color: String {
        switch self {
        case .meal: return "green"
        case .nap: return "blue"
        case .activity: return "orange"
        case .mood: return "purple"
        case .nappy: return "brown"
        }
    }
}

@Model
class DiaryEntry {
    @Attribute(.unique) var id: UUID
    var childId: UUID
    var childName: String
    var entryTypeRaw: String // Store enum as String for SwiftData compatibility
    var timestamp: Date
    var title: String
    // Avoid reserved name "description" for @Model stored properties
    var entryDescription: String
    var notes: String
    var staffName: String
    
    // Meal-specific fields
    var portionSize: String? // "All", "Most", "Some", "Little", "None"
    
    // Nap-specific fields
    var duration: Int? // Minutes
    
    // Mood-specific fields
    var moodRating: Int? // 1-5 (1=very upset, 5=very happy)
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        childName: String,
        entryType: DiaryEntryType,
        timestamp: Date = Date(),
        title: String,
        description: String,
        notes: String = "",
        staffName: String,
        portionSize: String? = nil,
        duration: Int? = nil,
        moodRating: Int? = nil
    ) {
        self.id = id
        self.childId = childId
        self.childName = childName
        self.entryTypeRaw = entryType.rawValue
        self.timestamp = timestamp
        self.title = title
        self.entryDescription = description
        self.notes = notes
        self.staffName = staffName
        self.portionSize = portionSize
        self.duration = duration
        self.moodRating = moodRating
    }
    
    // Convenience initializer for DataService compatibility
    convenience init(
        id: UUID = UUID(),
        childId: UUID,
        childName: String,
        type: DiaryEntryType,
        timestamp: Date = Date(),
        title: String,
        description: String,
        notes: String? = nil,
        keyworkerName: String,
        portionSize: String? = nil,
        duration: Int? = nil,
        moodRating: Int? = nil
    ) {
        self.init(
            id: id,
            childId: childId,
            childName: childName,
            entryType: type,
            timestamp: timestamp,
            title: title,
            description: description,
            notes: notes ?? "",
            staffName: keyworkerName,
            portionSize: portionSize,
            duration: duration,
            moodRating: moodRating
        )
    }
    
    // Computed property to access enum type
    var entryType: DiaryEntryType {
        get { DiaryEntryType(rawValue: entryTypeRaw) ?? .activity }
        set { entryTypeRaw = newValue.rawValue }
    }
    
    // Provide a computed alias named `description` for compatibility
    var description: String {
        get { entryDescription }
        set { entryDescription = newValue }
    }
    
    // Formatted timestamp for display
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: timestamp)
    }
    
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var durationText: String? {
        guard let duration = duration else { return nil }
        if duration < 60 {
            return "\(duration) mins"
        } else {
            let hours = duration / 60
            let mins = duration % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
    }
    
    var moodEmoji: String? {
        guard let rating = moodRating else { return nil }
        switch rating {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "😊"
        case 5: return "😄"
        default: return "😐"
        }
    }
    
    // Check if entry is overdue (older than 4 hours for meals, 8 hours for others)
    var isOverdue: Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch entryType {
            case .meal:
                // Meals should be logged within 4 hours
                guard let hoursSince = calendar.dateComponents([.hour], from: timestamp, to: now).hour else {
                    return false
                }
                return hoursSince > 4
            case .nappy:
                // Nappy changes should be logged within 3 hours
                guard let hoursSince = calendar.dateComponents([.hour], from: timestamp, to: now).hour else {
                    return false
                }
                return hoursSince > 3
            default:
                // Other entries should be logged within 8 hours
                guard let hoursSince = calendar.dateComponents([.hour], from: timestamp, to: now).hour else {
                    return false
                }
                return hoursSince > 8
        }
    }
}
