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
        "Hoe voelt je lijf nu?",
        "Valt je iets bijzonders op?",
        "Wat hoor je als je even stilstaat?",
        "Wil je dit moment bewaren?",
        "Voel je al verschil sinds je begon?",
        "Wat zou je willen onthouden van nu?",
        "Hoe voelen je voeten op de grond?",
        "Wat trekt je aandacht?",
        "Merk je dat je ademhaling veranderd is?",
        "Voel je je ritme al?",
        "Tijd voor een rustmoment?",
        "Wat heeft de route je tot nu toe gegeven?",
        "Merk je dat je hoofd leger wordt?",
        "Waar denk je aan tijdens het lopen?",
        "Loop je nog in je eigen tempo?"
    ]

    // MARK: - Motivation Messages

    private let motivationMessages = [
        "Je lijf mist bewegen",
        "Buiten wacht iets moois",
        "Zelfs tien minuten lopen helpt",
        "Een rondje om het blok is genoeg",
        "Frisse lucht maakt het hoofd helder",
        "Je ademhaling vraagt om ruimte",
        "Kleine stappen tellen ook",
        "Je laatste wandeling deed je goed",
        "Eén stap buiten de deur is al winst",
        "Klaar voor een flinke tocht?",
        "Kilometers maken brengt je bij jezelf",
        "Een dagtocht geeft ruimte die je niet kunt plannen",
        "De beste gedachten komen na uur drie",
        "Lange routes geven perspectief",
        "Durven doorgaan als het zwaar wordt – dat leer je wandelend"
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

        let shuffledMessages = hikeReminderMessages.shuffled()

        // Schedule 10 reminders ahead
        for i in 1...10 {
            let content = UNMutableNotificationContent()
            content.title = "Wandeldagboek"
            content.body = shuffledMessages[(i - 1) % shuffledMessages.count]
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
