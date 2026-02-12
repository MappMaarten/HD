import SwiftUI
import SwiftData

struct HikeTypesSettingsView: View {
    @Query(sort: \HikeType.sortOrder) private var allHikeTypes: [HikeType]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // State for inline adding
    @State private var newTypeName = ""
    @State private var newTypeIcon = "figure.walk"
    @State private var isAddingNewType = false
    @State private var newTypeIconPickerVisible = false

    // State for expanded types
    @State private var expandedTypeIDs: Set<PersistentIdentifier> = []

    private let availableIcons = [
        "figure.walk", "figure.hiking", "sun.max",
        "building.2", "tree", "mountain.2", "beach.umbrella",
        "signpost.right", "map", "leaf", "tent",
        "binoculars", "dog", "camera",
        "arrow.triangle.turn.up.right.circle", "shoe.2",
        "water.waves", "snowflake"
    ]

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                titleSection
                explanationSection

                if allHikeTypes.filter({ !$0.name.lowercased().contains("law") }).isEmpty {
                    emptyState
                } else {
                    typesContent
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Back Button

    private var backButton: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(HDColors.forestGreen)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin - 12)
        .padding(.top, HDSpacing.sm)
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
            addTypeSection
                .padding(.horizontal, HDSpacing.horizontalMargin)

            Spacer()

            EmptyStateView(
                icon: "figure.walk",
                title: "Geen wandeltypes",
                message: "Voeg wandeltypes toe om je wandelingen te categoriseren.",
                actionTitle: nil,
                action: nil
            )

            Spacer()
        }
    }

    // MARK: - Types Content

    private var typesContent: some View {
        ScrollView {
            VStack(spacing: HDSpacing.md) {
                // Add new type section at top
                addTypeSection

                // Existing types
                ForEach(allHikeTypes.filter { !$0.name.lowercased().contains("law") }) { type in
                    typeCard(for: type)
                }
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
                            .frame(width: 20)

                        Text(type.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(HDColors.mutedGreen)
                    }
                    .contentShape(Rectangle())
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

                    HStack {
                        Spacer()
                        Button {
                            withAnimation { deleteType(type) }
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(HDColors.mutedGreen)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Add Type Section

    private var addTypeSection: some View {
        FormSection {
            VStack(alignment: .leading, spacing: HDSpacing.sm) {
                // Header (tap to toggle)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isAddingNewType.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)
                            .frame(width: 20)

                        Text("Nieuw type")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)

                        Spacer()

                        Image(systemName: isAddingNewType ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(HDColors.mutedGreen)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Expanded content
                if isAddingNewType {
                    Divider()
                        .background(HDColors.dividerColor)

                    // Name field and icon button row
                    HStack(spacing: HDSpacing.sm) {
                        HDTextField(
                            "Bijv. Dagwandeling",
                            text: $newTypeName,
                            icon: "figure.walk"
                        )

                        // Icon picker toggle button
                        Button {
                            newTypeIconPickerVisible.toggle()
                        } label: {
                            Image(systemName: newTypeIcon)
                                .font(.system(size: 16))
                                .foregroundColor(HDColors.forestGreen)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                                        .fill(HDColors.cream)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                                        .stroke(HDColors.dividerColor, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        // Add button
                        Button {
                            addType()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(newTypeName.isEmpty ? HDColors.mutedGreen.opacity(0.5) : HDColors.forestGreen)
                        }
                        .buttonStyle(.plain)
                        .disabled(newTypeName.isEmpty)
                    }

                    // Icon picker grid
                    if newTypeIconPickerVisible {
                        VStack(alignment: .leading, spacing: HDSpacing.sm) {
                            Text("Icoon")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(HDColors.forestGreen)

                            iconPickerGrid(selectedIcon: newTypeIcon) { icon in
                                newTypeIcon = icon
                            }
                        }
                    }
                }
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
        // Find the highest sortOrder and add 1 to ensure new type is at the bottom
        let maxSortOrder = allHikeTypes.map(\.sortOrder).max() ?? -1

        let newType = HikeType(
            name: newTypeName,
            iconName: newTypeIcon,
            sortOrder: maxSortOrder + 1
        )

        modelContext.insert(newType)

        // Reset form
        newTypeName = ""
        newTypeIcon = "figure.walk"
        newTypeIconPickerVisible = false
        isAddingNewType = false
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

    let type1 = HikeType(name: "LAW", iconName: "signpost.right", sortOrder: 0)
    let type2 = HikeType(name: "Dagwandeling", iconName: "sun.max", sortOrder: 1)
    let type3 = HikeType(name: "Bergtocht", iconName: "mountain.2", sortOrder: 2)
    let type4 = HikeType(name: "Stadswandeling", iconName: "building.2", sortOrder: 3)

    container.mainContext.insert(type1)
    container.mainContext.insert(type2)
    container.mainContext.insert(type3)
    container.mainContext.insert(type4)

    return NavigationStack {
        HikeTypesSettingsView()
    }
    .modelContainer(container)
}
