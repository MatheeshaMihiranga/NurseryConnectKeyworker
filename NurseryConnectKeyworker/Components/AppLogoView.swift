//
//  AppLogoView.swift
//  NurseryConnectKeyworker
//
//  Reusable app logo component used in the HomeView header and app branding.
//  Drawn entirely with SwiftUI shapes — no external image assets required.
//

import SwiftUI

/// NurseryConnect Keyworker app logo.
/// Shows two stylised figures (adult + child) inside a circular badge
/// with a soft blue-to-teal gradient background.
struct AppLogoView: View {
    /// Controls the rendered size of the circular badge.
    var size: CGFloat = 72

    var body: some View {
        ZStack {
            // Background circle with brand gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.18, green: 0.50, blue: 0.93),
                                 Color(red: 0.08, green: 0.72, blue: 0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            // Outer ring
            Circle()
                .strokeBorder(.white.opacity(0.35), lineWidth: size * 0.03)
                .frame(width: size, height: size)

            // Icon: adult + child holding hands
            Image(systemName: "figure.and.child.holdinghands")
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.52, height: size * 0.52)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
        }
        .accessibilityLabel("NurseryConnect Keyworker logo")
        .accessibilityHidden(true)
    }
}

// MARK: - Brand Header

/// Full-width branding row used at the top of the home screen.
struct AppBrandHeader: View {
    var body: some View {
        HStack(spacing: 14) {
            AppLogoView(size: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text("NurseryConnect")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.18, green: 0.50, blue: 0.93),
                                     Color(red: 0.08, green: 0.72, blue: 0.72)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Keyworker")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("NurseryConnect Keyworker")
    }
}

#Preview {
    VStack(spacing: 32) {
        AppLogoView(size: 120)
        AppBrandHeader()
            .padding()
    }
    .padding()
}
