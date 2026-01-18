import SwiftUI

struct NotificationsSettingsView: View {
    @AppStorage("notificationsEnabled") private var enableNotifications = false
    @AppStorage("activeHikeReminderEnabled") private var activeHikeReminderEnabled = false
    @AppStorage("activeHikeReminderInterval") private var activeHikeReminderInterval = 30
    @AppStorage("motivationReminderEnabled") private var motivationReminderEnabled = false
    @AppStorage("motivationReminderDays") private var motivationReminderDays = 3

    var body: some View {
        List {
            Section {
                Toggle("Notificaties aan", isOn: $enableNotifications)
            } header: {
                Text("Algemeen")
            } footer: {
                Text("Schakel notificaties in om herinneringen te ontvangen")
            }

            // Wandelherinnering bij actieve wandeling
            Section {
                Toggle("Wandelherinnering", isOn: $activeHikeReminderEnabled)
                    .disabled(!enableNotifications)

                if activeHikeReminderEnabled && enableNotifications {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Interval")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(activeHikeReminderInterval) minuten")
                                .foregroundColor(.primary)
                        }

                        Slider(
                            value: Binding(
                                get: { Double(activeHikeReminderInterval) },
                                set: { activeHikeReminderInterval = Int($0) }
                            ),
                            in: 15...60,
                            step: 5
                        )
                    }
                }
            } header: {
                Text("Tijdens Wandeling")
            } footer: {
                Text("Krijg een herinnering om je wandeling bij te werken tijdens een actieve wandeling")
            }

            // Motivatieherinnering
            Section {
                Toggle("Motivatieherinnering", isOn: $motivationReminderEnabled)
                    .disabled(!enableNotifications)

                if motivationReminderEnabled && enableNotifications {
                    Picker("Na hoeveel dagen", selection: $motivationReminderDays) {
                        ForEach(1...14, id: \.self) { days in
                            if days == 1 {
                                Text("1 dag").tag(days)
                            } else {
                                Text("\(days) dagen").tag(days)
                            }
                        }
                    }
                }
            } header: {
                Text("Motivatie")
            } footer: {
                Text("Ontvang een motiverende herinnering als je een tijd niet gewandeld hebt")
            }
        }
        .navigationTitle("Notificaties")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsView()
    }
}
