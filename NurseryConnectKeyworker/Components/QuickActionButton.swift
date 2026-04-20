//
//  QuickActionButton.swift
//  NurseryConnectKeyworker
//
//  Reusable large button for quick actions.
//  80pt width, 44pt+ tap target for accessibility.
//

import SwiftUI

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundStyle(color)
                    }
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 80)
        }
        .accessibilityLabel(label)
        .accessibilityHint("Tap to \(label.lowercased())")
        .accessibilityAddTraits(.isButton)
    }
}
