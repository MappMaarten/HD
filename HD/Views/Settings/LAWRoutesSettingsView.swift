import SwiftUI
import SwiftData

struct LAWRoutesSettingsView: View {
    @Query(sort: \LAWRoute.sortOrder) private var lawRoutes: [LAWRoute]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // State for inline adding
    @State private var newRouteName = ""
    @State private var newStagesCount = 10

    // State for expanded routes
    @State private var expandedRouteIDs: Set<PersistentIdentifier> = []

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                titleSection
                explanationSection

                if lawRoutes.isEmpty {
                    emptyState
                } else {
                    routesContent
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
            Text("LAW Routes")
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
            Text("Wat zijn LAW Routes?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(HDColors.forestGreen)

            Text("Langeafstandswandelroutes (LAW) zijn bewegwijzerde wandelroutes door heel Nederland en daarbuiten. Bekende voorbeelden zijn het Pieterpad, Pelgrimspad en het Westerborkpad. Voeg hier je favoriete routes toe om je voortgang per etappe bij te houden.")
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
                icon: "signpost.right",
                title: "Geen LAW Routes",
                message: "Voeg je favoriete langeafstandswandelingen toe om je voortgang bij te houden.",
                actionTitle: nil,
                action: nil
            )

            Spacer()

            // Add route section at bottom
            addRouteSection
                .padding(.horizontal, HDSpacing.horizontalMargin)
                .padding(.bottom, HDSpacing.lg)
        }
    }

    // MARK: - Routes Content

    private var routesContent: some View {
        ScrollView {
            VStack(spacing: HDSpacing.md) {
                // Existing routes
                ForEach(lawRoutes) { route in
                    routeCard(for: route)
                }

                // Add new route section
                addRouteSection
            }
            .padding(.horizontal, HDSpacing.horizontalMargin)
            .padding(.bottom, HDSpacing.lg)
        }
    }

    // MARK: - Route Card

    private func routeCard(for route: LAWRoute) -> some View {
        let isExpanded = expandedRouteIDs.contains(route.id)

        return FormSection {
            VStack(alignment: .leading, spacing: HDSpacing.sm) {
                // Header row
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if isExpanded {
                            expandedRouteIDs.remove(route.id)
                        } else {
                            expandedRouteIDs.insert(route.id)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "signpost.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)

                        Text(route.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)

                        Spacer()

                        Text("\(route.stagesCount) etappes")
                            .font(.caption)
                            .foregroundColor(HDColors.mutedGreen)

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

                    // Edit controls
                    HStack {
                        Text("Aantal etappes")
                            .font(.system(size: 14))
                            .foregroundColor(HDColors.forestGreen)

                        Spacer()

                        HStack(spacing: HDSpacing.md) {
                            Button {
                                if route.stagesCount > 1 {
                                    route.stagesCount -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(route.stagesCount > 1 ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.5))
                            }
                            .buttonStyle(.plain)
                            .disabled(route.stagesCount <= 1)

                            Text("\(route.stagesCount)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(HDColors.forestGreen)
                                .frame(width: 32)

                            Button {
                                route.stagesCount += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(HDColors.forestGreen)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Delete button
                    Button {
                        withAnimation {
                            deleteRoute(route)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                            Text("Verwijder route")
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

    // MARK: - Add Route Section

    private var addRouteSection: some View {
        FormSection(title: "Nieuwe route", icon: "plus") {
            VStack(spacing: HDSpacing.md) {
                HDTextField(
                    "Bijv. Pieterpad",
                    text: $newRouteName,
                    icon: "signpost.right"
                )

                HStack {
                    Text("Aantal etappes")
                        .font(.system(size: 14))
                        .foregroundColor(HDColors.forestGreen)

                    Spacer()

                    HStack(spacing: HDSpacing.md) {
                        Button {
                            if newStagesCount > 1 {
                                newStagesCount -= 1
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(newStagesCount > 1 ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        .disabled(newStagesCount <= 1)

                        Text("\(newStagesCount)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)
                            .frame(width: 32)

                        Button {
                            newStagesCount += 1
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(HDColors.forestGreen)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    addRoute()
                } label: {
                    Text("Toevoegen")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HDSpacing.sm)
                        .background(newRouteName.isEmpty ? HDColors.mutedGreen.opacity(0.5) : HDColors.forestGreen)
                        .cornerRadius(HDSpacing.cornerRadiusSmall)
                }
                .buttonStyle(.plain)
                .disabled(newRouteName.isEmpty)
            }
        }
    }

    // MARK: - Actions

    private func addRoute() {
        let newRoute = LAWRoute(
            name: newRouteName,
            stagesCount: newStagesCount,
            sortOrder: lawRoutes.count
        )

        modelContext.insert(newRoute)

        // Reset form
        newRouteName = ""
        newStagesCount = 10
    }

    private func deleteRoute(_ route: LAWRoute) {
        expandedRouteIDs.remove(route.id)
        modelContext.delete(route)
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
