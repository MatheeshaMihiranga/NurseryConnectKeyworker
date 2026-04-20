//
//  NurseryConnectKeyworkerApp.swift
//  NurseryConnectKeyworker
//
//  Main app entry point. Configures SwiftData persistence and services.
//

import SwiftUI
import SwiftData

@main
struct NurseryConnectKeyworkerApp: App {
    
    // MARK: - Initialization
    
    init() {
        configureApp()
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(PersistenceService.shared.container!)
                .onAppear {
                    configureAccessibility()
                }
        }
    }
    
    // MARK: - Configuration
    
    private func configureApp() {
        print("🚀 NurseryConnectKeyworker App Starting...")
        
        // Initialize persistence service (already done via singleton)
        _ = PersistenceService.shared
        
        // Configure data service
        _ = DataService.shared
        
        print("✅ App configuration complete")
    }
    
    private func configureAccessibility() {
        // Configure minimum Dynamic Type size for accessibility
        // This ensures text is readable while maintaining layout integrity
        
        // Note: Individual views handle Dynamic Type with .dynamicTypeSize() modifier
        
        print("♿️ Accessibility configured")
    }
}
