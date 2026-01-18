import SwiftUI

struct ActiveHikeView: View {
    @State private var viewModel: ActiveHikeViewModel
    @State private var selectedTab = 0

    init(hike: Hike) {
        _viewModel = State(initialValue: ActiveHikeViewModel(hike: hike))
    }

    var isCompleted: Bool {
        viewModel.hike.status == "completed"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            StoryTabView(viewModel: viewModel)
                .tabItem {
                    Label("Verhaal", systemImage: "book")
                }
                .tag(0)

            ObservationsTabView(viewModel: viewModel)
                .tabItem {
                    Label("Observaties", systemImage: "eye")
                }
                .tag(1)

            AudioTabView(viewModel: viewModel)
                .tabItem {
                    Label("Audio", systemImage: "waveform")
                }
                .tag(2)

            PhotosTabView(viewModel: viewModel)
                .tabItem {
                    Label("Foto's", systemImage: "photo")
                }
                .tag(3)

            // Only show Finish tab for in-progress hikes
            if !isCompleted {
                FinishTabView(viewModel: viewModel)
                    .tabItem {
                        Label("Afronden", systemImage: "checkmark.circle")
                    }
                    .tag(4)
            }
        }
        .navigationTitle(viewModel.hike.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ActiveHikeView(
            hike: Hike(
                status: "inProgress",
                name: "Test Wandeling",
                type: "Dagwandeling",
                startMood: 8
            )
        )
    }
}
