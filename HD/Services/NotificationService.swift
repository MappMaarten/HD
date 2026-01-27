//
//  NotificationService.swift
//  HD
//
//  Central notification service for hike reminders and motivation notifications
//

import Foundation
import UserNotifications

@Observable
final class NotificationService {
    static let shared = NotificationService()

    private(set) var permissionStatus: UNAuthorizationStatus = .notDetermined

    // MARK: - Notification Identifiers

    private let hikeReminderPrefix = "hike_reminder_"
    private let motivationReminderPrefix = "motivation_reminder_"

    // MARK: - Hike Reminder Messages

    private let hikeReminderMessages = [
        "Geniet je van je wandeling?",
        "Heb je iets moois gezien?",
        "Wat valt je op?",
        "Neem even de tijd om rond te kijken",
        "Wil je iets vastleggen in je dagboek?"
    ]

    // MARK: - Motivation Messages

    private let motivationMessages = [
        "Zin om weer een mooie wandeling te maken?",
        "Mis je de buitenlucht al?",
        "Je hebt al even geen wandeling vastgelegd",
        "Wanneer ga je weer?",
        "De natuur wacht op je"
    ]

    // MARK: - Initialization

    private init() {
        Task {
            await refreshPermissionStatus()
        }
    }

    // MARK: - Permission Management

    @MainActor
    func refreshPermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        permissionStatus = settings.authorizationStatus
    }

    @MainActor
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await refreshPermissionStatus()
            return granted
        } catch {
            print("NotificationService: Error requesting permission: \(error)")
            await refreshPermissionStatus()
            return false
        }
    }

    // MARK: - Hike Reminders

    func scheduleHikeReminders(intervalMinutes: Int) {
        cancelHikeReminders()

        // Schedule 10 reminders ahead
        for i in 1...10 {
            let content = UNMutableNotificationContent()
            content.title = "Wandeldagboek"
            content.body = hikeReminderMessages.randomElement() ?? hikeReminderMessages[0]
            content.sound = .default

            let triggerDate = Date().addingTimeInterval(Double(i * intervalMinutes * 60))
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: "\(hikeReminderPrefix)\(i)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("NotificationService: Error scheduling hike reminder \(i): \(error)")
                }
            }
        }
    }

    func cancelHikeReminders() {
        let identifiers = (1...10).map { "\(hikeReminderPrefix)\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Motivation Reminders

    func scheduleMotivationReminders(lastCompletedHikeDate: Date?, daysInterval: Int) {
        cancelMotivationReminders()

        let baseDate = lastCompletedHikeDate ?? Date()

        let content = UNMutableNotificationContent()
        content.title = "Wandeldagboek"
        content.body = motivationMessages.randomElement() ?? motivationMessages[0]
        content.sound = .default

        // Schedule notification for X days after last completed hike at 10:00 AM
        var triggerDate = Calendar.current.date(byAdding: .day, value: daysInterval, to: baseDate) ?? baseDate
        triggerDate = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: triggerDate) ?? triggerDate

        // Only schedule if the trigger date is in the future
        guard triggerDate > Date() else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "\(motivationReminderPrefix)1",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("NotificationService: Error scheduling motivation reminder: \(error)")
            }
        }
    }

    func cancelMotivationReminders() {
        let identifiers = ["\(motivationReminderPrefix)1"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Hike Lifecycle

    func onHikeStarted() {
        // Cancel motivation reminders when a hike starts
        cancelMotivationReminders()
    }

    func onHikeEnded(completedDate: Date, motivationDaysInterval: Int, motivationEnabled: Bool) {
        // Cancel hike reminders
        cancelHikeReminders()

        // Schedule motivation reminders if enabled
        if motivationEnabled {
            scheduleMotivationReminders(lastCompletedHikeDate: completedDate, daysInterval: motivationDaysInterval)
        }
    }
}
