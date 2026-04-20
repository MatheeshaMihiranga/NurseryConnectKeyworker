//
//  Child.swift
//  NurseryConnectKeyworker
//
//  SwiftData model representing a child enrolled in the nursery.
//  Only children assigned to the current keyworker should be displayed.
//

import Foundation
import SwiftData

@Model
class Child {
    @Attribute(.unique) var id: UUID
    var name: String
    var age: Int
    var room: String // "Baby Room", "Toddlers", "Pre-school"
    var allergies: [String] // e.g., ["Peanuts", "Dairy"]
    var dietaryRestrictions: [String] // e.g., ["Vegetarian", "Halal"]
    var medicalNotes: String // e.g., "Asthma - inhaler in office"
    var photoName: String // SF Symbol name for demo (e.g., "person.circle.fill")
    var keyworkerName: String // Key filter field - only show if matches current user
    var emergencyContact: String // Parent/guardian name
    var emergencyPhone: String // Contact number
    
    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        room: String,
        allergies: [String] = [],
        dietaryRestrictions: [String] = [],
        medicalNotes: String = "",
        photoName: String = "person.circle.fill",
        keyworkerName: String,
        emergencyContact: String,
        emergencyPhone: String
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.room = room
        self.allergies = allergies
        self.dietaryRestrictions = dietaryRestrictions
        self.medicalNotes = medicalNotes
        self.photoName = photoName
        self.keyworkerName = keyworkerName
        self.emergencyContact = emergencyContact
        self.emergencyPhone = emergencyPhone
    }
    
    // Computed property for display
    var displayAge: String {
        age == 1 ? "1 year" : "\(age) years"
    }
    
    var hasAllergies: Bool {
        !allergies.isEmpty
    }
    
    var hasDietaryRestrictions: Bool {
        !dietaryRestrictions.isEmpty
    }
    
    var hasMedicalNotes: Bool {
        !medicalNotes.isEmpty
    }
}
