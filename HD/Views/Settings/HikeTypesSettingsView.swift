import SwiftUI
import SwiftData

struct HikeTypesSettingsView: View {
    @Query(sort: \HikeType.sortOrder) private var hikeTypes: [HikeType]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // State for inline adding
    @State private var newTypeName = ""
    @State private var newTypeIcon = "figure.walk"

    // State for expanded types
    @State private var expandedTypeIDs: Set<PersistentIdentifier> = []

    private let availableIcons = [
        "figure.walk", "figure.hiking", "sun.max", "calendar",
        "building.2", "tree", "mountain.2", "beach.umbrella",
        "signpost.right", "map", "location", "flag"
    ]

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                titleSection
                explanationSection

                if hikeTypes.isEmpty {
                    emptyState
                } else {
                    typesContent
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Terug")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(HDColors.forestGreen)
                }
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        HStack {
            Text("Wandeltypes")
                .hdHandwritten(size: 24)
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
        .padding(.bottom, HDSpacing.sm)
    }

    // MARK: - Explanation Section

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Wat zijn wandeltypes?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(HDColors.forestGreen)

            Text("Wandeltypes helpen je om je wandelingen te categoriseren. Maak types aan die passen bij jouw wandelstijl, zoals \"Dagwandeling\", \"Stadswandeling\" of \"Bergtocht\".")
                .font(.system(size: 13))
                .foregroundColor(HDColors.mutedGreen)
                .lineSpacing(2)
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.bottom, HDSpacing.md)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: HDSpacing.lg) {
            Spacer()

            EmptyStateView(
                icon: "figure.walk",
                title: "Geen wandeltypes",
                message: "Voeg wandeltypes toe om je wandelingen te categoriseren.",
                actionTitle: nil,
                action: nil
            )

            Spacer()

            // Add type section at bottom
            addTypeSection
                .padding(.horizontal, HDSpacing.horizontalMargin)
                .padding(.bottom, HDSpacing.lg)
        }
    }

    // MARK: - Types Content

    private var typesContent: some View {
        ScrollView {
            VStack(spacing: HDSpacing.md) {
                // Existing types
                ForEach(hikeTypes) { type in
                    typeCard(for: type)
                }

                // Add new type section
                addTypeSection
            }
            .padding(.horizontal, HDSpacing.horizontalMargin)
            .padding(.bottom, HDSpacing.lg)
        }
    }

    // MARK: - Type Card

    private func typeCard(for type: HikeType) -> some View {
        let isExpanded = expandedTypeIDs.contains(type.id)

        return FormSection {
            VStack(alignment: .leading, spacing: HDSpacing.sm) {
                // Header row
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if isExpanded {
                            expandedTypeIDs.remove(type.id)
                        } else {
                            expandedTypeIDs.insert(type.id)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: type.iconName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)

                        Text(type.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(HDColors.mutedGreen)
                    }
                }
                .buttonStyle(.plain)

                // Expanded content
                if isExpanded {
                    Divider()
                        .background(HDColors.dividerColor)

                    // Icon picker
                    VStack(alignment: .leading, spacing: HDSpacing.sm) {
                        Text("Icoon")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)

                        iconPickerGrid(selectedIcon: type.iconName) { icon in
                            type.iconName = icon
                        }
                    }

                    // Delete button
                    Button {
                        withAnimation {
                            deleteType(type)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                            Text("Verwijder type")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.red.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HDSpacing.xs)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Add Type Section

    private var addTypeSection: some View {
        FormSection(title: "Nieuw type", icon: "plus") {
            VStack(spacing: HDSpacing.md) {
                HDTextField(
                    "Bijv. Dagwandeling",
                    text: $newTypeName,
                    icon: "figure.walk"
                )

                // Icon picker
                VStack(alignment: .leading, spacing: HDSpacing.sm) {
                    Text("Icoon")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(HDColors.forestGreen)

                    iconPickerGrid(selectedIcon: newTypeIcon) { icon in
                        newTypeIcon = icon
                    }
                }

                Button {
                    addType()
                } label: {
                    Text("Toevoegen")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HDSpacing.sm)
                        .background(newTypeName.isEmpty ? HDColors.mutedGreen.opacity(0.5) : HDColors.forestGreen)
                        .cornerRadius(HDSpacing.cornerRadiusSmall)
                }
                .buttonStyle(.plain)
                .disabled(newTypeName.isEmpty)
            }
        }
    }

    // MARK: - Icon Picker Grid

    private func iconPickerGrid(selectedIcon: String, onSelect: @escaping (String) -> Void) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: HDSpacing.sm) {
            ForEach(availableIcons, id: \.self) { icon in
                Button {
                    onSelect(icon)
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(selectedIcon == icon ? .white : HDColors.forestGreen)
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                                .fill(selectedIcon == icon ? HDColors.forestGreen : HDColors.cream)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                                .stroke(selectedIcon == icon ? HDColors.forestGreen : HDColors.dividerColor, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Actions

    private func addType() {
        let newType = HikeType(
            name: newTypeName,
            iconName: newTypeIcon,
            sortOrder: hikeTypes.count
        )

        modelContext.insert(newType)

        // Reset form
        newTypeName = ""
        newTypeIcon = "figure.walk"
    }

    private func deleteType(_ type: HikeType) {
        expandedTypeIDs.remove(type.id)
        modelContext.delete(type)
    }
}

#Preview {
    NavigationStack {
        HikeTypesSettingsView()
    }
    .modelContainer(for: HikeType.self, inMemory: true)
}

#Preview("With Types") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HikeType.self, configurations: config)

    let type1 = HikeType(name: "Dagwandeling", iconName: "sun.max", sortOrder: 0)
    let type2 = HikeType(name: "Bergtocht", iconName: "mountain.2", sortOrder: 1)
    let type3 = HikeType(name: "Stadswandeling", iconName: "building.2", sortOrder: 2)

    container.mainContext.insert(type1)
    container.mainContext.insert(type2)
    container.mainContext.insert(type3)

    return NavigationStack {
        HikeTypesSettingsView()
    }
    .modelContainer(container)
}
