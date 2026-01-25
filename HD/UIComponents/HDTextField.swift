//
//  HDTextField.swift
//  HD
//
//  Design System - Custom styled text field with optional trailing content
//

import SwiftUI

struct HDTextField<TrailingContent: View>: View {
    let label: String?
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    let trailingContent: TrailingContent?

    init(
        _ placeholder: String,
        text: Binding<String>,
        label: String? = nil,
        icon: String? = nil,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.placeholder = placeholder
        self._text = text
        self.label = label
        self.icon = icon
        self.trailingContent = trailingContent()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            if let label = label {
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(HDColors.forestGreen)
            }

            HStack(spacing: HDSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(HDColors.forestGreen)
                        .frame(width: 20)
                }

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(HDColors.mutedGreen)
                    }
                    TextField("", text: $text)
                        .foregroundColor(HDColors.forestGreen)
                }

                if let trailing = trailingContent {
                    trailing
                }
            }
            .padding(HDSpacing.sm)
            .background(HDColors.sageGreen)
            .cornerRadius(HDSpacing.cornerRadiusSmall)
        }
    }
}

// MARK: - Convenience init without trailing content

extension HDTextField where TrailingContent == EmptyView {
    init(
        _ placeholder: String,
        text: Binding<String>,
        label: String? = nil,
        icon: String? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.label = label
        self.icon = icon
        self.trailingContent = nil
    }
}

// MARK: - GPS Button Component

struct GPSButton: View {
    let isLoading: Bool
    let hasLocation: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else if hasLocation {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(HDColors.forestGreen)
                } else {
                    Image(systemName: "location.fill")
                        .foregroundColor(HDColors.forestGreen)
                }
            }
            .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: HDSpacing.md) {
        HDTextField(
            "Voer je naam in",
            text: .constant(""),
            label: "Naam"
        )

        HDTextField(
            "Zoeken...",
            text: .constant("Test"),
            icon: "magnifyingglass"
        )

        HDTextField(
            "Locatie",
            text: .constant(""),
            label: "Startlocatie",
            icon: "mappin"
        )

        // With GPS button
        HDTextField(
            "Startlocatie",
            text: .constant(""),
            icon: "mappin"
        ) {
            GPSButton(isLoading: false, hasLocation: false) { }
        }

        // With GPS loading
        HDTextField(
            "Startlocatie",
            text: .constant(""),
            icon: "mappin"
        ) {
            GPSButton(isLoading: true, hasLocation: false) { }
        }

        // With GPS success
        HDTextField(
            "Amsterdam Centraal",
            text: .constant("Amsterdam Centraal"),
            icon: "mappin"
        ) {
            GPSButton(isLoading: false, hasLocation: true) { }
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
