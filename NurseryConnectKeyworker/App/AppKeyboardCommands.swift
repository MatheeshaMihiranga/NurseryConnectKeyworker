//
//  AppKeyboardCommands.swift
//  NurseryConnectKeyworker
//
//  iPad keyboard shortcut commands (Part A iPadOS platform-specific feature).
//  External keyboard users can navigate the app without touching the screen.
//

import SwiftUI

struct AppKeyboardCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            // Navigation shortcuts
            Button("Go to Home") {
                NotificationCenter.default.post(name: .navigateToHome, object: nil)
            }
            .keyboardShortcut("1", modifiers: .command)

            Button("Go to Alerts") {
                NotificationCenter.default.post(name: .navigateToAlerts, object: nil)
            }
            .keyboardShortcut("5", modifiers: .command)
        }

        CommandMenu("NurseryConnect") {
            Button("Refresh Data") {
                NotificationCenter.default.post(name: .refreshData, object: nil)
            }
            .keyboardShortcut("r", modifiers: .command)
        }
    }
}

extension Notification.Name {
    static let refreshData = Notification.Name("refreshData")
}
