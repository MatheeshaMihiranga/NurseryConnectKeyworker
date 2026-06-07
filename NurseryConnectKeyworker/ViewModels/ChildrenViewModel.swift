//
//  ChildrenViewModel.swift
//  NurseryConnectKeyworker
//
//  ViewModel for My Children screen.
//  Manages list of assigned children and selection logic.
//

import Foundation
import SwiftUI

@Observable
class ChildrenViewModel {
    var assignedChildren: [Child] = []
    var selectedChild: Child?
    var searchText: String = ""
    
    private let dataService = DataService.shared
    
    // MARK: - Initialization
    
    init() {
        loadChildren()
    }
    
    // MARK: - Data Loading
    
    func loadChildren() {
        assignedChildren = dataService.getAssignedChildren()
    }
    
    func refreshChildren() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            loadChildren()
        }
    }
    
    // MARK: - Selection
    
    func selectChild(_ child: Child) {
        selectedChild = child
    }
    
    func clearSelection() {
        selectedChild = nil
    }
    
    // MARK: - Computed Properties
    
    var filteredChildren: [Child] {
        if searchText.isEmpty {
            return assignedChildren
        }
        return assignedChildren.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.room.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var childrenCount: Int {
        assignedChildren.count
    }

    var childrenWithAllergies: [Child] {
        assignedChildren.filter { $0.hasAllergies }
    }

    var childrenWithDietaryRestrictions: [Child] {
        assignedChildren.filter { $0.hasDietaryRestrictions }
    }

    var childrenWithMedicalNotes: [Child] {
        assignedChildren.filter { $0.hasMedicalNotes }
    }

    // MARK: - CRUD

    func addChild(
        name: String,
        age: Int,
        room: String,
        allergies: [String],
        dietaryRestrictions: [String],
        medicalNotes: String,
        emergencyContact: String,
        emergencyPhone: String
    ) {
        dataService.addChild(
            name: name,
            age: age,
            room: room,
            allergies: allergies,
            dietaryRestrictions: dietaryRestrictions,
            medicalNotes: medicalNotes,
            emergencyContact: emergencyContact,
            emergencyPhone: emergencyPhone
        )
        // Append directly to live list so UI updates instantly
        let newChild = Child(
            name: name,
            age: age,
            room: room,
            allergies: allergies,
            dietaryRestrictions: dietaryRestrictions,
            medicalNotes: medicalNotes,
            keyworkerName: SampleDataProvider.shared.currentKeyworkerName,
            emergencyContact: emergencyContact,
            emergencyPhone: emergencyPhone
        )
        SampleDataProvider.shared.sampleChildren.append(newChild)
        loadChildren()
    }

    func updateChild(_ child: Child,
                     name: String,
                     age: Int,
                     room: String,
                     allergies: [String],
                     dietaryRestrictions: [String],
                     medicalNotes: String,
                     emergencyContact: String,
                     emergencyPhone: String) {
        dataService.updateChild(
            child,
            name: name,
            age: age,
            room: room,
            allergies: allergies,
            dietaryRestrictions: dietaryRestrictions,
            medicalNotes: medicalNotes,
            emergencyContact: emergencyContact,
            emergencyPhone: emergencyPhone
        )
        loadChildren()
    }

    func deleteChild(_ child: Child) {
        dataService.deleteChild(child)
        // Remove from the in-memory cache so the list updates immediately
        SampleDataProvider.shared.sampleChildren.removeAll { $0.id == child.id }
        loadChildren()
    }

    func deleteChildren(at offsets: IndexSet) {
        let toDelete = offsets.map { filteredChildren[$0] }
        toDelete.forEach { deleteChild($0) }
    }
}
