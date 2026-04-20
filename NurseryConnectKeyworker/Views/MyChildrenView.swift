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
    @State private var selectedEntryType: DiaryEntryType?
    @State private var selectedChildForAction: Child?
    
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
                                }
                            )
                            .onTapGesture {
                                viewModel.selectChild(child)
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
            .onAppear {
                viewModel.loadChildren()
            }
            .sheet(isPresented: $showingAddEntry) {
                if let child = selectedChildForAction, let type = selectedEntryType {
                    AddDiaryEntryView(
                        preselectedChild: child,
                        preselectedType: type
                    )
                }
            }
            .sheet(isPresented: $showingIncidentReport) {
                if let child = selectedChildForAction {
                    IncidentReportFormView(preselectedChild: child)
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
}

#Preview {
    MyChildrenView()
}
