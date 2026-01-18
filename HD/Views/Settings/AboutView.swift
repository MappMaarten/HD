import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Versie")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text("1")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("App Informatie")
            }

            Section {
                Text("Wandeldagboek is gemaakt voor iedereen die graag wandelt en hun avonturen wil vastleggen. Of je nu een korte boswandeling maakt of een meerdaagse tocht, deze app helpt je om elk moment te bewaren.")
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("Gemaakt met ❤️ voor wandelaars, door wandelaars.")
                    .font(.callout)
                    .foregroundColor(.accentColor)
                    .padding(.top, 8)
            } header: {
                Text("Over deze app")
            }

            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "figure.hiking")
                            .font(.system(size: 50))
                            .foregroundColor(.accentColor)

                        Text("Wandeldagboek")
                            .font(.headline)

                        Text("Jouw wandelingen, vastgelegd")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Over de app")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
