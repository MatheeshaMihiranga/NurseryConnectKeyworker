//
//  AddEditChildView.swift
//  NurseryConnectKeyworker
//
//  A form sheet for adding a new child or editing an existing child's details.
//  Works in two modes:
//   - Add mode  (child == nil): creates a new record
//   - Edit mode (child != nil): pre-fills with existing data and saves updates
//

import SwiftUI

struct AddEditChildView: View {
    // Pass nil to add, or a Child to edit
    var existingChild: Child? = nil
    var onSave: (Child?) -> Void   // returns updated/new child so caller can react

    @Environment(\.dismiss) private var dismiss

    // MARK: - Form State

    @State private var name = ""
    @State private var age = 2
    @State private var room = "Toddlers"
    @State private var emergencyContact = ""
    @State private var emergencyPhone = ""
    @State private var medicalNotes = ""

    // Tag-style entry for lists
    @State private var allergyInput = ""
    @State private var allergies: [String] = []
    @State private var dietaryInput = ""
    @State private var dietaryRestrictions: [String] = []

    @State private var showValidationError = false
    @State private var isSaving = false

    private let rooms = ["Baby Room", "Toddlers", "Pre-school"]
    private let dataService = DataService.shared

    // MARK: - Derived

    private var isEditMode: Bool { existingChild != nil }
    private var title: String { isEditMode ? "Edit Child" : "Add Child" }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !emergencyContact.trimmingCharacters(in: .whitespaces).isEmpty &&
        !emergencyPhone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // ── Basic Info ──────────────────────────────────────
                Section("Child Details") {
                    TextField("Full Name *", text: $name)
                        .textContentType(.name)
                        .accessibilityLabel("Child's full name (required)")

                    HStack {
                        Text("Age (years)")
                        Spacer()
                        Stepper("\(age)", value: $age, in: 0...12)
                    }
                    .accessibilityLabel("Age: \(age) years")

                    Picker("Room", selection: $room) {
                        ForEach(rooms, id: \.self) { Text($0) }
                    }
                    .accessibilityLabel("Room assignment")
                }

                // ── Emergency Contact ───────────────────────────────
                Section("Emergency Contact") {
                    TextField("Parent / Guardian Name *", text: $emergencyContact)
                        .textContentType(.name)
                        .accessibilityLabel("Emergency contact name (required)")

                    TextField("Phone Number *", text: $emergencyPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        .accessibilityLabel("Emergency contact phone number (required)")
                }

                // ── Allergies ───────────────────────────────────────
                Section {
                    tagInputRow(
                        label: "Add allergy (e.g. Peanuts)",
                        input: $allergyInput,
                        tags: $allergies
                    )
                    if !allergies.isEmpty {
                        tagList(tags: $allergies, color: .red)
                    }
                } header: {
                    Text("Allergies")
                } footer: {
                    Text("Type an allergy and tap + to add. Tap a badge to remove it.")
                        .font(.caption)
                }

                // ── Dietary Restrictions ────────────────────────────
                Section {
                    tagInputRow(
                        label: "Add restriction (e.g. Vegetarian)",
                        input: $dietaryInput,
                        tags: $dietaryRestrictions
                    )
                    if !dietaryRestrictions.isEmpty {
                        tagList(tags: $dietaryRestrictions, color: .orange)
                    }
                } header: {
                    Text("Dietary Restrictions")
                } footer: {
                    Text("Type a restriction and tap + to add.")
                        .font(.caption)
                }

                // ── Medical Notes ───────────────────────────────────
                Section("Medical Notes") {
                    TextEditor(text: $medicalNotes)
                        .frame(minHeight: 80)
                        .accessibilityLabel("Medical notes for child")
                }

                // ── Validation error ────────────────────────────────
                if showValidationError {
                    Section {
                        Label("Please fill in Name, Emergency Contact, and Phone Number.",
                              systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditMode ? "Save" : "Add") {
                        handleSave()
                    }
                    .bold()
                    .disabled(isSaving)
                }
            }
            .onAppear { prefill() }
        }
    }

    // MARK: - Tag Input

    private func tagInputRow(label: String, input: Binding<String>, tags: Binding<[String]>) -> some View {
        HStack {
            TextField(label, text: input)
                .onSubmit { addTag(input: input, tags: tags) }
            Button {
                addTag(input: input, tags: tags)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.title3)
            }
            .disabled(input.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityLabel("Add tag")
        }
    }

    private func tagList(tags: Binding<[String]>, color: Color) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags.wrappedValue, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Text(tag)
                            .font(.subheadline)
                        Button {
                            tags.wrappedValue.removeAll { $0 == tag }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                        }
                        .accessibilityLabel("Remove \(tag)")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.15))
                    .foregroundStyle(color)
                    .clipShape(Capsule())
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func addTag(input: Binding<String>, tags: Binding<[String]>) {
        let trimmed = input.wrappedValue.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.wrappedValue.contains(trimmed) else { return }
        tags.wrappedValue.append(trimmed)
        input.wrappedValue = ""
    }

    // MARK: - Pre-fill for Edit Mode

    private func prefill() {
        guard let child = existingChild else { return }
        name = child.name
        age = child.age
        room = child.room
        emergencyContact = child.emergencyContact
        emergencyPhone = child.emergencyPhone
        medicalNotes = child.medicalNotes
        allergies = child.allergies
        dietaryRestrictions = child.dietaryRestrictions
    }

    // MARK: - Save

    private func handleSave() {
        guard isFormValid else {
            showValidationError = true
            return
        }
        showValidationError = false
        isSaving = true

        let trimmedName   = name.trimmingCharacters(in: .whitespaces)
        let trimmedContact = emergencyContact.trimmingCharacters(in: .whitespaces)
        let trimmedPhone  = emergencyPhone.trimmingCharacters(in: .whitespaces)

        if let child = existingChild {
            // Edit existing
            dataService.updateChild(
                child,
                name: trimmedName,
                age: age,
                room: room,
                allergies: allergies,
                dietaryRestrictions: dietaryRestrictions,
                medicalNotes: medicalNotes,
                emergencyContact: trimmedContact,
                emergencyPhone: trimmedPhone
            )
            onSave(child)
        } else {
            // Add new — insert directly into SampleDataProvider so it's visible immediately
            let newChild = Child(
                name: trimmedName,
                age: age,
                room: room,
                allergies: allergies,
                dietaryRestrictions: dietaryRestrictions,
                medicalNotes: medicalNotes,
                keyworkerName: SampleDataProvider.shared.currentKeyworkerName,
                emergencyContact: trimmedContact,
                emergencyPhone: trimmedPhone
            )
            SampleDataProvider.shared.sampleChildren.append(newChild)
            if !dataService.useSampleData {
                dataService.addChild(
                    name: trimmedName,
                    age: age,
                    room: room,
                    allergies: allergies,
                    dietaryRestrictions: dietaryRestrictions,
                    medicalNotes: medicalNotes,
                    emergencyContact: trimmedContact,
                    emergencyPhone: trimmedPhone
                )
            }
            onSave(newChild)
        }

        isSaving = false
        dismiss()
    }
}

#Preview("Add Mode") {
    AddEditChildView { _ in }
}

#Preview("Edit Mode") {
    AddEditChildView(
        existingChild: Child(
            name: "Oliver Taylor", age: 3, room: "Toddlers",
            allergies: ["Peanuts"],
            keyworkerName: "Sarah Jones",
            emergencyContact: "James Taylor",
            emergencyPhone: "07700 900123"
        )
    ) { _ in }
}
