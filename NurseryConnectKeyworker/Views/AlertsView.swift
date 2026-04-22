//
//  AlertsView.swift
//  NurseryConnectKeyworker
//
//  Displays system alerts for allergies, dietary needs, medical notes,
//  overdue logs, and pending incidents. Supports acknowledgment and filtering.
//

import SwiftUI

struct AlertsView: View {
    @State private var viewModel = AlertsViewModel()
    @State private var selectedAlert: AlertItem?
    @State private var showingAlertDetail = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Stats Banner
                if viewModel.unacknowledgedCount > 0 {
                    statsBanner
                }
                
                // Main Content
                if viewModel.filteredAlerts.isEmpty {
                    emptyState
                } else {
                    alertsList
                }
            }
            .navigationTitle("Alerts & Reminders")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Toggle(isOn: $viewModel.showAcknowledgedAlerts) {
                            Label("Show Acknowledged", systemImage: "checkmark.circle")
                        }
                        
                        if viewModel.unacknowledgedCount > 0 {
                            Divider()
                            Button {
                                viewModel.acknowledgeAll()
                            } label: {
                                Label("Acknowledge All", systemImage: "checkmark.circle.fill")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .accessibilityLabel("Alert options")
                    }
                }
            }
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search alerts..."
            )
            .refreshable {
                await viewModel.refreshAlerts()
            }
            .onAppear {
                viewModel.loadAlerts()
            }
            .sheet(item: $selectedAlert) { alert in
                AlertDetailView(alert: alert) {
                    viewModel.acknowledgeAlert(alert)
                }
            }
        }
    }
    
    // MARK: - Stats Banner
    
    private var statsBanner: some View {
        HStack(spacing: 16) {
            // Critical Alerts Count
            VStack(spacing: 4) {
                Text("\(viewModel.criticalAlerts.count)")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.red)
                
                Text("Critical")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            // Unacknowledged Count
            VStack(spacing: 4) {
                Text("\(viewModel.unacknowledgedCount)")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.orange)
                
                Text("Unread")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Acknowledge All Button
            if viewModel.unacknowledgedCount > 0 {
                Button {
                    viewModel.acknowledgeAll()
                } label: {
                    Text("Clear All")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .accessibilityLabel("Acknowledge all alerts")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Alert statistics: \(viewModel.criticalAlerts.count) critical, \(viewModel.unacknowledgedCount) unread")
    }
    
    // MARK: - Alerts List
    
    private var alertsList: some View {
        List {
            // Critical Section
            if !viewModel.criticalAlerts.isEmpty {
                Section {
                    ForEach(viewModel.criticalAlerts.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { alert in
                        AlertBadge(alert: alert, onAcknowledge: {
                            viewModel.acknowledgeAlert(alert)
                        }, onDismiss: {
                            viewModel.deleteAlert(alert)
                        })
                        .contentShape(Rectangle())
                        .onTapGesture { selectedAlert = alert }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            if !alert.isAcknowledged {
                                Button {
                                    viewModel.acknowledgeAlert(alert)
                                } label: {
                                    Label("Acknowledge", systemImage: "checkmark")
                                }
                                .tint(.blue)
                            }
                            
                            Button(role: .destructive) {
                                viewModel.deleteAlert(alert)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                        Text("Critical Alerts")
                    }
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
                }
            }
            
            // All Alerts Section
            Section {
                ForEach(viewModel.filteredAlerts.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { alert in
                    AlertBadge(alert: alert, onAcknowledge: {
                        viewModel.acknowledgeAlert(alert)
                    }, onDismiss: {
                        viewModel.deleteAlert(alert)
                    })
                    .contentShape(Rectangle())
                    .onTapGesture { selectedAlert = alert }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if !alert.isAcknowledged {
                            Button {
                                viewModel.acknowledgeAlert(alert)
                            } label: {
                                Label("Acknowledge", systemImage: "checkmark")
                            }
                            .tint(.blue)
                        }
                        
                        Button(role: .destructive) {
                            viewModel.deleteAlert(alert)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .opacity(alert.isAcknowledged ? 0.6 : 1.0)
                }
            } header: {
                Text("All Alerts")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .listStyle(.plain)
        .accessibilityLabel("Alerts list")
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        ContentUnavailableView(
            viewModel.searchText.isEmpty ? "No Alerts" : "No Matching Alerts",
            systemImage: "bell.slash",
            description: Text(viewModel.searchText.isEmpty ?
                (viewModel.showAcknowledgedAlerts ?
                    "All alerts have been acknowledged" :
                    "No active alerts at this time") :
                "Try adjusting your search"
            )
        )
        .accessibilityLabel(viewModel.searchText.isEmpty ? "No alerts" : "No matching alerts found")
    }
}

// MARK: - Alert Detail View

struct AlertDetailView: View {
    @Environment(\.dismiss) var dismiss
    let alert: AlertItem
    let onAcknowledge: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Priority Badge
                    HStack {
                        Circle()
                            .fill(priorityColor(for: alert.priority))
                            .frame(width: 12, height: 12)
                        
                        Text("\(alert.priority.rawValue.capitalized) Priority")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(priorityColor(for: alert.priority))
                        
                        Spacer()
                        
                        Label(alert.alertType.rawValue.capitalized, systemImage: alert.alertType.icon)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    // Title
                    Text(alert.title)
                        .font(.title2)
                        .bold()
                    
                    // Message
                    Text(alert.message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    // Related Child
                    if alert.childId != nil && !alert.childName.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Related Child", systemImage: "person.fill")
                                .font(.headline)
                            
                            Text(alert.childName)
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    
                    // Timestamp
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Created", systemImage: "clock")
                            .font(.headline)
                        
                        Text(alert.timestamp, style: .relative)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Acknowledgment Status
                    if alert.isAcknowledged, let acknowledgedAt = alert.acknowledgedAt {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Acknowledged", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.green)
                            
                            Text(acknowledgedAt, style: .relative)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Action Button
                    if !alert.isAcknowledged {
                        Button {
                            onAcknowledge()
                            dismiss()
                        } label: {
                            HStack {
                                Spacer()
                                Label("Acknowledge Alert", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                                Spacer()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .accessibilityLabel("Acknowledge this alert")
                    }
                }
                .padding()
            }
            .navigationTitle("Alert Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .accessibilityLabel("Close alert details")
                }
            }
        }
    }
    
    private func priorityColor(for priority: AlertPriority) -> Color {
        switch priority {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        case .critical: return .red
        }
    }
}

#Preview {
    AlertsView()
}
