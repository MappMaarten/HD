import SwiftUI

struct ActiveHikeView: View {
    @State private var viewModel: ActiveHikeViewModel
    @State private var selectedTab = 0

    init(hike: Hike) {
        _viewModel = State(initialValue: ActiveHikeViewModel(hike: hike))

        // Configure navigation bar appearance for dark text
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(HDColors.cream)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(HDColors.forestGreen)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(HDColors.forestGreen)]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var isCompleted: Bool {
        viewModel.hike.status == "completed"
    }

    private var tabs: [(icon: String, title: String)] {
        var tabList: [(icon: String, title: String)] = [
            ("book", "Verhaal"),
            ("eye", "Observaties"),
            ("waveform", "Audio"),
            ("photo", "Foto's")
        ]

        // Only show Finish tab for in-progress hikes
        if !isCompleted {
            tabList.append(("checkmark.circle", "Afronden"))
        }

        return tabList
    }

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            Group {
                switch selectedTab {
                case 0: StoryTabView(viewModel: viewModel)
                case 1: ObservationsTabView(viewModel: viewModel)
                case 2: AudioTabView(viewModel: viewModel)
                case 3: PhotosTabView(viewModel: viewModel)
                case 4: FinishTabView(viewModel: viewModel)
                default: StoryTabView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            HDTabBar(selectedTab: $selectedTab, tabs: tabs)
        }
        .background(HDColors.cream)
        .navigationTitle(viewModel.hike.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(HDColors.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .preferredColorScheme(.light)
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
