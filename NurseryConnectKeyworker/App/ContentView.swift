//
//  ContentView.swift
//  NurseryConnectKeyworker
//
//  Root view that adapts to the device:
//  - iPad (regular width): NavigationSplitView with sidebar + detail columns
//  - iPhone (compact width): TabView with badges
//
//  Part A iPadOS extension: adds NavigationSplitView, keyboard shortcuts,
//  and Analytics as a new top-level destination.
//

import SwiftUI
import SwiftData

// MARK: - Navigation Destination

enum NavDestination: Hashable, CaseIterable {
    case home
    case children
    case diary
    case incidents
    case analytics
    case attendance
    case alerts

    var title: String {
        switch self {
        case .home:       return "Home"
        case .children:   return "My Children"
        case .diary:      return "Daily Diary"
        case .incidents:  return "Incidents"
        case .analytics:  return "Analytics"
        case .attendance: return "Attendance"
        case .alerts:     return "Alerts"
        }
    }

    var icon: String {
        switch self {
        case .home:       return "house.fill"
        case .children:   return "person.3.fill"
        case .diary:      return "book.fill"
        case .incidents:  return "exclamationmark.triangle.fill"
        case .analytics:  return "chart.bar.fill"
        case .attendance: return "checklist"
        case .alerts:     return "bell.fill"
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var alertsViewModel = AlertsViewModel()

    // iPad split view state
    @State private var selectedDestination: NavDestination? = .home
    // iPhone tab state
    @State private var selectedTab: Int = 0

    var body: some View {
        if sizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPad Layout (NavigationSplitView)

    private var iPadLayout: some View {
        NavigationSplitView {
            List(NavDestination.allCases, id: \.self, selection: $selectedDestination) { dest in
                Label(dest.title, systemImage: dest.icon)
                    .badge(badgeCount(for: dest))
                    .accessibilityLabel(accessibilityLabel(for: dest))
            }
            .navigationTitle("NurseryConnect")
            .listStyle(.sidebar)
        } detail: {
            NavigationStack {
                detailView(for: selectedDestination ?? .home)
            }
        }
        .onAppear { loadAlertsBadge() }
        // Keyboard shortcuts for iPad external keyboard
        .keyboardShortcut("1", modifiers: .command)
        .onReceive(NotificationCenter.default.publisher(for: .navigateToHome))    { _ in selectedDestination = .home }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToAlerts))  { _ in selectedDestination = .alerts }
    }

    // MARK: - iPhone Layout (TabView)

    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            MyChildrenView()
                .tabItem { Label("My Children", systemImage: "person.3.fill") }
                .tag(1)
            DiaryView()
                .tabItem { Label("Diary", systemImage: "book.fill") }
                .tag(2)
            IncidentReportView()
                .tabItem { Label("Incidents", systemImage: "exclamationmark.triangle.fill") }
                .tag(3)
            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }
                .tag(4)
            AttendanceView()
                .tabItem { Label("Attendance", systemImage: "checklist") }
                .tag(5)
            AlertsView()
                .tabItem { Label("Alerts", systemImage: "bell.fill") }
                .badge(alertsViewModel.unacknowledgedCount > 0 ? alertsViewModel.unacknowledgedCount : 0)
                .tag(6)
        }
        .tint(.blue)
        .onAppear {
            configureTabBarAppearance()
            loadAlertsBadge()
        }
        .onChange(of: selectedTab) { _, _ in loadAlertsBadge() }
    }

    // MARK: - Detail View Router

    @ViewBuilder
    private func detailView(for destination: NavDestination) -> some View {
        switch destination {
        case .home:       HomeView()
        case .children:   MyChildrenView()
        case .diary:      DiaryView()
        case .incidents:  IncidentReportView()
        case .analytics:  AnalyticsView()
        case .attendance: AttendanceView()
        case .alerts:     AlertsView()
        }
    }

    // MARK: - Helpers

    private func badgeCount(for dest: NavDestination) -> Int {
        switch dest {
        case .alerts:    return alertsViewModel.unacknowledgedCount
        case .incidents: return DataService.shared.getIncidents().filter(\.isPending).count
        default:         return 0
        }
    }

    private func accessibilityLabel(for dest: NavDestination) -> String {
        let count = badgeCount(for: dest)
        guard count > 0 else { return dest.title }
        return "\(dest.title), \(count) item\(count == 1 ? "" : "s")"
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private func loadAlertsBadge() {
        alertsViewModel.alerts = DataService.shared.getAlerts()
    }
}

// MARK: - Notification names for keyboard-shortcut navigation

extension Notification.Name {
    static let navigateToHome   = Notification.Name("navigateToHome")
    static let navigateToAlerts = Notification.Name("navigateToAlerts")
}

#Preview {
    ContentView()
        .modelContainer(PersistenceService.shared.container!)
}

