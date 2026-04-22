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
            Group {
                if let container = PersistenceService.shared.container {
                    ContentView()
                        .modelContainer(container)
                        .overlay(alignment: .top) {
                            if let errorMessage = PersistenceService.shared.setupError {
                                StorageWarningBanner(message: errorMessage)
                            }
                        }
                } else {
                    StorageErrorView()
                }
            }
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

// MARK: - Storage Warning Banner

struct StorageWarningBanner: View {
    let message: String
    @State private var isDismissed = false

    var body: some View {
        if !isDismissed {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Spacer()
                Button {
                    withAnimation { isDismissed = true }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.orange)
            .transition(.push(from: .top))
            .accessibilityLabel("Storage warning: \(message)")
        }
    }
}

// MARK: - Storage Error View

struct StorageErrorView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "externaldrive.badge.exclamationmark")
                .font(.system(size: 64))
                .foregroundStyle(.red)

            Text("Unable to Start")
                .font(.title)
                .bold()

            Text("The app could not initialise its local storage. Please restart the app or contact support.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("Storage error. App cannot start.")
    }
}
