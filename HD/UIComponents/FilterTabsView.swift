//
//  FilterTabsView.swift
//  HD
//
//  Horizontal filter tabs for filtering hikes by status
//

import SwiftUI

enum HikeFilter: String, CaseIterable {
    case all = "Alles"
    case inProgress = "Onderweg"
    case completed = "Voltooid"

    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .inProgress: return "circle.dashed"
        case .completed: return "checkmark.circle"
        }
    }
}

struct FilterTabsView: View {
    @Binding var selectedFilter: HikeFilter

    var body: some View {
        HStack(spacing: HDSpacing.sm) {
            ForEach(HikeFilter.allCases, id: \.self) { filter in
                filterTab(for: filter)
            }
        }
    }

    private func filterTab(for filter: HikeFilter) -> some View {
        let isSelected = selectedFilter == filter

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFilter = filter
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(isSelected ? .white : HDColors.forestGreen)
            .padding(.horizontal, HDSpacing.md)
            .padding(.vertical, HDSpacing.xs)
            .background(isSelected ? HDColors.forestGreen : HDColors.sageGreen)
            .cornerRadius(HDSpacing.cornerRadiusLarge)
            .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: HDSpacing.lg) {
        FilterTabsView(selectedFilter: .constant(.all))
        FilterTabsView(selectedFilter: .constant(.inProgress))
        FilterTabsView(selectedFilter: .constant(.completed))
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
