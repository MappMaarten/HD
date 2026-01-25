//
//  HDTabBar.swift
//  HD
//
//  Custom Tab Bar Component
//

import SwiftUI

struct HDTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, title: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                tabButton(index: index, icon: tab.icon, title: tab.title)
            }
        }
        .padding(.vertical, HDSpacing.sm)
        .background(HDColors.cardBackground)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: -2)
    }

    private func tabButton(index: Int, icon: String, title: String) -> some View {
        let isSelected = selectedTab == index

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.6))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        Spacer()
        HDTabBar(
            selectedTab: .constant(0),
            tabs: [
                ("book", "Verhaal"),
                ("eye", "Observaties"),
                ("waveform", "Audio"),
                ("photo", "Foto's"),
                ("checkmark.circle", "Afronden")
            ]
        )
    }
    .background(HDColors.cream)
}
