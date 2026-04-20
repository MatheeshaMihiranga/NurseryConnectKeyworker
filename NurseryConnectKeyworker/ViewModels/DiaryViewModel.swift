//
//  DiaryViewModel.swift
//  NurseryConnectKeyworker
//
//  ViewModel for Daily Diary feature.
//  Manages diary entries, filtering, and entry creation.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class DiaryViewModel {
    var diaryEntries: [DiaryEntry] = []
    var selectedChild: Child?
    var selectedEntryType: DiaryEntryType?
    var searchText: String = ""
    
    private let dataService = DataService.shared
    
    // MARK: - Initialization
    
    init() {
        loadEntries()
    }
    
    // MARK: - Data Loading
    
    func loadEntries() {
        if let childId = selectedChild?.id {
            diaryEntries = dataService.getDiaryEntries(for: childId)
        } else {
            diaryEntries = dataService.getDiaryEntries()
        }
        diaryEntries.sort { $0.timestamp > $1.timestamp }
    }
    
    func refreshEntries() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        await MainActor.run {
            loadEntries()
        }
    }
    
    // MARK: - Filtering
    
    func filterByChild(_ child: Child?) {
        selectedChild = child
        loadEntries()
    }
    
    func filterByEntryType(_ type: DiaryEntryType?) {
        selectedEntryType = type
    }
    
    func clearFilters() {
        selectedChild = nil
        selectedEntryType = nil
        searchText = ""
    }
    
    // MARK: - Entry Creation
    
    func createEntry(_ entry: DiaryEntry) async {
        dataService.addDiaryEntry(
            type: entry.entryType,
            title: entry.title,
            description: entry.description,
            notes: entry.notes,
            childId: entry.childId,
            childName: entry.childName
        )
        await MainActor.run {
            loadEntries()
        }
    }
    
    // MARK: - Computed Properties
    
    var filteredEntries: [DiaryEntry] {
        var filtered = diaryEntries
        
        // Filter by type
        if let type = selectedEntryType {
            filtered = filtered.filter { $0.entryType == type }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.childName.localizedCaseInsensitiveContains(searchText) ||
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var entriesByDate: [Date: [DiaryEntry]] {
        let calendar = Calendar.current
        var grouped: [Date: [DiaryEntry]] = [:]
        
        for entry in filteredEntries {
            let dateKey = calendar.startOfDay(for: entry.timestamp)
            if grouped[dateKey] == nil {
                grouped[dateKey] = []
            }
            grouped[dateKey]?.append(entry)
        }
        
        return grouped
    }
    
    var sortedDates: [Date] {
        Array(entriesByDate.keys).sorted { $0 > $1 }
    }
    
    var totalEntriesCount: Int {
        diaryEntries.count
    }
    
    var todaysEntriesCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return diaryEntries.filter {
            calendar.isDate($0.timestamp, inSameDayAs: today)
        }.count
    }
    
    // MARK: - Adding Entries
    
    func addEntry(
        type: DiaryEntryType,
        title: String,
        description: String,
        notes: String?,
        childId: UUID,
        childName: String
    ) {
        dataService.addDiaryEntry(
            type: type,
            title: title,
            description: description,
            notes: notes,
            childId: childId,
            childName: childName
        )
        loadEntries()
    }
}
