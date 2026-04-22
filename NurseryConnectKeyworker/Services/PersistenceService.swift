//
//  PersistenceService.swift
//  NurseryConnectKeyworker
//
//  Manages SwiftData ModelContainer and persistence layer.
//  Handles model configuration, context management, and sample data population.
//

import Foundation
import SwiftData

@MainActor
class PersistenceService {
    static let shared = PersistenceService()

    // MARK: - Properties

    private(set) var container: ModelContainer?
    private(set) var setupError: String?

    var mainContext: ModelContext {
        guard let container = container else {
            // Return a temporary in-memory container instead of crashing
            let schema = Schema([Child.self, DiaryEntry.self, IncidentReport.self, AlertItem.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            if let fallback = try? ModelContainer(for: schema, configurations: [config]) {
                return fallback.mainContext
            }
            fatalError("Unable to create even a fallback in-memory ModelContainer")
        }
        return container.mainContext
    }
    
    // MARK: - Configuration
    
    private var useSampleData: Bool = true // Toggle for testing vs production
    
    // MARK: - Initialization
    
    private init() {
        setupContainer()
    }
    
    // MARK: - Container Setup
    
    private func setupContainer() {
        do {
            // Define the schema with all models
            let schema = Schema([
                Child.self,
                DiaryEntry.self,
                IncidentReport.self,
                AlertItem.self
            ])
            
            // Configure persistence
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false, // Set to true for testing
                cloudKitDatabase: .none // No CloudKit sync for MVP
            )
            
            // Create container
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            print("✅ SwiftData ModelContainer initialized successfully")
            
            // Populate with sample data if needed
            if useSampleData {
                Task {
                    await populateWithSampleData()
                }
            }
            
        } catch {
            print("❌ Failed to initialize ModelContainer: \(error)")
            setupError = "Storage setup failed: \(error.localizedDescription). Using temporary storage."
            // Attempt an in-memory fallback so the app stays usable
            let schema = Schema([Child.self, DiaryEntry.self, IncidentReport.self, AlertItem.self])
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try? ModelContainer(for: schema, configurations: [fallbackConfig])
            if container != nil {
                print("⚠️ Falling back to in-memory storage")
            }
        }
    }
    
    // MARK: - Sample Data Population
    
    func populateWithSampleData() async {
        let context = mainContext
        
        // Check if data already exists
        let fetchDescriptor = FetchDescriptor<Child>()
        let existingChildren = try? context.fetch(fetchDescriptor)
        
        guard existingChildren?.isEmpty ?? true else {
            print("ℹ️ Sample data already exists, skipping population")
            return
        }
        
        print("📝 Populating database with sample data...")
        
        // Insert Children
        for child in SampleDataProvider.shared.sampleChildren {
            context.insert(child)
        }
        
        // Insert Diary Entries
        for entry in SampleDataProvider.shared.sampleDiaryEntries {
            context.insert(entry)
        }
        
        // Insert Incident Reports
        for incident in SampleDataProvider.shared.sampleIncidentReports {
            context.insert(incident)
        }
        
        // Insert Alerts
        for alert in SampleDataProvider.shared.sampleAlerts {
            context.insert(alert)
        }
        
        // Save context
        do {
            try context.save()
            print("✅ Sample data populated successfully")
        } catch {
            print("❌ Failed to save sample data: \(error)")
        }
    }
    
    // MARK: - Data Operations
    
    func save() {
        do {
            try mainContext.save()
            print("✅ Context saved successfully")
        } catch {
            print("❌ Failed to save context: \(error)")
        }
    }
    
    func delete<T: PersistentModel>(_ object: T) {
        mainContext.delete(object)
        save()
    }
    
    func deleteAll<T: PersistentModel>(type: T.Type) {
        do {
            let fetchDescriptor = FetchDescriptor<T>()
            let objects = try mainContext.fetch(fetchDescriptor)
            
            for object in objects {
                mainContext.delete(object)
            }
            
            try mainContext.save()
            print("✅ All \(T.self) objects deleted")
        } catch {
            print("❌ Failed to delete all objects: \(error)")
        }
    }
    
    func resetAllData() async {
        print("🗑️ Resetting all data...")
        
        deleteAll(type: Child.self)
        deleteAll(type: DiaryEntry.self)
        deleteAll(type: IncidentReport.self)
        deleteAll(type: AlertItem.self)
        
        await populateWithSampleData()
    }
    
    // MARK: - Fetch Operations
    
    func fetchChildren() -> [Child] {
        do {
            let fetchDescriptor = FetchDescriptor<Child>(
                sortBy: [SortDescriptor(\.name)]
            )
            return try mainContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to fetch children: \(error)")
            return []
        }
    }
    
    func fetchDiaryEntries() -> [DiaryEntry] {
        do {
            let fetchDescriptor = FetchDescriptor<DiaryEntry>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            return try mainContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to fetch diary entries: \(error)")
            return []
        }
    }
    
    func fetchIncidentReports() -> [IncidentReport] {
        do {
            let fetchDescriptor = FetchDescriptor<IncidentReport>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            return try mainContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to fetch incident reports: \(error)")
            return []
        }
    }
    
    func fetchAlerts() -> [AlertItem] {
        do {
            let fetchDescriptor = FetchDescriptor<AlertItem>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            return try mainContext.fetch(fetchDescriptor)
        } catch {
            print("❌ Failed to fetch alerts: \(error)")
            return []
        }
    }
}
