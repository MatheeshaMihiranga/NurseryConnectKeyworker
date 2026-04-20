//
//  SectionHeader.swift
//  NurseryConnectKeyworker
//
//  Reusable section header with icon and optional action button.
//

import SwiftUI

struct SectionHeader<Trailing: View>: View {
    let title: String
    let icon: String?
    let trailing: Trailing?
    
    init(
        title: String,
        icon: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.icon = icon
        self.trailing = trailing()
    }
    
    init(
        title: String,
        icon: String? = nil
    ) where Trailing == EmptyView {
        self.title = title
        self.icon = icon
        self.trailing = nil
    }
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .accessibilityHidden(true)
            }
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if let trailing = trailing {
                trailing
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

// Empty state view
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}
