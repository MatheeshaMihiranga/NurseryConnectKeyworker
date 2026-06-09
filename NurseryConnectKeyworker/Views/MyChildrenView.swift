//
//  MyChildrenView.swift
//  NurseryConnectKeyworker
//
//  Displays list of assigned children with quick action buttons for logging
//  activities and reporting incidents.
//

import SwiftUI

// Single enum drives all sheet presentations — avoids multiple .sheet modifier bug
private enum ActiveSheet: Identifiable {
    case addEntry(Child, DiaryEntryType)
    case incidentReport(Child)
    case observationNotes(Child)
    case addChild
    case editChild(Child)

    var id: String {
        switch self {
        case .addEntry(let c, let t):   return "addEntry-\(c.id)-\(t.rawValue)"
        case .incidentReport(let c):    return "incident-\(c.id)"
        case .observationNotes(let c):  return "observe-\(c.id)"
        case .addChild:                 return "addChild"
        case .editChild(let c):         return "editChild-\(c.id)"
        }
    }
}

struct MyChildrenView: View {
    @State private var viewModel = ChildrenViewModel()
    @State private var activeSheet: ActiveSheet? = nil
    @State private var childToDelete: Child? = nil
    @State private var showDeleteConfirm = false
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
                                    activeSheet = .observationNotes(child)
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
                                    activeSheet = .editChild(child)
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
                        activeSheet = .addChild
                    } label: {
                        Label("Add Child", systemImage: "person.badge.plus")
                    }
                    .accessibilityLabel("Add new child")
                }
            }
            .onAppear {
                viewModel.loadChildren()
            }
            // Single sheet — all cases handled here
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .addEntry(let child, let type):
                    AddDiaryEntryView(preselectedChild: child, preselectedType: type)
                case .incidentReport(let child):
                    IncidentReportFormView(preselectedChild: child)
                case .observationNotes(let child):
                    ObservationNotesView(child: child)
                case .addChild:
                    AddEditChildView { _ in viewModel.loadChildren() }
                case .editChild(let child):
                    AddEditChildView(existingChild: child) { _ in viewModel.loadChildren() }
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
        activeSheet = .addEntry(child, entryType)
    }
    
    private func handleIncidentReport(child: Child) {
        activeSheet = .incidentReport(child)
    }
}


#Preview {
    MyChildrenView()
}
