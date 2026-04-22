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
}
