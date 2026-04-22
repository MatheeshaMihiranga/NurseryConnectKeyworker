//
//  IncidentReportView.swift
//  NurseryConnectKeyworker
//
//  Displays incident reports with filtering and allows creating new reports.
//  Includes safeguarding-focused workflows with audit trail.
//

import SwiftUI

struct IncidentReportView: View {
    @State private var viewModel = IncidentViewModel()
    @State private var showingAddReport = false
    @State private var showFilterMenu = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Active Filters Display
                if viewModel.selectedCategory != nil || viewModel.selectedSeverity != nil {
                    activeFiltersBar
                }
                
                // Main Content
                if viewModel.filteredIncidents.isEmpty {
                    emptyState
                } else {
                    reportsList
                }
            }
            .navigationTitle("Incident Reports")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddReport = true
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add new incident report")
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Menu("Filter by Category") {
                            Button("All Categories") {
                                viewModel.selectedCategory = nil
                            }
                            ForEach([IncidentCategory.injury, .illness, .behavior, .safeguarding, .accident, .allergic, .other], id: \.self) { category in
                                Button(category.rawValue.capitalized) {
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                        
                        Menu("Filter by Severity") {
                            Button("All Severities") {
                                viewModel.selectedSeverity = nil
                            }
                            ForEach([IncidentSeverity.minor, .moderate, .major, .serious], id: \.self) { severity in
                                Button(severity.rawValue.capitalized) {
                                    viewModel.selectedSeverity = severity
                                }
                            }
                        }
                        
                        if viewModel.selectedCategory != nil || viewModel.selectedSeverity != nil {
                            Divider()
                            Button("Clear Filters") {
                                viewModel.selectedCategory = nil
                                viewModel.selectedSeverity = nil
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .accessibilityLabel("Filter incidents")
                    }
                }
            }
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search incidents..."
            )
            .refreshable {
                await viewModel.refreshIncidents()
            }
            .onAppear {
                viewModel.loadIncidents()
            }
            .sheet(isPresented: $showingAddReport) {
                IncidentReportFormView()
            }
        }
    }
    
    // MARK: - Active Filters Bar
    
    private var activeFiltersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = viewModel.selectedCategory {
                    FilterTag(text: category.rawValue.capitalized) {
                        viewModel.selectedCategory = nil
                    }
                }
                
                if let severity = viewModel.selectedSeverity {
                    FilterTag(text: severity.rawValue.capitalized) {
                        viewModel.selectedSeverity = nil
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGray6))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Active filters")
    }
    
    // MARK: - Reports List
    
    private var reportsList: some View {
        List {
            // Pending Section
            if !viewModel.pendingIncidents.isEmpty {
                Section {
                    ForEach(viewModel.pendingIncidents.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { incident in
                        IncidentCard(incident: incident, onMarkParentNotified: {
                            Task { await viewModel.markParentNotified(incidentId: incident.id) }
                        }, onMarkManagerReviewed: {
                            Task { await viewModel.markManagerReviewed(incidentId: incident.id) }
                        })
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button {
                                viewModel.markAsReviewed(incident)
                            } label: {
                                Label("Mark Reviewed", systemImage: "checkmark")
                            }
                            .tint(.blue)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Pending Review")
                    }
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
                }
            }
            
            // All Reports Section
            Section {
                ForEach(viewModel.filteredIncidents.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { incident in
                    IncidentCard(incident: incident, onMarkParentNotified: {
                        Task { await viewModel.markParentNotified(incidentId: incident.id) }
                    }, onMarkManagerReviewed: {
                        Task { await viewModel.markManagerReviewed(incidentId: incident.id) }
                    })
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                }
            } header: {
                Text("All Reports")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .listStyle(.plain)
        .accessibilityLabel("Incident reports list")
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        ContentUnavailableView(
            viewModel.searchText.isEmpty ? "No Incidents" : "No Matching Incidents",
            systemImage: "checkmark.shield",
            description: Text(viewModel.searchText.isEmpty ?
                "No incidents have been reported" :
                "Try adjusting your search or filters"
            )
        )
        .accessibilityLabel(viewModel.searchText.isEmpty ? "No incidents reported" : "No matching incidents found")
    }
}

// MARK: - Filter Tag Component

struct FilterTag: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.2))
        .foregroundStyle(.blue)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(text) filter. Tap to remove")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Incident Report Form View

struct IncidentReportFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = IncidentViewModel()
    
    // Form Fields
    @State private var selectedCategory: IncidentCategory = .injury
    @State private var selectedSeverity: IncidentSeverity = .minor
    @State private var selectedChild: Child?
    @State private var location: String = ""
    @State private var description: String = ""
    @State private var immediateAction: String = ""
    @State private var witnesses: String = ""
    
    // Preselected child
    let preselectedChild: Child?
    
    // Validation
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    // Available children
    @State private var availableChildren: [Child] = []
    
    init(preselectedChild: Child? = nil) {
        self.preselectedChild = preselectedChild
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Incident Classification
                Section("Incident Classification") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach([IncidentCategory.injury, .illness, .behavior, .safeguarding, .accident, .allergic, .other], id: \.self) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                    .accessibilityLabel("Incident category picker")
                    
                    Picker("Severity", selection: $selectedSeverity) {
                        ForEach([IncidentSeverity.minor, .moderate, .major, .serious], id: \.self) { severity in
                            HStack {
                                Circle()
                                    .fill(colorFor(severity))
                                    .frame(width: 10, height: 10)
                                Text(severity.rawValue.capitalized)
                            }
                            .tag(severity)
                        }
                    }
                    .accessibilityLabel("Severity level picker")
                    
                    if selectedCategory == .safeguarding || selectedSeverity == .major || selectedSeverity == .serious {
                        Label {
                            Text("This incident requires urgent attention and manager review")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        }
                        .foregroundStyle(.red)
                        .accessibilityLabel("Warning: This incident requires urgent attention")
                    }
                }
                
                // Child Selection
                Section("Child Involved") {
                    Picker("Select Child", selection: $selectedChild) {
                        Text("Select a child...")
                            .tag(nil as Child?)
                        
                        ForEach(availableChildren, id: \.id) { child in
                            Text("\(child.name) - \(child.room)")
                                .tag(child as Child?)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityLabel("Child selection picker")
                }
                
                // Incident Details
                Section("Incident Details") {
                    TextField("Location", text: $location)
                        .accessibilityLabel("Incident location")
                        .accessibilityHint("Required field")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .accessibilityLabel("Incident description")
                            .accessibilityHint("Required field. Describe what happened in detail")
                    }
                }
                
                // Actions Taken
                Section("Immediate Action Taken") {
                    TextEditor(text: $immediateAction)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityLabel("Immediate action taken")
                        .accessibilityHint("Required field. Describe actions taken")
                }
                
                // Witnesses
                Section {
                    TextField("Witness names (separate with commas)", text: $witnesses)
                        .accessibilityLabel("Witnesses")
                        .accessibilityHint("Optional. Enter witness names separated by commas")
                } header: {
                    Text("Witnesses (Optional)")
                } footer: {
                    Text("Enter names separated by commas")
                        .font(.caption)
                }
                
                // Save Button
                Section {
                    Button {
                        saveReport()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Submit Report")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!isFormValid)
                    .accessibilityLabel("Submit incident report")
                    .accessibilityHint(isFormValid ? "Tap to submit report" : "Complete required fields to enable")
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("New Incident Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel and close")
                }
            }
            .alert("Validation Error", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .onAppear {
                availableChildren = SampleDataProvider.shared.getAssignedChildren()
                
                if let preselectedChild = preselectedChild {
                    selectedChild = availableChildren.first { $0.id == preselectedChild.id }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        selectedChild != nil &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !immediateAction.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Helper Methods
    
    private func saveReport() {
        guard isFormValid, let child = selectedChild else {
            validationMessage = "Please fill in all required fields"
            showingValidationError = true
            return
        }
        
        // Parse witnesses
        let witnessArray = witnesses
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Add report to viewModel
        viewModel.addReport(
            category: selectedCategory,
            severity: selectedSeverity,
            location: location.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            immediateAction: immediateAction.trimmingCharacters(in: .whitespaces),
            witnesses: witnessArray,
            childId: child.id,
            childName: child.name
        )
        
        dismiss()
    }
    
    private func colorFor(_ severity: IncidentSeverity) -> Color {
        switch severity {
        case .minor: return .yellow
        case .moderate: return .orange
        case .major: return .red
        case .serious: return .red
        }
    }
}

#Preview {
    IncidentReportView()
}
