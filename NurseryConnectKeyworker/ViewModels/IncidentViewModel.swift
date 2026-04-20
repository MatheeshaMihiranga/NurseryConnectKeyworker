//
//  IncidentViewModel.swift
//  NurseryConnectKeyworker
//
//  ViewModel for Incident Reporting feature.
//  Manages incident creation, status updates, and filtering.
//

import Foundation
import SwiftUI

@Observable
class IncidentViewModel {
    var incidents: [IncidentReport] = []
    var selectedChild: Child?
    var selectedCategory: IncidentCategory?
    var selectedSeverity: IncidentSeverity?
    var showCompletedIncidents: Bool = false
    var searchText: String = ""
    
    private let dataService = DataService.shared
    
    // MARK: - Initialization
    
    init() {
        loadIncidents()
    }
    
    // MARK: - Data Loading
    
    func loadIncidents() {
        incidents = dataService.getIncidents()
        incidents.sort { $0.timestamp > $1.timestamp }
    }
    
    func refreshIncidents() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            loadIncidents()
        }
    }
    
    // MARK: - Incident Creation & Updates
    
    func createIncident(_ incident: IncidentReport) async {
        try? await dataService.createIncident(incident)
        await MainActor.run {
            loadIncidents()
        }
    }
    
    func markParentNotified(incidentId: UUID) async {
        try? await dataService.markParentNotified(incidentId: incidentId)
        await MainActor.run {
            loadIncidents()
        }
    }
    
    func markManagerReviewed(incidentId: UUID) async {
        try? await dataService.markManagerReviewed(incidentId: incidentId)
        await MainActor.run {
            loadIncidents()
        }
    }
    
    func markAsReviewed(_ incident: IncidentReport) {
        Task {
            await markManagerReviewed(incidentId: incident.id)
        }
    }
    
    // MARK: - Filtering
    
    func filterByChild(_ child: Child?) {
        selectedChild = child
    }
    
    func filterByCategory(_ category: IncidentCategory?) {
        selectedCategory = category
    }
    
    func filterBySeverity(_ severity: IncidentSeverity?) {
        selectedSeverity = severity
    }
    
    func toggleShowCompleted() {
        showCompletedIncidents.toggle()
    }
    
    func clearFilters() {
        selectedChild = nil
        selectedCategory = nil
        selectedSeverity = nil
        showCompletedIncidents = false
    }
    
    // MARK: - Computed Properties
    
    var filteredIncidents: [IncidentReport] {
        var filtered = incidents
        
        // Filter by completion status
        if !showCompletedIncidents {
            filtered = filtered.filter { $0.isPending }
        }
        
        // Filter by child
        if let child = selectedChild {
            filtered = filtered.filter { $0.childId == child.id }
        }
        
        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by severity
        if let severity = selectedSeverity {
            filtered = filtered.filter { $0.severity == severity }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.childName.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var pendingIncidents: [IncidentReport] {
        incidents.filter { $0.isPending }
    }
    
    var pendingCount: Int {
        pendingIncidents.count
    }
    
    var completedIncidents: [IncidentReport] {
        incidents.filter { $0.isComplete }
    }
    
    var todaysIncidents: [IncidentReport] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return incidents.filter {
            calendar.isDate($0.timestamp, inSameDayAs: today)
        }
    }
    
    var requiresParentNotification: [IncidentReport] {
        incidents.filter { !$0.parentNotified }
    }
    
    var requiresManagerReview: [IncidentReport] {
        incidents.filter { !$0.managerReviewed }
    }
    
    // MARK: - Adding Reports
    
    func addReport(
        category: IncidentCategory,
        severity: IncidentSeverity,
        location: String,
        description: String,
        immediateAction: String,
        witnesses: [String],
        childId: UUID,
        childName: String
    ) {
        Task {
            await dataService.addIncidentReport(
                category: category,
                severity: severity,
                location: location,
                description: description,
                immediateAction: immediateAction,
                witnesses: witnesses,
                childId: childId,
                childName: childName
            )
            await MainActor.run {
                loadIncidents()
            }
        }
    }
}
