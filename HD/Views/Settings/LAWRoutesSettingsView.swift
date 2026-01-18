import SwiftUI
import SwiftData

struct LAWRoutesSettingsView: View {
    @Query(sort: \LAWRoute.sortOrder) private var lawRoutes: [LAWRoute]
    @Environment(\.modelContext) private var modelContext

    @State private var showAddSheet = false
    @State private var editingRoute: LAWRoute?

    var body: some View {
        Group {
            if lawRoutes.isEmpty {
                emptyState
            } else {
                routesList
            }
        }
        .navigationTitle("LAW Routes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }

            if !lawRoutes.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddLAWRouteView()
        }
        .sheet(item: $editingRoute) { route in
            EditLAWRouteView(lawRoute: route)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            EmptyStateView(
                icon: "signpost.right",
                title: "Geen LAW Routes",
                message: "Voeg je favoriete langeafstandswandelingen toe",
                actionTitle: "Voeg Route Toe",
                action: {
                    showAddSheet = true
                }
            )
        }
    }

    private var routesList: some View {
        List {
            ForEach(lawRoutes) { route in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(route.name)
                            .font(.body)

                        Text("\(route.stagesCount) etappe(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "signpost.right")
                        .foregroundColor(.accentColor)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingRoute = route
                }
            }
            .onDelete(perform: deleteRoutes)
            .onMove(perform: moveRoutes)
        }
    }

    private func deleteRoutes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(lawRoutes[index])
        }
    }

    private func moveRoutes(from source: IndexSet, to destination: Int) {
        var updatedRoutes = lawRoutes
        updatedRoutes.move(fromOffsets: source, toOffset: destination)

        for (index, route) in updatedRoutes.enumerated() {
            route.sortOrder = index
        }
    }
}

struct AddLAWRouteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var stagesCount = 1

    var body: some View {
        NavigationStack {
            Form {
                Section("Route Informatie") {
                    TextField("Naam", text: $name)

                    Stepper("Aantal etappes: \(stagesCount)", value: $stagesCount, in: 1...100)
                }
            }
            .navigationTitle("Nieuwe LAW Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Voeg toe") {
                        addRoute()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func addRoute() {
        let newRoute = LAWRoute(
            name: name,
            stagesCount: stagesCount,
            sortOrder: 999
        )

        modelContext.insert(newRoute)
        dismiss()
    }
}

struct EditLAWRouteView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var lawRoute: LAWRoute

    var body: some View {
        NavigationStack {
            Form {
                Section("Route Informatie") {
                    TextField("Naam", text: $lawRoute.name)

                    Stepper("Aantal etappes: \(lawRoute.stagesCount)", value: $lawRoute.stagesCount, in: 1...100)
                }
            }
            .navigationTitle("Bewerk LAW Route")
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
        LAWRoutesSettingsView()
    }
    .modelContainer(for: LAWRoute.self, inMemory: true)
}

#Preview("With Routes") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LAWRoute.self, configurations: config)

    let route1 = LAWRoute(name: "Pieterpad", stagesCount: 26, sortOrder: 0)
    let route2 = LAWRoute(name: "Pelgrimspad", stagesCount: 18, sortOrder: 1)

    container.mainContext.insert(route1)
    container.mainContext.insert(route2)

    return NavigationStack {
        LAWRoutesSettingsView()
    }
    .modelContainer(container)
}
