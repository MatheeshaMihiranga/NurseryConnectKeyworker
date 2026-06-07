//
//  AddEditChildView.swift
//  NurseryConnectVision
//
//  Spatial form for adding a new child or editing an existing child.
//  Presented as a visionOS sheet anchored in space.
//
//  Fields:
//  - Name (TextField)
//  - Age (Stepper 1–5)
//  - Room (Picker: Baby Room / Toddlers / Pre-school)
//  - Allergies (add/remove tags)
//  - Dietary Restrictions (add/remove tags)
//  - Medical Notes (TextEditor)
//  - Emergency Contact + Phone (TextField)
//  - Initial Mood (Slider 1–5)
//

import SwiftUI

struct AddEditChildView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismiss) private var dismiss

    // nil = Add mode, non-nil = Edit mode
    let editingChild: VisionChild?

    // Form state
    @State private var name: String = ""
    @State private var age: Int = 2
    @State private var room: String = "Toddlers"
    @State private var allergiesText: String = ""
    @State private var allergiesList: [String] = []
    @State private var dietaryText: String = ""
    @State private var dietaryList: [String] = []
    @State private var medicalNotes: String = ""
    @State private var emergencyContact: String = ""
    @State private var emergencyPhone: String = ""
    @State private var moodAverage: Double = 4.0

    @State private var showValidationAlert = false

    private var isEditing: Bool { editingChild != nil }
    private var title: String { isEditing ? "Edit Child" : "Add Child" }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Basic Info
                Section {
                    TextField("Full name", text: $name)
                        .accessibilityLabel("Child's full name")

                    Stepper("Age: \(age) \(age == 1 ? "year" : "years")", value: $age, in: 0...10)
                        .accessibilityLabel("Age: \(age) years")

                    Picker("Room", selection: $room) {
                        ForEach(VisionChild.rooms, id: \.self) { r in
                            Text(r).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Room assignment")
                } header: {
                    Label("Basic Information", systemImage: "person.fill")
                }

                // MARK: Allergies
                Section {
                    tagEntryRow(
                        label: "Add allergy",
                        text: $allergiesText,
                        tags: $allergiesList,
                        accentColor: .red
                    )
                } header: {
                    Label("Allergies", systemImage: "exclamationmark.circle.fill")
                } footer: {
                    Text("Type an allergy and press Return to add it.")
                        .font(.caption)
                }

                // MARK: Dietary Restrictions
                Section {
                    tagEntryRow(
                        label: "Add restriction",
                        text: $dietaryText,
                        tags: $dietaryList,
                        accentColor: .orange
                    )
                } header: {
                    Label("Dietary Restrictions", systemImage: "fork.knife")
                }

                // MARK: Medical Notes
                Section {
                    TextEditor(text: $medicalNotes)
                        .frame(minHeight: 80)
                        .accessibilityLabel("Medical notes")
                } header: {
                    Label("Medical Notes", systemImage: "cross.fill")
                } footer: {
                    Text("Include conditions, medications, and special instructions.")
                        .font(.caption)
                }

                // MARK: Emergency Contact
                Section {
                    TextField("Parent / guardian name", text: $emergencyContact)
                        .accessibilityLabel("Emergency contact name")
                    TextField("Phone number", text: $emergencyPhone)
                        .keyboardType(.phonePad)
                        .accessibilityLabel("Emergency contact phone")
                } header: {
                    Label("Emergency Contact", systemImage: "phone.fill")
                }

                // MARK: Initial Mood
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Mood rating")
                            Spacer()
                            Text("\(moodEmoji(for: moodAverage))  \(String(format: "%.1f", moodAverage)) / 5")
                                .font(.headline)
                        }
                        Slider(value: $moodAverage, in: 1...5, step: 0.5)
                            .tint(moodColor(for: moodAverage))
                            .accessibilityLabel("Mood rating slider")
                        HStack {
                            Text("😢").font(.caption)
                            Spacer()
                            Text("😐").font(.caption)
                            Spacer()
                            Text("😄").font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Current Mood", systemImage: "face.smiling.fill")
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save Changes" : "Add Child") {
                        guard validate() else { showValidationAlert = true; return }
                        commit()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Required Field", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter the child's name before saving.")
            }
            .onAppear { loadExistingChildIfEditing() }
        }
        .frame(minWidth: 540, minHeight: 640)
    }

    // MARK: - Tag Entry Row

    @ViewBuilder
    private func tagEntryRow(
        label: String,
        text: Binding<String>,
        tags: Binding<[String]>,
        accentColor: Color
    ) -> some View {
        // Existing tags
        if !tags.wrappedValue.isEmpty {
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
                            .buttonStyle(.plain)
                            .accessibilityLabel("Remove \(tag)")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(accentColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(accentColor)
                    }
                }
                .padding(.vertical, 2)
            }
        }

        // Input field
        HStack {
            TextField(label, text: text)
                .onSubmit {
                    let trimmed = text.wrappedValue.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty && !tags.wrappedValue.contains(trimmed) {
                        tags.wrappedValue.append(trimmed)
                    }
                    text.wrappedValue = ""
                }
            if !text.wrappedValue.isEmpty {
                Button {
                    let trimmed = text.wrappedValue.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty && !tags.wrappedValue.contains(trimmed) {
                        tags.wrappedValue.append(trimmed)
                    }
                    text.wrappedValue = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add \(text.wrappedValue)")
            }
        }
    }

    // MARK: - Validation & Commit

    private func validate() -> Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func commit() {
        if isEditing, let existing = editingChild {
            var updated = existing
            updated.name = name.trimmingCharacters(in: .whitespaces)
            updated.age = age
            updated.room = room
            updated.allergies = allergiesList
            updated.dietaryRestrictions = dietaryList
            updated.medicalNotes = medicalNotes
            updated.emergencyContact = emergencyContact
            updated.emergencyPhone = emergencyPhone
            updated.moodAverage = moodAverage
            appModel.updateChild(updated)
        } else {
            let child = VisionChild(
                name: name.trimmingCharacters(in: .whitespaces),
                age: age,
                room: room,
                allergies: allergiesList,
                dietaryRestrictions: dietaryList,
                medicalNotes: medicalNotes,
                emergencyContact: emergencyContact,
                emergencyPhone: emergencyPhone,
                moodAverage: moodAverage
            )
            appModel.addChild(child)
        }
    }

    private func loadExistingChildIfEditing() {
        guard let child = editingChild else { return }
        name = child.name
        age = child.age
        room = child.room
        allergiesList = child.allergies
        dietaryList = child.dietaryRestrictions
        medicalNotes = child.medicalNotes
        emergencyContact = child.emergencyContact
        emergencyPhone = child.emergencyPhone
        moodAverage = child.moodAverage
    }

    // MARK: - Helpers

    private func moodEmoji(for rating: Double) -> String {
        switch rating {
        case 4.5...: return "😄"
        case 3.5..<4.5: return "🙂"
        case 2.5..<3.5: return "😐"
        case 1.5..<2.5: return "🙁"
        default: return "😢"
        }
    }

    private func moodColor(for rating: Double) -> Color {
        switch rating {
        case 4.0...: return .green
        case 3.0..<4.0: return .blue
        case 2.0..<3.0: return .yellow
        default: return .red
        }
    }
}

#Preview {
    AddEditChildView(editingChild: nil)
        .environment(AppModel())
}
