//
//  AddDiaryEntryView.swift
//  NurseryConnectKeyworker
//
//  Form for creating new diary entries for assigned children.
//  Validates required fields before saving.
//

import SwiftUI

struct AddDiaryEntryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = DiaryViewModel()
    
    // Form Fields
    @State private var selectedType: DiaryEntryType = .meal
    @State private var selectedChild: Child?
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var notes: String = ""
    
    // Preselected values from quick actions
    let preselectedChild: Child?
    let preselectedType: DiaryEntryType?
    
    // Validation
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    // Available children
    @State private var availableChildren: [Child] = []
    
    init(preselectedChild: Child? = nil, preselectedType: DiaryEntryType? = nil) {
        self.preselectedChild = preselectedChild
        self.preselectedType = preselectedType
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Entry Type Section
                Section("Entry Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach([DiaryEntryType.meal, .nap, .activity, .mood, .nappy], id: \.self) { type in
                            Label {
                                Text(type.rawValue.capitalized)
                            } icon: {
                                Circle()
                                    .fill(colorFor(type))
                                    .frame(width: 10, height: 10)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityLabel("Entry type picker")
                }
                
                // Child Selection Section
                Section("Child") {
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
                    
                    if let child = selectedChild {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(child.name)
                                    .font(.subheadline)
                                    .bold()
                                Text("Age \(child.age) • \(child.room)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Selected child: \(child.name), age \(child.age), \(child.room)")
                    }
                }
                
                // Entry Details Section
                Section("Entry Details") {
                    TextField("Title", text: $title)
                        .accessibilityLabel("Entry title")
                        .accessibilityHint("Required field")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .accessibilityLabel("Entry description")
                            .accessibilityHint("Required field. Describe what happened")
                    }
                }
                
                // Additional Notes Section
                Section("Additional Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityLabel("Additional notes")
                        .accessibilityHint("Optional field for extra details")
                }
                
                // Save Button Section
                Section {
                    Button {
                        saveEntry()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save Entry")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!isFormValid)
                    .accessibilityLabel("Save diary entry")
                    .accessibilityHint(isFormValid ? "Tap to save entry" : "Complete required fields to enable")
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("New Diary Entry")
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
                availableChildren = DataService.shared.getAssignedChildren()
                
                // Apply preselected values
                if let preselectedChild = preselectedChild {
                    selectedChild = availableChildren.first { $0.id == preselectedChild.id }
                }
                if let preselectedType = preselectedType {
                    selectedType = preselectedType
                    // Set default title based on type
                    title = getDefaultTitle(for: preselectedType)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        selectedChild != nil &&
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Helper Methods
    
    private func getDefaultTitle(for type: DiaryEntryType) -> String {
        switch type {
        case .meal:
            return "Meal Time"
        case .nap:
            return "Nap Time"
        case .activity:
            return "Activity"
        case .mood:
            return "Mood Check"
        case .nappy:
            return "Nappy Change"
        }
    }
    
    private func saveEntry() {
        guard isFormValid, let child = selectedChild else {
            validationMessage = "Please fill in all required fields"
            showingValidationError = true
            return
        }
        
        // Add entry to viewModel
        viewModel.addEntry(
            type: selectedType,
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces),
            childId: child.id,
            childName: child.name
        )
        
        // Close the sheet
        dismiss()
    }
    
    private func colorFor(_ type: DiaryEntryType) -> Color {
        switch type {
        case .meal: return .green
        case .nap: return .blue
        case .activity: return .orange
        case .mood: return .purple
        case .nappy: return .brown
        }
    }
}

#Preview {
    AddDiaryEntryView()
}
