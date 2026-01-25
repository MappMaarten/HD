//
//  LAWRouteSelector.swift
//  HD
//
//  Sheet selector for LAW routes, similar to HikeTypeSelector
//

import SwiftUI

struct LAWRouteSelector: View {
    let routes: [LAWRoute]
    @Binding var selectedRoute: LAWRoute?
    @State private var showSheet = false

    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack(spacing: HDSpacing.sm) {
                // Icon
                Image(systemName: "map")
                    .font(.body.weight(.medium))
                    .foregroundColor(HDColors.forestGreen)
                    .frame(width: 24)

                // Selected route name
                Text(selectedRoute?.name ?? "Kies route")
                    .font(.body.weight(.medium))
                    .foregroundColor(selectedRoute == nil ? HDColors.mutedGreen : HDColors.forestGreen)

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
            LAWRouteSelectorSheet(
                routes: routes,
                selectedRoute: $selectedRoute,
                isPresented: $showSheet
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Sheet Content

private struct LAWRouteSelectorSheet: View {
    let routes: [LAWRoute]
    @Binding var selectedRoute: LAWRoute?
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                HDColors.cream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(routes) { route in
                            routeRow(route)

                            if route.id != routes.last?.id {
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
                    Text("Kies route")
                        .font(.headline)
                        .foregroundColor(HDColors.forestGreen)
                }
            }
        }
    }

    private func routeRow(_ route: LAWRoute) -> some View {
        let isSelected = selectedRoute?.id == route.id

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedRoute = route
            }
            // Slight delay before dismissing for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPresented = false
            }
        } label: {
            HStack(spacing: HDSpacing.sm) {
                // Icon
                Image(systemName: "map")
                    .foregroundColor(HDColors.forestGreen)
                    .frame(width: 24)

                // Route name and stages count
                VStack(alignment: .leading, spacing: 2) {
                    Text(route.name)
                        .foregroundColor(HDColors.forestGreen)

                    Text("\(route.stagesCount) etappes")
                        .font(.caption)
                        .foregroundColor(HDColors.mutedGreen)
                }

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
        LAWRouteSelector(
            routes: [
                LAWRoute(name: "Pieterpad", stagesCount: 26),
                LAWRoute(name: "Pelgrimspad", stagesCount: 18),
                LAWRoute(name: "Floris V pad", stagesCount: 15)
            ],
            selectedRoute: .constant(nil)
        )

        LAWRouteSelector(
            routes: [
                LAWRoute(name: "Pieterpad", stagesCount: 26),
                LAWRoute(name: "Pelgrimspad", stagesCount: 18),
                LAWRoute(name: "Floris V pad", stagesCount: 15)
            ],
            selectedRoute: .constant(LAWRoute(name: "Pieterpad", stagesCount: 26))
        )
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
