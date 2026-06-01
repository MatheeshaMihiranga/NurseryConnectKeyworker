//
//  AppModel.swift
//  NurseryConnectVision
//
//  Shared app state for the visionOS app.
//  Manages immersive space lifecycle and selected child context.
//

import SwiftUI

@Observable
class AppModel {
    var isImmersiveSpaceOpen = false
    var selectedChild: VisionChild? = nil

    // Sample children used across the visionOS app
    // In a full implementation these would be fetched from shared SwiftData store
    let children: [VisionChild] = [
        VisionChild(name: "Oliver Taylor",   age: 3, room: "Toddlers",
                    allergies: ["Peanuts", "Tree nuts"],
                    diaryCount: 4, moodAverage: 4.2, pendingIncidents: 0,
                    photoSymbol: "figure.child"),
        VisionChild(name: "Emma Wilson",     age: 2, room: "Toddlers",
                    allergies: [],
                    diaryCount: 3, moodAverage: 4.8, pendingIncidents: 0,
                    photoSymbol: "figure.child"),
        VisionChild(name: "Noah Brown",      age: 3, room: "Toddlers",
                    allergies: [],
                    diaryCount: 2, moodAverage: 3.5, pendingIncidents: 2,
                    photoSymbol: "figure.child"),
        VisionChild(name: "Ava Davis",       age: 2, room: "Toddlers",
                    allergies: [],
                    diaryCount: 3, moodAverage: 4.5, pendingIncidents: 0,
                    photoSymbol: "figure.child")
    ]

    var totalPendingIncidents: Int {
        children.map(\.pendingIncidents).reduce(0, +)
    }

    var averageMoodToday: Double {
        let all = children.map(\.moodAverage)
        return all.isEmpty ? 0 : all.reduce(0, +) / Double(all.count)
    }
}

// MARK: - Lightweight model for visionOS (avoids SwiftData dependency in separate target)

struct VisionChild: Identifiable {
    let id = UUID()
    let name: String
    let age: Int
    let room: String
    let allergies: [String]
    let diaryCount: Int
    let moodAverage: Double
    let pendingIncidents: Int
    let photoSymbol: String

    var displayAge: String { age == 1 ? "1 year" : "\(age) years" }
    var hasAllergies: Bool { !allergies.isEmpty }
    var moodEmoji: String {
        switch moodAverage {
        case 4.5...: return "😄"
        case 3.5..<4.5: return "🙂"
        case 2.5..<3.5: return "😐"
        case 1.5..<2.5: return "🙁"
        default: return "😢"
        }
    }
}
