//
//  MyChildrenView.swift
//  NurseryConnectKeyworker
//
//  Displays list of assigned children with quick action buttons for logging
//  activities and reporting incidents.
//

import SwiftUI

struct MyChildrenView: View {
    @State private var viewModel = ChildrenViewModel()
    @State private var showingAddEntry = false
    @State private var showingIncidentReport = false
    @State private var showingObservationNotes = false
    @State private var showingAddChild = false
    @State private var childToEdit: Child? = nil
    @State private var childToDelete: Child? = nil
    @State private var showDeleteConfirm = false
    @State private var selectedEntryType: DiaryEntryType?
    @State private var selectedChildForAction: Child?
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.filteredChildren.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.filteredChildren, id: \.id) { child in
                            ChildCard(
                                child: child,
                                onLogMeal: {
                                    handleQuickAction(child: child, entryType: .meal)
                                },
                                onLogNap: {
                                    handleQuickAction(child: child, entryType: .nap)
                                },
                                onLogMood: {
                                    handleQuickAction(child: child, entryType: .mood)
                                },
                                onReportIncident: {
                                    handleIncidentReport(child: child)
                                },
                                onObservationNotes: sizeClass == .regular ? {
                                    handleObservationNotes(child: child)
                                } : nil
                            )
                            .transition(.asymmetric(
                                insertion: .push(from: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                            .onTapGesture {
                                viewModel.selectChild(child)
                            }
                            // Long-press context menu: Edit or Delete
                            .contextMenu {
                                Button {
                                    childToEdit = child
                                } label: {
                                    Label("Edit Child", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    childToDelete = child
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Delete Child", systemImage: "trash")
                                }
                            }
                            // iPadOS drag-and-drop
                            .draggable(child.name) {
                                Label(child.name, systemImage: child.photoName)
                                    .padding(10)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Children")
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search by name or room"
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddChild = true
                    } label: {
                        Label("Add Child", systemImage: "person.badge.plus")
                    }
                    .accessibilityLabel("Add new child")
                }
            }
            .onAppear {
                viewModel.loadChildren()
            }
            // Add child
            .sheet(isPresented: $showingAddChild) {
                AddEditChildView { _ in
                    viewModel.loadChildren()
                }
            }
            // Edit child (long-press context menu)
            .sheet(item: $childToEdit) { child in
                AddEditChildView(existingChild: child) { _ in
                    viewModel.loadChildren()
                }
            }
            // Delete confirmation
            .confirmationDialog(
                "Delete \(childToDelete?.name ?? "this child")?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let child = childToDelete {
                        viewModel.deleteChild(child)
                    }
                    childToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    childToDelete = nil
                }
            } message: {
                Text("This will permanently remove the child and all their records. This action cannot be undone.")
            }
            // Diary entry sheet
            .sheet(isPresented: $showingAddEntry) {
                if let child = selectedChildForAction, let type = selectedEntryType {
                    AddDiaryEntryView(
                        preselectedChild: child,
                        preselectedType: type
                    )
                }
            }
            // Incident report sheet
            .sheet(isPresented: $showingIncidentReport) {
                if let child = selectedChildForAction {
                    IncidentReportFormView(preselectedChild: child)
                }
            }
            // Observation notes sheet
            .sheet(isPresented: $showingObservationNotes) {
                if let child = selectedChildForAction {
                    ObservationNotesView(child: child)
                }
            }
            .accessibilityLabel("My assigned children list")
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Children Found",
            systemImage: "person.3",
            description: Text(viewModel.searchText.isEmpty ?
                "You don't have any assigned children yet" :
                "No children match '\(viewModel.searchText)'"
            )
        )
        .frame(minHeight: 400)
        .accessibilityLabel("No children found")
    }
    
    // MARK: - Action Handlers
    
    private func handleQuickAction(child: Child, entryType: DiaryEntryType) {
        selectedChildForAction = child
        selectedEntryType = entryType
        showingAddEntry = true
    }
    
    private func handleIncidentReport(child: Child) {
        selectedChildForAction = child
        showingIncidentReport = true
    }

    private func handleObservationNotes(child: Child) {
        selectedChildForAction = child
        showingObservationNotes = true
    }
}


#Preview {
    MyChildrenView()
}
