//
//  FormSection.swift
//  HD
//
//  Reusable card-style container for form sections
//

import SwiftUI

struct FormSection<Content: View>: View {
    let title: String?
    let icon: String?
    let content: Content

    init(
        title: String? = nil,
        icon: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HDSpacing.md) {
            // Header with icon and title
            if let title = title {
                HStack(spacing: HDSpacing.xs) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(HDColors.mutedGreen)
                    }

                    Text(title.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundColor(HDColors.mutedGreen)
                        .tracking(0.5)
                }
            }

            // Content
            content
        }
        .padding(HDSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HDColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: HDSpacing.md) {
        FormSection(title: "Details", icon: "pencil") {
            VStack(spacing: HDSpacing.sm) {
                Text("Content goes here")
                    .foregroundColor(HDColors.forestGreen)
                Text("More content")
                    .foregroundColor(HDColors.mutedGreen)
            }
        }

        FormSection(title: "Locatie", icon: "mappin") {
            Text("Location content")
                .foregroundColor(HDColors.forestGreen)
        }

        FormSection {
            Text("Section without header")
                .foregroundColor(HDColors.forestGreen)
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
