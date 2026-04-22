//
//  AlertBadge.swift
//  NurseryConnectKeyworker
//
//  Reusable component for displaying alerts with priority color-coding.
//  Fully accessible with action buttons.
//

import SwiftUI

struct AlertBadge: View {
    let alert: AlertItem
    let onAcknowledge: () -> Void
    let onDismiss: () -> Void

    @State private var isPulsing = false
    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with priority indicator
            HStack(spacing: 12) {
                Circle()
                    .fill(priorityColor)
                    .frame(width: 12, height: 12)
                    .accessibilityLabel("\(alert.priority.rawValue) priority")
                
                Image(systemName: alert.alertType.icon)
                    .font(.title3)
                    .foregroundStyle(priorityColor)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(alert.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if alert.childId != nil {
                        Text(alert.childName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(alert.alertType.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if !alert.isAcknowledged {
                    Circle()
                        .fill(.blue)
                        .frame(width: 10, height: 10)
                        .scaleEffect(isPulsing ? 1.4 : 1.0)
                        .opacity(isPulsing ? 0.5 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                        .accessibilityLabel("Unacknowledged")
                }
            }
            
            // Message
            Text(alert.message)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Timeline info
            HStack {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(alert.relativeTime)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                if let acknowledgedAt = alert.acknowledgedAt {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                        Text("Acknowledged")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Action buttons (if not acknowledged)
            if !alert.isAcknowledged {
                HStack(spacing: 12) {
                    Button(action: onAcknowledge) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Acknowledge")
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.blue)
                        .cornerRadius(8)
                    }
                    .buttonStyle(BounceButtonStyle())
                    
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color(.systemGray))
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("Dismiss alert")
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityColor.opacity(0.4), lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint(alert.isAcknowledged ? "" : "Double tap acknowledge button to mark as read")
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 12)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
            if !alert.isAcknowledged {
                isPulsing = true
            }
        }
    }
    
    private var priorityColor: Color {
        switch alert.priority {
        case .low: return .blue
        case .medium: return .yellow
        case .high: return .orange
        case .urgent: return .red
        case .critical: return .red
        }
    }
    
    private var accessibilityText: String {
        var text = "\(alert.priority.rawValue) priority alert. \(alert.title). \(alert.message). "
        if let childId = alert.childId {
            text += "For \(alert.childName). "
        }
        text += "\(alert.relativeTime). "
        text += alert.isAcknowledged ? "Acknowledged." : "Not acknowledged."
        return text
    }
}

// MARK: - Bounce Button Style

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
