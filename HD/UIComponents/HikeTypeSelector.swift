//
//  HikeTypeSelector.swift
//  HD
//
//  Tap-to-select row that opens a sheet with type options
//

import SwiftUI

struct HikeTypeSelector: View {
    let types: [HikeType]
    @Binding var selectedType: HikeType?
    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack(spacing: HDSpacing.sm) {
                // Color indicator dot
                if let selectedType = selectedType {
                    Circle()
                        .fill(selectedType.displayColor)
                        .frame(width: 10, height: 10)
                }

                // Icon with type color
                Image(systemName: selectedType?.iconName ?? "figure.walk")
                    .font(.body.weight(.medium))
                    .foregroundColor(selectedType?.displayColor ?? HDColors.mutedGreen)
                    .frame(width: 24)

                // Selected type name
                Text(selectedType?.name ?? "Kies type wandeling")
                    .font(.body.weight(.medium))
                    .foregroundColor(selectedType == nil ? HDColors.mutedGreen : HDColors.forestGreen)

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(HDColors.mutedGreen.opacity(0.7))
            }
            .padding(.horizontal, HDSpacing.md)
            .padding(.vertical, HDSpacing.md)
            .background(HDColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            HikeTypeSelectorSheet(
                types: types,
                selectedType: $selectedType,
                isPresented: $showSheet
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Sheet Content

private struct HikeTypeSelectorSheet: View {
    let types: [HikeType]
    @Binding var selectedType: HikeType?
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                HDColors.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(types) { type in
                            typeRow(type)

                            if type.id != types.last?.id {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .padding(.horizontal, HDSpacing.horizontalMargin)
                    .padding(.top, HDSpacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(HDColors.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Kies type wandeling")
                        .font(.headline)
                        .foregroundColor(HDColors.forestGreen)
                }
            }
        }
    }

    private func typeRow(_ type: HikeType) -> some View {
        let isSelected = selectedType?.id == type.id

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedType = type
            }
            // Slight delay before dismissing for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPresented = false
            }
        } label: {
            HStack(spacing: HDSpacing.sm) {
                // Colored vertical accent bar
                Rectangle()
                    .fill(type.displayColor)
                    .frame(width: 4)
                    .cornerRadius(2)

                // Icon with type color
                Image(systemName: type.iconName)
                    .foregroundColor(type.displayColor)
                    .frame(width: 24)

                // Type name
                Text(type.name)
                    .foregroundColor(HDColors.forestGreen)

                Spacer()

                // Checkmark with type color
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body.weight(.semibold))
                        .foregroundColor(type.displayColor)
                }
            }
            .font(.body)
            .padding(.vertical, HDSpacing.md)
            .background(isSelected ? type.displayColor.opacity(0.08) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: HDSpacing.lg) {
        HikeTypeSelector(
            types: [
                HikeType(name: "Dagwandeling", iconName: "figure.walk"),
                HikeType(name: "LAW", iconName: "map"),
                HikeType(name: "Stadswandeling", iconName: "building.2"),
                HikeType(name: "Boswandeling", iconName: "tree")
            ],
            selectedType: .constant(nil)
        )

        HikeTypeSelector(
            types: [
                HikeType(name: "Dagwandeling", iconName: "figure.walk"),
                HikeType(name: "LAW", iconName: "map"),
                HikeType(name: "Stadswandeling", iconName: "building.2"),
                HikeType(name: "Boswandeling", iconName: "tree")
            ],
            selectedType: .constant(HikeType(name: "LAW", iconName: "map"))
        )
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
