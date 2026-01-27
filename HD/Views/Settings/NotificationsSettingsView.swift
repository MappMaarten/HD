import SwiftUI

struct NotificationsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @AppStorage("notificationsEnabled") private var enableNotifications = false
    @AppStorage("activeHikeReminderEnabled") private var activeHikeReminderEnabled = false
    @AppStorage("activeHikeReminderInterval") private var activeHikeReminderInterval = 30
    @AppStorage("motivationReminderEnabled") private var motivationReminderEnabled = false
    @AppStorage("motivationReminderDays") private var motivationReminderDays = 3

    @State private var permissionDenied = false

    private let intervalOptions = [15, 30, 45, 60]

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                titleSection
                settingsContent
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
        .task {
            await checkPermissionStatus()
        }
        .onChange(of: enableNotifications) { _, newValue in
            if newValue {
                Task {
                    await requestPermissionIfNeeded()
                }
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        HStack {
            Text("Notificaties")
                .hdHandwritten(size: 24)
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
        .padding(.bottom, HDSpacing.md)
    }

    // MARK: - Settings Content

    private var settingsContent: some View {
        ScrollView {
            VStack(spacing: HDSpacing.md) {
                // Permission warning
                if permissionDenied {
                    permissionWarningSection
                }

                // Main toggle
                mainToggleSection

                // During hike section
                if enableNotifications {
                    hikeReminderSection
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                // Motivation section
                if enableNotifications {
                    motivationSection
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, HDSpacing.horizontalMargin)
            .padding(.bottom, HDSpacing.lg)
            .animation(.easeInOut(duration: 0.2), value: enableNotifications)
        }
    }

    // MARK: - Permission Warning

    private var permissionWarningSection: some View {
        FormSection {
            VStack(alignment: .leading, spacing: HDSpacing.sm) {
                HStack(spacing: HDSpacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(HDColors.amber)
                    Text("Notificaties uitgeschakeld")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(HDColors.forestGreen)
                }

                Text("Notificaties zijn uitgeschakeld in de systeeminstellingen. Schakel ze in om herinneringen te ontvangen.")
                    .font(.system(size: 14))
                    .foregroundColor(HDColors.mutedGreen)

                Button {
                    openSettings()
                } label: {
                    HStack {
                        Image(systemName: "gear")
                        Text("Open Instellingen")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HDSpacing.sm)
                    .background(HDColors.forestGreen)
                    .cornerRadius(HDSpacing.cornerRadiusSmall)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Main Toggle Section

    private var mainToggleSection: some View {
        FormSection {
            HStack(spacing: HDSpacing.md) {
                // Bell icon
                Image(systemName: enableNotifications ? "bell.fill" : "bell.slash")
                    .font(.system(size: 24))
                    .foregroundColor(enableNotifications ? HDColors.forestGreen : HDColors.mutedGreen)
                    .frame(width: 32)

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(enableNotifications ? "Notificaties aan" : "Notificaties uit")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(HDColors.forestGreen)
                    Text("Ontvang herinneringen tijdens en na je wandelingen")
                        .font(.system(size: 13))
                        .foregroundColor(HDColors.mutedGreen)
                }

                Spacer()

                // Custom toggle with better contrast
                Toggle("", isOn: $enableNotifications)
                    .labelsHidden()
                    .tint(HDColors.forestGreen)
                    .background(
                        Capsule()
                            .fill(enableNotifications ? Color.clear : HDColors.dividerColor)
                            .frame(width: 51, height: 31)
                    )
            }
        }
    }

    // MARK: - Hike Reminder Section

    private var hikeReminderSection: some View {
        FormSection(title: "Tijdens wandeling", icon: "figure.walk") {
            VStack(alignment: .leading, spacing: HDSpacing.md) {
                Toggle(isOn: $activeHikeReminderEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Wandelherinneringen")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)
                        Text("Krijg zachte herinneringen om momenten vast te leggen")
                            .font(.system(size: 13))
                            .foregroundColor(HDColors.mutedGreen)
                    }
                }
                .tint(HDColors.forestGreen)

                if activeHikeReminderEnabled {
                    VStack(alignment: .leading, spacing: HDSpacing.sm) {
                        Text("Interval")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)

                        HStack(spacing: HDSpacing.xs) {
                            ForEach(intervalOptions, id: \.self) { interval in
                                Button {
                                    activeHikeReminderInterval = interval
                                } label: {
                                    Text("\(interval)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(activeHikeReminderInterval == interval ? .white : HDColors.forestGreen)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, HDSpacing.xs)
                                        .background(
                                            RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                                                .fill(activeHikeReminderInterval == interval ? HDColors.forestGreen : HDColors.cream)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusSmall)
                                                .stroke(activeHikeReminderInterval == interval ? HDColors.forestGreen : HDColors.dividerColor, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Text("minuten tussen herinneringen")
                            .font(.system(size: 12))
                            .foregroundColor(HDColors.mutedGreen)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: activeHikeReminderEnabled)
        }
    }

    // MARK: - Motivation Section

    private var motivationSection: some View {
        FormSection(title: "Motivatie", icon: "heart") {
            VStack(alignment: .leading, spacing: HDSpacing.md) {
                Toggle(isOn: $motivationReminderEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Motivatieherinneringen")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)
                        Text("Krijg een vriendelijke herinnering als je even niet gewandeld hebt")
                            .font(.system(size: 13))
                            .foregroundColor(HDColors.mutedGreen)
                    }
                }
                .tint(HDColors.forestGreen)

                if motivationReminderEnabled {
                    VStack(alignment: .leading, spacing: HDSpacing.sm) {
                        Text("Na hoeveel dagen?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(HDColors.forestGreen)

                        HStack(spacing: HDSpacing.sm) {
                            // Stepper
                            HStack(spacing: 0) {
                                Button {
                                    if motivationReminderDays > 1 {
                                        motivationReminderDays -= 1
                                    }
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.body.weight(.semibold))
                                        .foregroundColor(motivationReminderDays > 1 ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.5))
                                        .frame(width: 44, height: 40)
                                }
                                .disabled(motivationReminderDays <= 1)

                                Text("\(motivationReminderDays)")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(HDColors.forestGreen)
                                    .frame(minWidth: 32)

                                Button {
                                    if motivationReminderDays < 14 {
                                        motivationReminderDays += 1
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.body.weight(.semibold))
                                        .foregroundColor(motivationReminderDays < 14 ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.5))
                                        .frame(width: 44, height: 40)
                                }
                                .disabled(motivationReminderDays >= 14)
                            }
                            .background(Color.white.opacity(0.5))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(HDColors.dividerColor.opacity(0.3), lineWidth: 1)
                            )

                            Text(motivationReminderDays == 1 ? "dag" : "dagen")
                                .font(.subheadline)
                                .foregroundColor(HDColors.mutedGreen)

                            Spacer()
                        }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: motivationReminderEnabled)
        }
    }

    // MARK: - Actions

    private func checkPermissionStatus() async {
        await NotificationService.shared.refreshPermissionStatus()
        await MainActor.run {
            permissionDenied = NotificationService.shared.permissionStatus == .denied
        }
    }

    private func requestPermissionIfNeeded() async {
        if NotificationService.shared.permissionStatus == .notDetermined {
            let granted = await NotificationService.shared.requestPermission()
            await MainActor.run {
                if !granted {
                    enableNotifications = false
                }
            }
        } else if NotificationService.shared.permissionStatus == .denied {
            await MainActor.run {
                permissionDenied = true
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsView()
    }
}
