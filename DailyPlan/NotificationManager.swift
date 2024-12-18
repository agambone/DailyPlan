//
//  NotificationManager.swift
//  DailyPlan
//
//  Created by Antonio Gambone on 18/12/24.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
                self.checkNotificationSettings()
            } else {
                print("❌ Notification permission denied")
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("\n=== Notification Settings ===")
            print("Authorization Status: \(settings.authorizationStatus.rawValue)")
            print("Alert Setting: \(settings.alertSetting.rawValue)")
            print("Sound Setting: \(settings.soundSetting.rawValue)")
            print("Badge Setting: \(settings.badgeSetting.rawValue)")
            print("=== End Settings ===")
        }
    }
    
    func scheduleNotification(for item: Item) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Task Starting Now!"
        content.body = "📝 \(item.title)"
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.interruptionLevel = .timeSensitive
        
        print("\n=== Scheduling Notification ===")
        print("Task: \(item.title)")
        print("Scheduled for: \(item.startDate.formatted())")
        
        if item.startDate > Date() {
            
            cancelNotification(for: item)
            
            
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: item.startDate
            )
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: item.id.uuidString,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification: \(error)")
                } else {
                    print("✅ Successfully scheduled notification")
                    // Verify schedule
                    self.checkPendingNotifications()
                }
            }
        } else {
            print("⚠️ Cannot schedule notification for past date")
        }
    }
    
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        
        completionHandler([.banner, .sound, .badge])
    }
    
    
    
    func cancelNotification(for item: Item) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
        print("Cancelled notification for: \(item.title)")
    }
    
    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("\n=== Pending Notifications ===")
            print("Total count: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("ID: \(request.identifier)")
                    print("Title: \(request.content.title)")
                    print("Body: \(request.content.body)")
                    print("Next trigger: \(trigger.nextTriggerDate()?.formatted() ?? "N/A")")
                    print("---")
                }
            }
            print("=== End Pending Notifications ===")
        }
    }
}
