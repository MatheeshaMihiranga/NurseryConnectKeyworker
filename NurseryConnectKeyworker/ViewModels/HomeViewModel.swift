//
//  HomeViewModel.swift
//  NurseryConnectKeyworker
//
//  ViewModel for Home Dashboard screen.
//  Manages overview data: assigned children, recent entries, alerts, pending incidents.
//

import Foundation
import SwiftUI

@Observable
class HomeViewModel {
    var assignedChildren: [Child] = []
    var recentDiaryEntries: [DiaryEntry] = []
    var highPriorityAlerts: [AlertItem] = []
    var pendingIncidents: [IncidentReport] = []
    var unacknowledgedAlertCount: Int = 0
    var pendingIncidentCount: Int = 0
    
    private let dataService = DataService.shared
    
    // MARK: - Initialization
    
    init() {
        loadDashboardData()
    }
    
    // MARK: - Data Loading
    
    func loadDashboardData() {
        // Load assigned children
        assignedChildren = dataService.getAssignedChildren()
            
        // Get recent diary entries (last 3)
        let allEntries = dataService.getDiaryEntries()
        recentDiaryEntries = Array(allEntries
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(3))
        
        // Get high-priority unacknowledged alerts (includes critical, urgent, high)
        highPriorityAlerts = dataService.getAlerts()
            .filter { ($0.priority == .critical || $0.priority == .urgent || $0.priority == .high) && !$0.isAcknowledged }
            .sorted(by: AlertItem.sortByPriority)
        
        // Get pending incidents (not fully reviewed)
        pendingIncidents = dataService.getIncidents()
            .filter { $0.isPending }
            .sorted { $0.timestamp > $1.timestamp }
        
        // Badge counts
        unacknowledgedAlertCount = dataService.getAlerts().filter { !$0.isAcknowledged }.count
        pendingIncidentCount = dataService.getIncidents().filter { $0.isPending }.count
    }
    
    func refreshData() async {
        // Simulate async refresh
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        await MainActor.run {
            loadDashboardData()
        }
    }
    
    // MARK: - Computed Properties
    
    var assignedChildrenCount: Int {
        assignedChildren.count
    }
    
    var todaysDiaryEntryCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return dataService.getDiaryEntries().filter {
            calendar.isDate($0.timestamp, inSameDayAs: today)
        }.count
    }
    
    var hasHighPriorityAlerts: Bool {
        !highPriorityAlerts.isEmpty
    }
    
    var hasPendingIncidents: Bool {
        !pendingIncidents.isEmpty
    }
    
    var criticalAlerts: [AlertItem] {
        highPriorityAlerts
    }
    
    var overdueCount: Int {
        dataService.getOverdueDiaryEntries().count
    }
    
    func refresh() async {
        await refreshData()
    }
}
