//
//  AlertsViewModel.swift
//  NurseryConnectKeyworker
//
//  ViewModel for Alerts & Reminders screen.
//  Manages alerts, filtering, and acknowledgment logic.
//

import Foundation
import SwiftUI

@Observable
class AlertsViewModel {
    var alerts: [AlertItem] = []
    var selectedPriority: AlertPriority?
    var selectedAlertType: AlertType?
    var showAcknowledgedAlerts: Bool = false
    var searchText: String = ""
    
    private let dataService = DataService.shared
    
    // MARK: - Initialization
    
    init() {
        loadAlerts()
    }
    
    // MARK: - Data Loading
    
    func loadAlerts() {
        alerts = dataService.getAlerts()
        alerts.sort(by: AlertItem.sortByTime)
    }
    
    func refreshAlerts() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            loadAlerts()
        }
    }
    
    // MARK: - Alert Actions
    
    func acknowledgeAlert(id: UUID) async {
        try? await dataService.acknowledgeAlert(id: id)
        await MainActor.run {
            loadAlerts()
        }
    }
    
    func dismissAlert(id: UUID) async {
        try? await dataService.dismissAlert(id: id)
        await MainActor.run {
            loadAlerts()
        }
    }
    
    func markAllAsAcknowledged() async {
        for alert in unacknowledgedAlerts {
            try? await dataService.acknowledgeAlert(id: alert.id)
        }
        await MainActor.run {
            loadAlerts()
        }
    }
    
    // MARK: - Filtering
    
    func filterByPriority(_ priority: AlertPriority?) {
        selectedPriority = priority
    }
    
    func filterByAlertType(_ type: AlertType?) {
        selectedAlertType = type
    }
    
    func toggleShowAcknowledged() {
        showAcknowledgedAlerts.toggle()
    }
    
    func clearFilters() {
        selectedPriority = nil
        selectedAlertType = nil
        searchText = ""
    }
    
    // MARK: - Computed Properties
    
    var filteredAlerts: [AlertItem] {
        var filtered = alerts
        
        // Filter by acknowledgment status
        if !showAcknowledgedAlerts {
            filtered = filtered.filter { !$0.isAcknowledged }
        }
        
        // Filter by priority
        if let priority = selectedPriority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        // Filter by alert type
        if let type = selectedAlertType {
            filtered = filtered.filter { $0.alertType == type }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.childName.localizedCaseInsensitiveContains(searchText) ||
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.message.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var sortedAlerts: [AlertItem] {
        filteredAlerts.sorted(by: AlertItem.sortByPriority)
    }
    
    var unacknowledgedAlerts: [AlertItem] {
        alerts.filter { !$0.isAcknowledged }
    }
    
    var unacknowledgedCount: Int {
        unacknowledgedAlerts.count
    }
    
    var urgentAlerts: [AlertItem] {
        alerts.filter { $0.priority == .urgent && !$0.isAcknowledged }
    }
    
    var highPriorityAlerts: [AlertItem] {
        alerts.filter { ($0.priority == .high || $0.priority == .urgent) && !$0.isAcknowledged }
    }
    
    var allergyAlerts: [AlertItem] {
        alerts.filter { $0.alertType == .allergy }
    }
    
    var medicalAlerts: [AlertItem] {
        alerts.filter { $0.alertType == .medical }
    }
    
    var overdueReminders: [AlertItem] {
        alerts.filter { $0.alertType == .overdueDiary && !$0.isAcknowledged }
    }
    
    var criticalAlerts: [AlertItem] {
        alerts.filter { ($0.priority == .critical || $0.priority == .urgent) && !$0.isAcknowledged }
    }
    
    func acknowledgeAlert(_ alert: AlertItem) {
        dataService.acknowledgeAlert(alert)
        loadAlerts()
    }
    
    func deleteAlert(_ alert: AlertItem) {
        dataService.deleteAlert(alert)
        loadAlerts()
    }
    
    func acknowledgeAll() {
        Task {
            await markAllAsAcknowledged()
        }
    }
}
