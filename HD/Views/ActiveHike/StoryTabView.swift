import SwiftUI

struct StoryTabView: View {
    @Bindable var viewModel: ActiveHikeViewModel
    @FocusState private var isEditorFocused: Bool
    @StateObject private var keyboardObserver = KeyboardObserver()

    private let quickActionsHeight: CGFloat = 50
    private let tabBarHeight: CGFloat = 70 // Tab bar stays visible above keyboard

    private var wordCount: Int {
        let words = viewModel.hike.story
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        return words.count
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HDColors.cream.ignoresSafeArea(.all, edges: [.top, .leading, .trailing])

                VStack(spacing: 0) {
                    // Compact Quick Actions (bovenaan)
                    quickActionsBar
                        .padding(.top, HDSpacing.md)
                        .padding(.bottom, HDSpacing.sm)

                    // Story Card (vult rest van scherm)
                    storyCard()
                        .padding(.horizontal, HDSpacing.horizontalMargin)
                        .padding(.bottom, keyboardObserver.currentHeight > 0
                            ? max(0, keyboardObserver.currentHeight - tabBarHeight + HDSpacing.md)
                            : HDSpacing.md
                        )
                }
            }
        }
        .toolbarBackground(HDColors.cream, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    isEditorFocused = false
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(HDColors.forestGreen)
            }
        }
    }

    // MARK: - Quick Actions Bar

    private var quickActionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HDSpacing.xs) {
                QuickActionPill(
                    icon: "clock",
                    title: "Tijd",
                    action: { insertTimestamp() }
                )
                QuickActionPill(
                    icon: "eye",
                    title: "Observatie",
                    action: { insertObservation() }
                )
                QuickActionPill(
                    icon: "pause.circle",
                    title: "Pauze",
                    action: { insertPause() }
                )
                QuickActionPill(
                    icon: "hare",
                    title: "Dieren",
                    action: { insertAnimalSpotted() }
                )
                QuickActionPill(
                    icon: "person.2",
                    title: "Ontmoeting",
                    action: { insertMeeting() }
                )
            }
            .padding(.horizontal, HDSpacing.horizontalMargin)
        }
    }

    // MARK: - Story Card

    private func storyCard() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            HStack(spacing: HDSpacing.xs) {
                Image(systemName: "pencil.line")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(HDColors.mutedGreen)
                Text("JE VERHAAL")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(HDColors.mutedGreen)
                    .tracking(0.5)

                Spacer()

                if wordCount > 0 {
                    Text("\(wordCount) woorden")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(HDColors.mutedGreen.opacity(0.7))
                        .padding(.horizontal, HDSpacing.xs)
                        .padding(.vertical, 4)
                        .background(HDColors.sageGreen.opacity(0.3))
                        .cornerRadius(HDSpacing.cornerRadiusSmall)
                }
            }
            .padding(.horizontal, HDSpacing.md)
            .padding(.top, HDSpacing.md)
            .padding(.bottom, HDSpacing.sm)

            // TextEditor with notebook background (scrolls internally)
            ZStack(alignment: .topLeading) {
                HDColors.cardBackground

                NotebookLinesBackground(lineSpacing: 24)
                    .padding(.horizontal, HDSpacing.sm)

                TextEditor(text: $viewModel.hike.story)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(HDColors.forestGreen)
                    .lineSpacing(4)
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.never)
                    .padding(.leading, HDSpacing.sm)
                    .padding(.trailing, 4)
                    .padding(.top, HDSpacing.xs)
                    .padding(.bottom, HDSpacing.xs)
                    .focused($isEditorFocused)
                    .frame(minHeight: 200, maxHeight: .infinity)
            }
            .onTapGesture {
                isEditorFocused = true
            }
            .clipShape(RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusMedium))
            .padding(.horizontal, HDSpacing.md)
            .padding(.bottom, HDSpacing.md)
        }
        .frame(minHeight: 300, maxHeight: .infinity)
        .background(HDColors.cardBackground)
        .cornerRadius(HDSpacing.cornerRadiusMedium)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // MARK: - Actions

    private func insertTimestamp() {
        let timeString = formatTime()
        appendToStory("\n\n[\(timeString)] ")
    }

    private func insertObservation() {
        let timeString = formatTime()
        appendToStory("\n\n[\(timeString)] Observatie: ")
    }

    private func insertPause() {
        let timeString = formatTime()
        appendToStory("\n\n[\(timeString)] Pauze\n")
        viewModel.incrementPauseCount()
    }

    private func insertAnimalSpotted() {
        let timeString = formatTime()
        appendToStory("\n\n[\(timeString)] Dieren gespot: ")
        viewModel.incrementAnimalCount()
    }

    private func insertMeeting() {
        let timeString = formatTime()
        appendToStory("\n\n[\(timeString)] Ontmoeting: ")
        viewModel.incrementMeetingCount()
    }

    private func formatTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    private func appendToStory(_ text: String) {
        viewModel.hike.story += text
        viewModel.hike.updatedAt = Date()
    }
}

#Preview {
    StoryTabView(
        viewModel: ActiveHikeViewModel(
            hike: Hike(
                status: "inProgress",
                name: "Test Wandeling",
                type: "Dagwandeling",
                startMood: 8
            )
        )
    )
}
