//
//  DiaryView.swift
//  NurseryConnectKeyworker
//
//  Displays diary entries grouped by date with filtering options.
//  Allows keyworkers to view and add daily care logs.
//

import SwiftUI

struct DiaryView: View {
    @State private var viewModel = DiaryViewModel()
    @State private var showingAddEntry = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Chips
                if !viewModel.diaryEntries.isEmpty {
                    filterChips
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
                
                // Main Content
                if viewModel.filteredEntries.isEmpty {
                    emptyState
                } else {
                    entriesList
                }
            }
            .navigationTitle("Daily Diary")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add new diary entry")
                    }
                }
                
                if viewModel.selectedEntryType != nil || !viewModel.searchText.isEmpty {
                    ToolbarItem(placement: .secondaryAction) {
                        Button("Clear Filters") {
                            viewModel.clearFilters()
                        }
                        .accessibilityLabel("Clear all filters")
                    }
                }
            }
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search entries..."
            )
            .refreshable {
                await viewModel.refreshEntries()
            }
            .onAppear {
                viewModel.loadEntries()
            }
            .sheet(isPresented: $showingAddEntry) {
                AddDiaryEntryView()
            }
        }
    }
    
    // MARK: - Filter Chips
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedEntryType == nil
                ) {
                    viewModel.selectedEntryType = nil
                }
                
                ForEach([DiaryEntryType.meal, .nap, .activity, .mood, .nappy], id: \.self) { type in
                    FilterChip(
                        title: type.rawValue.capitalized,
                        isSelected: viewModel.selectedEntryType == type
                    ) {
                        viewModel.selectedEntryType = type
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Entry type filters")
    }
    
    // MARK: - Entries List
    
    private var entriesList: some View {
        List {
            let groupedEntries = Dictionary(
                grouping: viewModel.filteredEntries,
                by: { Calendar.current.startOfDay(for: $0.timestamp) }
            )
            .sorted { $0.key > $1.key }
            
            ForEach(groupedEntries, id: \.key) { date, entries in
                Section {
                    ForEach(entries.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { entry in
                        DiaryEntryCard(entry: entry)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                    }
                } header: {
                    Text(date, style: .date)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .accessibilityAddTraits(.isHeader)
                }
            }
        }
        .listStyle(.plain)
        .accessibilityLabel("Diary entries list grouped by date")
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        ContentUnavailableView(
            viewModel.searchText.isEmpty ? "No Entries Yet" : "No Matching Entries",
            systemImage: "book.closed",
            description: Text(viewModel.searchText.isEmpty ?
                "Start logging daily activities for your assigned children" :
                "Try adjusting your search or filters"
            )
        )
        .accessibilityLabel(viewModel.searchText.isEmpty ? "No diary entries" : "No matching entries found")
    }
}

// MARK: - Filter Chip Component

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isSelected ? "Selected filter" : "Tap to filter by \(title)")
    }
}

#Preview {
    DiaryView()
}
