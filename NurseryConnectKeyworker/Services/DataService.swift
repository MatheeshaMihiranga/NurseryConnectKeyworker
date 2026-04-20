//
//  DataService.swift
//  NurseryConnectKeyworker
//
//  Provides data access layer between ViewModels and persistence.
//  Wraps SwiftData operations with business logic and filtering.
//

import Foundation
import SwiftData

@MainActor
class DataService {
    static let shared = DataService()
    
    // MARK: - Properties
    
    private var persistenceService: PersistenceService {
        PersistenceService.shared
    }
    
    var useSampleData: Bool = false // Set to false to enable real data persistence
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Children Operations
    
    func getAssignedChildren() -> [Child] {
        if useSampleData {
            return SampleDataProvider.shared.getAssignedChildren()
        }
        return persistenceService.fetchChildren()
    }
    
    func getChild(by id: UUID) -> Child? {
        let children = getAssignedChildren()
        return children.first { $0.id == id }
    }
    
    // MARK: - Diary Entry Operations
    
    func getDiaryEntries(for childId: UUID? = nil) -> [DiaryEntry] {
        if useSampleData {
            return SampleDataProvider.shared.getDiaryEntries(for: childId)
        }
        
        let allEntries = persistenceService.fetchDiaryEntries()
        
        if let childId = childId {
            return allEntries.filter { $0.childId == childId }
        }
        
        return allEntries
    }
    
    func addDiaryEntry(
        type: DiaryEntryType,
        title: String,
        description: String,
        notes: String? = nil,
        childId: UUID,
        childName: String
    ) {
        let entry = DiaryEntry(
            id: UUID(),
            childId: childId,
            childName: childName,
            type: type,
            timestamp: Date(),
            title: title,
            description: description,
            notes: notes,
            keyworkerName: "Current Keyworker",
            portionSize: nil,
            duration: nil,
            moodRating: nil
        )
        
        if !useSampleData {
            persistenceService.mainContext.insert(entry)
            persistenceService.save()
        }
        
        print("✅ Diary entry added: \(title) for \(childName)")
    }
    
    func getOverdueDiaryEntries() -> [DiaryEntry] {
        let entries = getDiaryEntries()
        return entries.filter { $0.isOverdue }
    }
    
    func getRecentDiaryEntries(limit: Int = 3) -> [DiaryEntry] {
        let entries = getDiaryEntries()
        return Array(entries.sorted(by: { $0.timestamp > $1.timestamp }).prefix(limit))
    }
    
    // MARK: - Incident Report Operations
    
    func getIncidentReports(for childId: UUID? = nil) -> [IncidentReport] {
        if useSampleData {
            return SampleDataProvider.shared.getIncidentReports(for: childId)
        }
        
        let allReports = persistenceService.fetchIncidentReports()
        
        if let childId = childId {
            return allReports.filter { $0.childId == childId }
        }
        
        return allReports
    }
    
    func getIncidents() -> [IncidentReport] {
        return getIncidentReports()
    }
    
    func addIncidentReport(
        category: IncidentCategory,
        severity: IncidentSeverity,
        location: String,
        description: String,
        immediateAction: String,
        witnesses: [String],
        childId: UUID,
        childName: String
    ) {
        let report = IncidentReport(
            id: UUID(),
            childId: childId,
            childName: childName,
            category: category,
            severity: severity,
            timestamp: Date(),
            location: location,
            description: description,
            immediateAction: immediateAction,
            witnesses: witnesses,
            parentNotified: false,
            parentNotificationTime: nil,
            managerReviewed: false,
            managerReviewTime: nil,
            reportedBy: "Current Keyworker",
            createdAt: Date()
        )
        
        if !useSampleData {
            persistenceService.mainContext.insert(report)
            persistenceService.save()
        }
        
        print("✅ Incident report added: \(category.rawValue) - \(severity.rawValue)")
        
        // Auto-generate alert for urgent incidents
        if report.requiresUrgentAction {
            createUrgentIncidentAlert(for: report)
        }
    }
    
    func markIncidentAsReviewed(_ report: IncidentReport) {
        report.managerReviewed = true
        report.managerReviewTime = Date()
        
        if !useSampleData {
            persistenceService.save()
        }
        
        print("✅ Incident marked as reviewed")
    }
    
