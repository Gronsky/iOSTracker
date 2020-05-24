//
//  AppDelegate.swift
//  Tracker
//
//  Created by Gronsky on 5/4/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // for notifications
    let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        notificationCenter.delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    // MARK: extensions
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }
        
        completionHandler()
    }
    
    func scheduleNotification(notificationType: String) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        let categoryIdentifire = "Delete Notification Type"
        
        content.title = "Notification"
        content.body = "hfhgfjhkjjl"
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // after 5 sec
        let identifier = "Local Notification"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            }
            
            let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
            let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
            let category = UNNotificationCategory(identifier: categoryIdentifire,
                                                  actions: [snoozeAction, deleteAction],
                                                  intentIdentifiers: [],
                                                  options: [])
            
            notificationCenter.setNotificationCategories([category])
        }
}

