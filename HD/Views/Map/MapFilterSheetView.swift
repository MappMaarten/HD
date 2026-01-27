//
//  MapFilterSheetView.swift
//  HD
//
//  Filter sheet for map with type and period filters
//

import SwiftUI
import SwiftData

// MARK: - Time Period Enum

enum TimePeriod: String, CaseIterable, Identifiable {
    case all = "Alle periodes"
    case thisWeek = "Deze week"
    case thisMonth = "Deze maand"
    case thisYear = "Dit jaar"
    case lastYear = "Vorig jaar"

    var id: String { rawValue }

    func matches(date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .all:
            return true
        case .thisWeek:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .thisMonth:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .thisYear:
            return calendar.isDate(date, equalTo: now, toGranularity: .year)
        case .lastYear:
            guard let lastYear = calendar.date(byAdding: .year, value: -1, to: now) else {
                return false
            }
            return calendar.isDate(date, equalTo: lastYear, toGranularity: .year)
        }
    }
}

// MARK: - Filter Sheet View

struct MapFilterSheetView: View {
    @Binding var selectedTypeFilters: Set<String>
    @Binding var selectedTimePeriod: TimePeriod
    @Query(sort: \HikeType.sortOrder) private var hikeTypes: [HikeType]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                HDColors.cream
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: HDSpacing.lg) {
                        // Type filter section
                        typeFilterSection

                        // Period filter section
                        periodFilterSection

                        Spacer(minLength: HDSpacing.xl)
                    }
                    .padding(.horizontal, HDSpacing.horizontalMargin)
                    .padding(.top, HDSpacing.md)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(HDColors.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        selectedTypeFilters.removeAll()
                        selectedTimePeriod = .all
                    }
                    .foregroundColor(HDColors.forestGreen)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Klaar") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(HDColors.forestGreen)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    // MARK: - Type Filter Section

    private var typeFilterSection: some View {
        VStack(alignment: .leading, spacing: HDSpacing.sm) {
            SectionHeader(
                title: "Type wandeling",
                subtitle: "Selecteer een of meerdere types"
            )

            VStack(spacing: HDSpacing.xs) {
                ForEach(hikeTypes) { hikeType in
                    TypeFilterRow(
                        icon: hikeType.iconName,
                        name: hikeType.name,
                        isSelected: selectedTypeFilters.contains(hikeType.name),
                        action: { toggleTypeFilter(hikeType.name) }
                    )
                }
            }
        }
    }

    // MARK: - Period Filter Section

    private var periodFilterSection: some View {
        VStack(alignment: .leading, spacing: HDSpacing.sm) {
            SectionHeader(
                title: "Periode",
                subtitle: "Filter op tijdsperiode"
            )

            VStack(spacing: HDSpacing.xs) {
                ForEach(TimePeriod.allCases) { period in
                    PeriodRow(
                        period: period,
                        isSelected: selectedTimePeriod == period,
                        action: {
                            selectedTimePeriod = period
                        }
                    )
                }
            }
        }
    }

    private func toggleTypeFilter(_ typeName: String) {
        if selectedTypeFilters.contains(typeName) {
            selectedTypeFilters.remove(typeName)
        } else {
            selectedTypeFilters.insert(typeName)
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)

                Text(text)
                    .font(.subheadline)
            }
            .foregroundColor(isSelected ? .white : HDColors.forestGreen)
            .padding(.horizontal, HDSpacing.sm)
            .padding(.vertical, HDSpacing.xs)
            .background(isSelected ? HDColors.forestGreen : HDColors.sageGreen)
            .cornerRadius(HDSpacing.cornerRadiusMedium)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Period Row

private struct PeriodRow: View {
    let period: TimePeriod
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(period.rawValue)
                    .font(.body)
                    .foregroundColor(isSelected ? .white : HDColors.forestGreen)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(HDColors.mutedGreen)
                }
            }
            .padding(HDSpacing.cardPadding)
            .background(isSelected ? HDColors.forestGreen : HDColors.cardBackground)
            .cornerRadius(HDSpacing.cornerRadiusMedium)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Type Filter Row

private struct TypeFilterRow: View {
    let icon: String
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: HDSpacing.sm) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(isSelected ? .white : HDColors.forestGreen)
                    .frame(width: 24)

                Text(name)
                    .font(.body)
                    .foregroundColor(isSelected ? .white : HDColors.forestGreen)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "square")
                        .foregroundColor(HDColors.mutedGreen)
                }
            }
            .padding(HDSpacing.cardPadding)
            .background(isSelected ? HDColors.forestGreen : HDColors.cardBackground)
            .cornerRadius(HDSpacing.cornerRadiusMedium)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let viewSize = subview.sizeThatFits(.unspecified)

                if currentX + viewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, viewSize.height)
                currentX += viewSize.width + spacing

                size.width = max(size.width, currentX - spacing)
            }

            size.height = currentY + lineHeight
        }
    }
}

#Preview {
    MapFilterSheetView(
        selectedTypeFilters: .constant(["Boswandeling"]),
        selectedTimePeriod: .constant(.all)
    )
}
