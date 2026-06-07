//
//  AppModel.swift
//  NurseryConnectVision
//
//  Shared app state for the visionOS app.
//  Manages immersive space lifecycle, selected child context,
//  and full CRUD for the VisionChild list (persisted via UserDefaults).
//

import SwiftUI

// MARK: - AppModel

@Observable
class AppModel {

    var isImmersiveSpaceOpen = false
    var selectedChild: VisionChild? = nil
    var children: [VisionChild] = []

    // MARK: - Init

    init() {
        children = ChildStore.load()
        if children.isEmpty {
            // Seed sample data on first launch
            children = Self.sampleChildren
            ChildStore.save(children)
        }
    }

    // MARK: - Computed

    var totalPendingIncidents: Int {
        children.map(\.pendingIncidents).reduce(0, +)
    }

    var averageMoodToday: Double {
        guard !children.isEmpty else { return 0 }
        return children.map(\.moodAverage).reduce(0, +) / Double(children.count)
    }

    // MARK: - CRUD

    func addChild(_ child: VisionChild) {
        children.append(child)
        ChildStore.save(children)
    }

    func updateChild(_ updated: VisionChild) {
        guard let idx = children.firstIndex(where: { $0.id == updated.id }) else { return }
        children[idx] = updated
        ChildStore.save(children)
    }

    func deleteChild(_ child: VisionChild) {
        children.removeAll { $0.id == child.id }
        ChildStore.save(children)
    }

    func deleteChildren(at offsets: IndexSet) {
        children.remove(atOffsets: offsets)
        ChildStore.save(children)
    }

    // MARK: - Sample seed data

    private static let sampleChildren: [VisionChild] = [
        VisionChild(name: "Oliver Taylor",   age: 3, room: "Toddlers",
                    allergies: ["Peanuts", "Tree nuts"],
                    medicalNotes: "", emergencyContact: "James Taylor",
                    emergencyPhone: "07700 900123",
                    diaryCount: 4, moodAverage: 4.2, pendingIncidents: 0),
        VisionChild(name: "Emma Wilson",     age: 2, room: "Toddlers",
                    allergies: [], dietaryRestrictions: ["Dairy free"],
                    medicalNotes: "", emergencyContact: "Sophie Wilson",
                    emergencyPhone: "07700 900456",
                    diaryCount: 3, moodAverage: 4.8, pendingIncidents: 0),
        VisionChild(name: "Noah Brown",      age: 3, room: "Toddlers",
                    allergies: [],
                    medicalNotes: "Asthma â€“ blue inhaler in office",
                    emergencyContact: "Rachel Brown", emergencyPhone: "07700 900789",
                    diaryCount: 2, moodAverage: 3.5, pendingIncidents: 2),
        VisionChild(name: "Ava Davis",       age: 2, room: "Toddlers",
                    allergies: [],
                    medicalNotes: "", emergencyContact: "Michael Davis",
                    emergencyPhone: "07700 900321",
                    diaryCount: 3, moodAverage: 4.5, pendingIncidents: 0)
    ]
}

// MARK: - VisionChild Model

struct VisionChild: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var age: Int
    var room: String
    var allergies: [String]
    var dietaryRestrictions: [String]
    var medicalNotes: String
    var emergencyContact: String
    var emergencyPhone: String
    var diaryCount: Int
    var moodAverage: Double          // 1.0 â€“ 5.0
    var pendingIncidents: Int

    // Convenience initialisers with sensible defaults
    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        room: String = "Toddlers",
        allergies: [String] = [],
        dietaryRestrictions: [String] = [],
        medicalNotes: String = "",
        emergencyContact: String = "",
        emergencyPhone: String = "",
        diaryCount: Int = 0,
        moodAverage: Double = 4.0,
        pendingIncidents: Int = 0
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.room = room
        self.allergies = allergies
        self.dietaryRestrictions = dietaryRestrictions
        self.medicalNotes = medicalNotes
        self.emergencyContact = emergencyContact
        self.emergencyPhone = emergencyPhone
        self.diaryCount = diaryCount
        self.moodAverage = moodAverage
        self.pendingIncidents = pendingIncidents
    }

    // MARK: - Computed helpers

    var displayAge: String { age == 1 ? "1 year" : "\(age) years" }
    var hasAllergies: Bool { !allergies.isEmpty }
    var hasDietaryRestrictions: Bool { !dietaryRestrictions.isEmpty }
    var hasMedicalNotes: Bool { !medicalNotes.isEmpty }
    var photoSymbol: String { "figure.child" }

    var moodEmoji: String {
        switch moodAverage {
        case 4.5...: return "ðŸ˜„"
        case 3.5..<4.5: return "ðŸ™‚"
        case 2.5..<3.5: return "ðŸ˜"
        case 1.5..<2.5: return "ðŸ™"
        default: return "ðŸ˜¢"
        }
    }

    static let rooms = ["Baby Room", "Toddlers", "Pre-school"]
}

// MARK: - UserDefaults persistence

enum ChildStore {
    private static let key = "nurseryconnect_vision_children"

    static func load() -> [VisionChild] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([VisionChild].self, from: data)
        else { return [] }
        return decoded
    }

    static func save(_ children: [VisionChild]) {
        if let data = try? JSONEncoder().encode(children) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
