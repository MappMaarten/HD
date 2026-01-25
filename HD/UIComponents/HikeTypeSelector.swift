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
                // Icon
                Image(systemName: selectedType?.iconName ?? "figure.walk")
                    .foregroundColor(HDColors.forestGreen)
                    .frame(width: 24)

                // Selected type name
                Text(selectedType?.name ?? "Kies type wandeling")
                    .foregroundColor(selectedType == nil ? HDColors.mutedGreen : HDColors.forestGreen)

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(HDColors.mutedGreen)
            }
            .font(.body)
            .padding(HDSpacing.sm)
            .background(HDColors.sageGreen)
            .cornerRadius(HDSpacing.cornerRadiusSmall)
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
            .navigationTitle("Kies type wandeling")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(HDColors.cream, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
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
                // Icon
                Image(systemName: type.iconName)
                    .foregroundColor(HDColors.forestGreen)
                    .frame(width: 24)

                // Type name
                Text(type.name)
                    .foregroundColor(HDColors.forestGreen)

                Spacer()

                // Checkmark for selected
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundColor(HDColors.forestGreen)
                }
            }
            .font(.body)
            .padding(.vertical, HDSpacing.md)
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
                HikeType(name: "LAW-route", iconName: "map"),
                HikeType(name: "Stadswandeling", iconName: "building.2"),
                HikeType(name: "Boswandeling", iconName: "tree")
            ],
            selectedType: .constant(nil)
        )

        HikeTypeSelector(
            types: [
                HikeType(name: "Dagwandeling", iconName: "figure.walk"),
                HikeType(name: "LAW-route", iconName: "map"),
                HikeType(name: "Stadswandeling", iconName: "building.2"),
                HikeType(name: "Boswandeling", iconName: "tree")
            ],
            selectedType: .constant(HikeType(name: "LAW-route", iconName: "map"))
        )
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