    func markManagerReviewed(incidentId: UUID) async throws {
        let incidents = getIncidents()
        guard let incident = incidents.first(where: { $0.id == incidentId }) else {
            throw NSError(domain: "DataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Incident not found"])
        }
        
        markIncidentAsReviewed(incident)
    }
    
    func markParentNotified(_ report: IncidentReport) {
        report.parentNotified = true
        report.parentNotificationTime = Date()
        
        if !useSampleData {
            persistenceService.save()
        }
        
        print("✅ Parent marked as notified")
    }
    
    func markParentNotified(incidentId: UUID) async throws {
        let incidents = getIncidents()
        guard let incident = incidents.first(where: { $0.id == incidentId }) else {
            throw NSError(domain: "DataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Incident not found"])
        }
        
        markParentNotified(incident)
    }
    
    func createIncident(_ incident: IncidentReport) async throws {
        if !useSampleData {
            persistenceService.mainContext.insert(incident)
            persistenceService.save()
        }
        
        print("✅ Incident report created: \(incident.category.rawValue)")
    }
    
    func getPendingIncidents() -> [IncidentReport] {
        let reports = getIncidentReports()
        return reports.filter { $0.isPending }
    }
    
    func getRecentIncidents(days: Int = 7) -> [IncidentReport] {
        let reports = getIncidentReports()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return reports.filter { $0.timestamp >= cutoffDate }
    }
    
    // MARK: - Alert Operations
    
    func getAlerts() -> [AlertItem] {
        if useSampleData {
            return SampleDataProvider.shared.getAlerts()
        }
        return persistenceService.fetchAlerts()
    }
    
    func getUnacknowledgedAlerts() -> [AlertItem] {
        if useSampleData {
            return SampleDataProvider.shared.getUnacknowledgedAlerts()
        }
        
        let alerts = getAlerts()
        return alerts.filter { !$0.isAcknowledged }
    }
    
    func getCriticalAlerts() -> [AlertItem] {
        let alerts = getAlerts()
        return alerts.filter { $0.priority == .critical || $0.priority == .high }
    }
    
    func acknowledgeAlert(_ alert: AlertItem) {
        alert.acknowledgeAlert()
        
        if !useSampleData {
            persistenceService.save()
        }
        
        print("✅ Alert acknowledged: \(alert.title)")
    }
    
    func acknowledgeAlert(id: UUID) async throws {
        let alerts = getAlerts()
        guard let alert = alerts.first(where: { $0.id == id }) else {
            throw NSError(domain: "DataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Alert not found"])
        }
        
        acknowledgeAlert(alert)
    }
    
    func dismissAlert(id: UUID) async throws {
        let alerts = getAlerts()
        guard let alert = alerts.first(where: { $0.id == id }) else {
            throw NSError(domain: "DataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Alert not found"])
        }
        
        deleteAlert(alert)
    }
    
    func deleteAlert(_ alert: AlertItem) {
        if !useSampleData {
            persistenceService.delete(alert)
        }
        
        print("🗑️ Alert deleted: \(alert.title)")
    }
    
    private func createUrgentIncidentAlert(for report: IncidentReport) {
        let alert = AlertItem(
            type: .pending,
            priority: report.severity == .major ? .critical : .high,
            title: "Urgent: \(report.category.rawValue.capitalized) Incident",
            message: "A \(report.severity.rawValue) \(report.category.rawValue) incident requires immediate attention for \(report.childName)",
            relatedChildId: report.childId,
            relatedChildName: report.childName,
            timestamp: Date(),
            isAcknowledged: false
        )
        
        if !useSampleData {
            persistenceService.mainContext.insert(alert)
            persistenceService.save()
        }
        
        print("🚨 Urgent incident alert created")
    }
    
    // MARK: - Refresh Data
    
    func refresh() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        print("🔄 Data refreshed")
    }
    
    // MARK: - Statistics
    
    func getHomeStatistics() -> (
        assignedChildren: [Child],
        recentEntries: [DiaryEntry],
        pendingIncidents: [IncidentReport],
        criticalAlerts: [AlertItem],
        overdueCount: Int
    ) {
        let children = getAssignedChildren()
        let recentEntries = getRecentDiaryEntries(limit: 3)
        let pendingIncidents = getPendingIncidents()
        let criticalAlerts = getCriticalAlerts()
        let overdueCount = getOverdueDiaryEntries().count
        
        return (children, recentEntries, pendingIncidents, criticalAlerts, overdueCount)
    }
}
