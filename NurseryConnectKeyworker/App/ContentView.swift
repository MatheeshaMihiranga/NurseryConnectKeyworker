//
//  ContentView.swift
//  NurseryConnectKeyworker
//
//  Root view with TabView navigation for 5 main app areas.
//  Displays badge for unacknowledged alerts.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var alertsViewModel = AlertsViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home Dashboard
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
                .accessibilityLabel("Home tab")
            
            // Tab 2: My Children
            MyChildrenView()
                .tabItem {
                    Label("My Children", systemImage: "person.3.fill")
                }
                .tag(1)
                .accessibilityLabel("My Children tab")
            
            // Tab 3: Daily Diary
            DiaryView()
                .tabItem {
                    Label("Diary", systemImage: "book.fill")
                }
                .tag(2)
                .accessibilityLabel("Diary tab")
            
            // Tab 4: Incident Reports
            IncidentReportView()
                .tabItem {
                    Label("Incidents", systemImage: "exclamationmark.triangle.fill")
                }
                .tag(3)
                .accessibilityLabel("Incidents tab")
            
            // Tab 5: Alerts & Reminders
            AlertsView()
                .tabItem {
                    Label {
                        Text("Alerts")
                    } icon: {
                        Image(systemName: "bell.fill")
                    }
                }
                .badge(alertsViewModel.unacknowledgedCount > 0 ? alertsViewModel.unacknowledgedCount : 0)
                .tag(4)
                .accessibilityLabel("Alerts tab with \(alertsViewModel.unacknowledgedCount) unread alerts")
        }
        .tint(.blue)
        .onAppear {
            configureTabBarAppearance()
            loadAlertsBadge()
        }
        .onChange(of: selectedTab) { _, _ in
            // Refresh alerts badge when switching tabs
            if selectedTab != 4 {
                loadAlertsBadge()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func configureTabBarAppearance() {
        // Configure tab bar to be opaque with background
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        print("✅ TabBar appearance configured")
    }
    
    private func loadAlertsBadge() {
        alertsViewModel.alerts = DataService.shared.getAlerts()
    }
}

#Preview {
    ContentView()
        .modelContainer(PersistenceService.shared.container!)
}

