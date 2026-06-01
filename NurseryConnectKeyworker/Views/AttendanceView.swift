//
//  AttendanceView.swift
//  NurseryConnectKeyworker
//
//  Part A – New Feature: Daily Attendance Register.
//  Keyworkers mark each assigned child as Present / Late / Absent per session.
//  Shows a live attendance rate and daily summary stats.
//
//  iPad: uses a table-style layout with inline session/date picker in the sidebar.
//  iPhone: single-column scrollable list.
//

import SwiftUI

struct AttendanceView: View {
    @State private var viewModel = AttendanceViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date + session pickers
                controlsBar

                // Summary strip
                summaryStrip

                Divider()

                // Attendance list
                if viewModel.records.isEmpty {
                    ContentUnavailableView(
                        "No Children",
                        systemImage: "person.3",
                        description: Text("No assigned children found.")
                    )
                } else {
                    attendanceList
                }
            }
            .navigationTitle("Attendance Register")
            .toolbar { toolbarItems }
            .onChange(of: viewModel.selectedDate)   { _, _ in viewModel.loadRecords() }
            .onChange(of: viewModel.selectedSession) { _, _ in viewModel.loadRecords() }
            .onAppear { viewModel.loadChildren(); viewModel.loadRecords() }
        }
    }

    // MARK: - Controls Bar

    private var controlsBar: some View {
        HStack(spacing: 16) {
            // Date picker
            DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .accessibilityLabel("Select attendance date")

            Divider().frame(height: 28)

            // Session picker
            Picker("Session", selection: $viewModel.selectedSession) {
                ForEach(NurserySession.allCases, id: \.self) { session in
                    Text(session.rawValue).tag(session)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 280)
            .accessibilityLabel("Select nursery session")

            Spacer()

            // Mark all present shortcut
            Button {
                viewModel.markAllPresent()
            } label: {
                Label("All Present", systemImage: "checkmark.circle")
            }
            .buttonStyle(.bordered)
            .tint(.green)
            .accessibilityLabel("Mark all children as present")
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Summary Strip

    private var summaryStrip: some View {
        HStack(spacing: 0) {
            summaryTile(
                value: "\(viewModel.presentCount)",
                label: "Present",
                color: .green,
                icon: "checkmark.circle.fill"
            )
            Divider()
            summaryTile(
                value: "\(viewModel.lateCount)",
                label: "Late",
                color: .orange,
                icon: "clock.badge.exclamationmark.fill"
            )
            Divider()
            summaryTile(
                value: "\(viewModel.absentCount)",
                label: "Absent",
                color: .red,
                icon: "xmark.circle.fill"
            )
            Divider()
            summaryTile(
                value: String(format: "%.0f%%", viewModel.attendanceRate * 100),
                label: "Rate",
                color: rateColor,
                icon: "percent"
            )
        }
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
    }

    private var rateColor: Color {
        let r = viewModel.attendanceRate
        if r >= 0.9 { return .green }
        if r >= 0.7 { return .orange }
        return .red
    }

    private func summaryTile(value: String, label: String, color: Color, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Attendance List

    private var attendanceList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach($viewModel.records, id: \.id) { $record in
                    AttendanceRowView(
                        record: $record,
                        onStatusChange: { newStatus in
                            viewModel.setStatus(newStatus, for: record.childId)
                        },
                        onNoteChange: { note in
                            viewModel.setNote(note, for: record.childId)
                        },
                        onArrivalTimeChange: { time in
                            viewModel.setArrivalTime(time, for: record.childId)
                        }
                    )
                }
            }
            .padding()
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.loadRecords()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .keyboardShortcut("r", modifiers: .command)
            .accessibilityLabel("Refresh attendance records")
        }
    }
}

// MARK: - Attendance Row

struct AttendanceRowView: View {
    @Binding var record: AttendanceRecord
    let onStatusChange: (AttendanceStatus) -> Void
    let onNoteChange: (String) -> Void
    let onArrivalTimeChange: (Date) -> Void

    @State private var showNoteField = false
    @State private var noteText = ""
    @State private var arrivalTime = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row
            HStack(spacing: 14) {
                // Child info
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.childName)
                        .font(.headline)
                    if record.status == AttendanceStatus.late.rawValue,
                       let arrival = record.arrivalTime {
                        Text("Arrived: \(arrival, style: .time)")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                .frame(minWidth: 140, alignment: .leading)

                Spacer()

                // Status picker — segmented on iPad, menu on iPhone
                statusPicker
            }
            .padding()

            // Note area (expandable)
            if !record.note.isEmpty || showNoteField {
                Divider().padding(.horizontal)
                HStack(spacing: 10) {
                    Image(systemName: "note.text")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    TextField("Add note…", text: $noteText)
                        .font(.subheadline)
                        .onSubmit { onNoteChange(noteText) }
                        .onAppear { noteText = record.note }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            // Arrival time picker for late arrivals
            if record.status == AttendanceStatus.late.rawValue {
                Divider().padding(.horizontal)
                HStack(spacing: 10) {
                    Image(systemName: "clock")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    DatePicker("Arrival", selection: $arrivalTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: arrivalTime) { _, new in
                            onArrivalTimeChange(new)
                        }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .onAppear { arrivalTime = record.arrivalTime ?? Date() }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.07), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(currentStatus.color.opacity(0.4), lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.childName) – \(record.status)")
    }

    private var currentStatus: AttendanceStatus {
        AttendanceStatus(rawValue: record.status) ?? .present
    }

    private var statusPicker: some View {
        HStack(spacing: 8) {
            ForEach(AttendanceStatus.allCases, id: \.self) { status in
                Button {
                    onStatusChange(status)
                } label: {
                    Label(status.rawValue, systemImage: status.icon)
                        .labelStyle(.iconOnly)
                        .font(.title3)
                        .foregroundStyle(record.status == status.rawValue ? status.color : Color.secondary.opacity(0.4))
                        .scaleEffect(record.status == status.rawValue ? 1.15 : 1.0)
                        .animation(.spring(response: 0.2), value: record.status)
                }
                .accessibilityLabel("Mark \(record.childName) as \(status.rawValue)")
            }

            // Note toggle
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showNoteField.toggle()
                }
            } label: {
                Image(systemName: showNoteField || !record.note.isEmpty
                      ? "note.text.badge.plus"
                      : "note.text")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Toggle note for \(record.childName)")
        }
    }
}

#Preview {
    AttendanceView()
}
