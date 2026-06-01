//
//  ObservationNotesView.swift
//  NurseryConnectKeyworker
//
//  Part A – iPadOS platform-specific feature + Advanced Library:
//  Handwritten child observation notes using PencilKit.
//
//  Keyworkers can draw/write freehand EYFS observations with Apple Pencil,
//  then save them linked to a specific child. Notes are stored as PNG data
//  in UserDefaults keyed by child UUID (a full implementation would use SwiftData
//  with @Attribute(.externalStorage) Binary data).
//
//  PencilKit is on the Approved Advanced Libraries list (Media & Communication /
//  Document & Rendering category) and is a native iPadOS capability.
//

import SwiftUI
import PencilKit

// MARK: - View

struct ObservationNotesView: View {
    let child: Child

    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var isSaved = false
    @State private var showClearConfirm = false
    @State private var savedNotes: [SavedObservation] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Canvas
                CanvasViewRepresentable(
                    canvasView: $canvasView,
                    toolPicker: toolPicker
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding()
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)

                // Saved observations strip
                if !savedNotes.isEmpty {
                    savedNotesStrip
                }
            }
            .navigationTitle("Observation Notes – \(child.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarItems }
            .alert("Clear canvas?", isPresented: $showClearConfirm) {
                Button("Clear", role: .destructive) { canvasView.drawing = PKDrawing() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will erase the current drawing. Saved observations are not affected.")
            }
            .overlay(alignment: .top) {
                if isSaved {
                    savedBanner
                }
            }
            .onAppear {
                savedNotes = ObservationStore.load(for: child.id)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") { dismiss() }
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                saveObservation()
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .accessibilityLabel("Save observation note")
        }
        ToolbarItem(placement: .secondaryAction) {
            Button(role: .destructive) {
                showClearConfirm = true
            } label: {
                Label("Clear Canvas", systemImage: "trash")
            }
            .accessibilityLabel("Clear canvas")
        }
    }

    // MARK: - Saved Notes Strip

    private var savedNotesStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Saved Observations (\(savedNotes.count))")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(savedNotes) { note in
                        savedNoteThumb(note)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
    }

    private func savedNoteThumb(_ note: SavedObservation) -> some View {
        VStack(spacing: 6) {
            if let img = UIImage(data: note.imageData) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
            }
            Text(note.dateLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("Saved observation from \(note.dateLabel)")
    }

    // MARK: - Save Banner

    private var savedBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Observation saved!")
                .font(.subheadline.bold())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.thinMaterial, in: Capsule())
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Actions

    private func saveObservation() {
        guard !canvasView.drawing.strokes.isEmpty else { return }

        let image = canvasView.drawing.image(from: canvasView.drawing.bounds, scale: 1.5)
        guard let data = image.pngData() else { return }

        let observation = SavedObservation(
            id: UUID(),
            childId: child.id,
            imageData: data,
            date: Date()
        )

        ObservationStore.save(observation, for: child.id)
        savedNotes = ObservationStore.load(for: child.id)

        withAnimation(.spring(response: 0.3)) { isSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { isSaved = false }
        }
    }
}

// MARK: - UIViewRepresentable Bridge

struct CanvasViewRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let toolPicker: PKToolPicker

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.drawingPolicy = .anyInput  // Support both finger and Apple Pencil
        canvasView.backgroundColor = .systemBackground
        canvasView.isOpaque = true

        // Attach tool picker
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

// MARK: - Data Models

struct SavedObservation: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let imageData: Data
    let date: Date

    var dateLabel: String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }
}

// MARK: - Persistence (UserDefaults keyed by childId)

enum ObservationStore {
    private static func key(for childId: UUID) -> String { "observations_\(childId.uuidString)" }

    static func load(for childId: UUID) -> [SavedObservation] {
        guard let data = UserDefaults.standard.data(forKey: key(for: childId)),
              let decoded = try? JSONDecoder().decode([SavedObservation].self, from: data)
        else { return [] }
        return decoded.sorted { $0.date > $1.date }
    }

    static func save(_ observation: SavedObservation, for childId: UUID) {
        var existing = load(for: childId)
        existing.insert(observation, at: 0)
        // Cap at 20 observations per child to avoid excessive storage
        let capped = Array(existing.prefix(20))
        if let data = try? JSONEncoder().encode(capped) {
            UserDefaults.standard.set(data, forKey: key(for: childId))
        }
    }
}

#Preview {
    ObservationNotesView(
        child: Child(
            name: "Oliver Taylor", age: 3, room: "Toddlers",
            keyworkerName: "Sarah Jones",
            emergencyContact: "James Taylor", emergencyPhone: "07700 900123"
        )
    )
}
