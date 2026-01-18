import SwiftUI
import SwiftData

struct HikeTypesSettingsView: View {
    @Query(sort: \HikeType.sortOrder) private var hikeTypes: [HikeType]
    @Environment(\.modelContext) private var modelContext

    @State private var showAddSheet = false
    @State private var editingType: HikeType?

    var body: some View {
        List {
            ForEach(hikeTypes) { type in
                HStack {
                    Image(systemName: type.iconName)
                        .foregroundColor(.accentColor)
                        .frame(width: 30)

                    Text(type.name)
                        .font(.body)

                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingType = type
                }
            }
            .onDelete(perform: deleteTypes)
            .onMove(perform: moveTypes)
        }
        .navigationTitle("Wandeltypes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddHikeTypeView()
        }
        .sheet(item: $editingType) { type in
            EditHikeTypeView(hikeType: type)
        }
    }

    private func deleteTypes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(hikeTypes[index])
        }
    }

    private func moveTypes(from source: IndexSet, to destination: Int) {
        var updatedTypes = hikeTypes
        updatedTypes.move(fromOffsets: source, toOffset: destination)

        for (index, type) in updatedTypes.enumerated() {
            type.sortOrder = index
        }
    }
}

struct AddHikeTypeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var selectedIcon = "figure.walk"

    private let availableIcons = [
        "figure.walk", "figure.hiking", "sun.max", "calendar",
        "building.2", "tree", "mountain.2", "beach.umbrella",
        "signpost.right", "map", "location", "flag"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Naam") {
                    TextField("Bijv. Nachtelijke wandeling", text: $name)
                }

                Section("Icoon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                VStack {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? .white : .accentColor)
                                        .frame(width: 50, height: 50)
                                        .background(selectedIcon == icon ? Color.accentColor : Color.clear)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Nieuw Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Voeg toe") {
                        addHikeType()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addHikeType() {
        let newType = HikeType(
            name: name,
            iconName: selectedIcon,
            sortOrder: 999
        )

        modelContext.insert(newType)
        dismiss()
    }
}

struct EditHikeTypeView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var hikeType: HikeType

    private let availableIcons = [
        "figure.walk", "figure.hiking", "sun.max", "calendar",
        "building.2", "tree", "mountain.2", "beach.umbrella",
        "signpost.right", "map", "location", "flag"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Naam") {
                    TextField("Naam", text: $hikeType.name)
                }

                Section("Icoon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                hikeType.iconName = icon
                            } label: {
                                VStack {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(hikeType.iconName == icon ? .white : .accentColor)
                                        .frame(width: 50, height: 50)
                                        .background(hikeType.iconName == icon ? Color.accentColor : Color.clear)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Bewerk Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Klaar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HikeTypesSettingsView()
    }
    .modelContainer(for: HikeType.self, inMemory: true)
}
