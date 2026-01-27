import SwiftUI
import SwiftData

struct DevToolsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allHikes: [Hike]

    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isProcessing = false

    private var sampleHikesCount: Int {
        // This is an approximation - we can't directly count sample hikes without fetching them
        // but we can show total hikes count
        allHikes.count
    }

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                titleSection

                ScrollView {
                    VStack(spacing: HDSpacing.md) {
                        infoSection
                        sampleDataSection
                    }
                    .padding(.horizontal, HDSpacing.horizontalMargin)
                    .padding(.bottom, HDSpacing.lg)
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
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        HStack {
            Text("Dev Tools")
                .hdHandwritten(size: 24)
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
        .padding(.bottom, HDSpacing.sm)
    }

    // MARK: - Info Section

    private var infoSection: some View {
        FormSection(title: "Status", icon: "info.circle") {
            VStack(spacing: HDSpacing.sm) {
                HStack {
                    Text("Totaal aantal wandelingen")
                        .font(.system(size: 15))
                        .foregroundColor(HDColors.forestGreen)
                    Spacer()
                    Text("\(sampleHikesCount)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(HDColors.mutedGreen)
                }
            }
        }
    }

    // MARK: - Sample Data Section

    private var sampleDataSection: some View {
        FormSection(title: "Voorbeelddata", icon: "folder") {
            VStack(spacing: HDSpacing.sm) {
                // Import button
                Button {
                    importSampleHikes()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Importeer voorbeeldwandelingen")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(HDColors.forestGreen)
                            Text("Voegt 10 voorbeeldwandelingen toe")
                                .font(.system(size: 13))
                                .foregroundColor(HDColors.mutedGreen)
                        }

                        Spacer()

                        if isProcessing {
                            ProgressView()
                                .tint(HDColors.forestGreen)
                        }
                    }
                    .padding(.vertical, HDSpacing.xs)
                }
                .disabled(isProcessing)
                .buttonStyle(.plain)

                Divider()
                    .background(HDColors.dividerColor)

                // Delete button
                Button {
                    deleteSampleHikes()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Verwijder voorbeeldwandelingen")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.red)
                            Text("Verwijdert alle voorbeeldwandelingen")
                                .font(.system(size: 13))
                                .foregroundColor(HDColors.mutedGreen)
                        }

                        Spacer()

                        if isProcessing {
                            ProgressView()
                                .tint(.red)
                        }
                    }
                    .padding(.vertical, HDSpacing.xs)
                }
                .disabled(isProcessing)
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Actions

    private func importSampleHikes() {
        isProcessing = true

        Task {
            do {
                let count = try SampleDataService.createSampleHikes(context: modelContext)

                await MainActor.run {
                    isProcessing = false
                    alertTitle = "Succes"
                    alertMessage = "\(count) wandelingen geïmporteerd"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    alertTitle = "Fout"
                    alertMessage = "Kon wandelingen niet importeren: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }

    private func deleteSampleHikes() {
        isProcessing = true

        Task {
            do {
                let count = try SampleDataService.deleteSampleHikes(context: modelContext)

                await MainActor.run {
                    isProcessing = false
                    alertTitle = "Succes"
                    alertMessage = "\(count) wandelingen verwijderd"
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    alertTitle = "Fout"
                    alertMessage = "Kon wandelingen niet verwijderen: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DevToolsView()
    }
}
