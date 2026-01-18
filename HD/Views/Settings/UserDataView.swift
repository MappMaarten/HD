import SwiftUI
import SwiftData

struct UserDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userData: [UserData]

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var isCloudSyncEnabled: Bool = false

    private var currentUserData: UserData? {
        userData.first
    }

    var body: some View {
        List {
            Section {
                TextField("Naam", text: $name)
                TextField("E-mail", text: $email)
                    .textInputAutocapitalization(.never)
            } header: {
                Text("Persoonlijke gegevens")
            } footer: {
                Text("Deze gegevens worden alleen lokaal opgeslagen op je apparaat.")
            }

            Section {
                Toggle("iCloud Sync", isOn: $isCloudSyncEnabled)
            } header: {
                Text("Synchronisatie")
            } footer: {
                Text("Synchroniseer je wandelingen en gegevens via iCloud (optioneel).")
            }
        }
        .navigationTitle("Jouw gegevens")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUserData()
        }
        .onChange(of: name) { _, _ in saveUserData() }
        .onChange(of: email) { _, _ in saveUserData() }
        .onChange(of: isCloudSyncEnabled) { _, _ in saveUserData() }
    }

    private func loadUserData() {
        if let data = currentUserData {
            name = data.name
            email = data.email
            isCloudSyncEnabled = data.isCloudSyncEnabled
        } else {
            // Create initial user data
            let newData = UserData()
            modelContext.insert(newData)
        }
    }

    private func saveUserData() {
        if let data = currentUserData {
            data.name = name
            data.email = email
            data.isCloudSyncEnabled = isCloudSyncEnabled
            data.updatedAt = Date()
        } else {
            let newData = UserData(
                name: name,
                email: email,
                isCloudSyncEnabled: isCloudSyncEnabled
            )
            modelContext.insert(newData)
        }

        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        UserDataView()
            .modelContainer(for: UserData.self, inMemory: true)
    }
}
