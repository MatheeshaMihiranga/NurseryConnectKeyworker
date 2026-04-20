//
//  HomeView.swift
//  NurseryConnectKeyworker
//
//  Home Dashboard with overview statistics, critical alerts, recent diary entries,
//  and pending incidents. Provides quick access to key information.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var showAllAlerts = false
    @State private var showAllEntries = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Section
                    welcomeSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Critical Alerts Section
                    if !viewModel.criticalAlerts.isEmpty {
                        criticalAlertsSection
                    }
                    
                    // Recent Diary Entries
                    recentEntriesSection
                    
                    // Pending Incidents
                    if !viewModel.pendingIncidents.isEmpty {
                        pendingIncidentsSection
                    }
                    
                    // Overdue Logs Warning
                    if viewModel.overdueCount > 0 {
                        overdueWarningSection
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                viewModel.loadDashboardData()
            }
            .accessibilityLabel("Home dashboard with overview of assigned children, alerts, and recent entries")
        }
    }
    
    // MARK: - Welcome Section
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back!")
                .font(.title)
                .bold()
            
            Text("You have \(viewModel.assignedChildren.count) assigned children today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Welcome back! You have \(viewModel.assignedChildren.count) assigned children today")
    }
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Today's Overview", icon: "chart.bar.fill")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    icon: "book.fill",
                    title: "Diary Entries",
                    value: "\(viewModel.recentDiaryEntries.count)",
                    color: .blue
                )
                
                StatCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "Pending Incidents",
                    value: "\(viewModel.pendingIncidents.count)",
                    color: .orange
                )
                
                StatCard(
                    icon: "bell.fill",
                    title: "Critical Alerts",
                    value: "\(viewModel.criticalAlerts.count)",
                    color: .red
                )
                
                StatCard(
                    icon: "clock.fill",
                    title: "Overdue Logs",
                    value: "\(viewModel.overdueCount)",
                    color: viewModel.overdueCount > 0 ? .yellow : .green
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Today's overview statistics")
    }
    
    // MARK: - Critical Alerts Section
    
    private var criticalAlertsSection: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Critical Alerts",
                icon: "bell.fill",
                trailing: {
                    NavigationLink {
                        Text("Alerts View Placeholder")
                    } label: {
                        Text("View All")
                            .font(.subheadline)
                    }
                }
            )
            
            ForEach(Array(viewModel.criticalAlerts.prefix(3)), id: \.id) { alert in
                AlertBadge(alert: alert, onAcknowledge: {
                    // Optionally handle acknowledge from Home
                }, onDismiss: {
                    // Optionally handle dismiss from Home
                })
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Critical alerts section with \(viewModel.criticalAlerts.count) alerts")
    }
    
    // MARK: - Recent Entries Section
    
    private var recentEntriesSection: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Recent Diary Entries",
                icon: "book.fill",
                trailing: {
                    NavigationLink {
                        Text("Diary View Placeholder")
                    } label: {
                        Text("View All")
                            .font(.subheadline)
                    }
                }
            )
            
            if viewModel.recentDiaryEntries.isEmpty {
                ContentUnavailableView(
                    "No Recent Entries",
                    systemImage: "book.closed",
                    description: Text("Start logging activities for your assigned children")
                )
                .frame(minHeight: 150)
            } else {
                ForEach(viewModel.recentDiaryEntries, id: \.id) { entry in
                    DiaryEntryCard(entry: entry)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Recent diary entries section showing last \(viewModel.recentDiaryEntries.count) entries")
    }
    
    // MARK: - Pending Incidents Section
    
    private var pendingIncidentsSection: some View {
        VStack(spacing: 12) {
            SectionHeader(
                title: "Pending Incidents",
                icon: "exclamationmark.triangle.fill",
                trailing: {
                    NavigationLink {
                        Text("Incidents View Placeholder")
                    } label: {
                        Text("View All")
                            .font(.subheadline)
                    }
                }
            )
            
            ForEach(Array(viewModel.pendingIncidents.prefix(2)), id: \.id) { incident in
                IncidentCard(incident: incident, onMarkParentNotified: {
                    // Optionally handle from Home
                }, onMarkManagerReviewed: {
                    // Optionally handle from Home
                })
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Pending incidents section with \(viewModel.pendingIncidents.count) unreviewed incidents")
    }
    
    // MARK: - Overdue Warning Section
    
    private var overdueWarningSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.badge.exclamationmark.fill")
                .font(.title2)
                .foregroundStyle(.yellow)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Overdue Logs")
                    .font(.headline)
                Text("You have \(viewModel.overdueCount) log(s) that need attention")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.yellow.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Warning: You have \(viewModel.overdueCount) overdue logs that need attention")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                )
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title)
                    .bold()
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    HomeView()
}

