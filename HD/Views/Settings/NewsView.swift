import SwiftUI

struct NewsView: View {
    private let newsURL = URL(string: "https://example.com/news")!

    var body: some View {
        List {
            Section {
                Text("Blijf op de hoogte van nieuwe functies, updates en verbeteringen aan de Wandeldagboek app.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Section {
                Link(destination: newsURL) {
                    HStack {
                        Image(systemName: "newspaper")
                            .foregroundColor(.accentColor)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bekijk alle updates")
                                .font(.body)
                            Text("Laatste nieuws en aankondigingen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Nieuws")
            }
        }
        .navigationTitle("Nieuws & updates")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NewsView()
    }
}
