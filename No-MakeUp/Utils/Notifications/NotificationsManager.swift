//
//  NotificationsManager.swift
//  No-MakeUp
//
//  Created by Димон on 28.11.23.
//

import ObjectiveC

final class NotificationsManager: NSObject {
    
    func fetchNotificationContent(of type: NotificationType,
                                  clientName: String) -> (title: String, body: String) {
        switch type {
            case .fiveMinutes:
                let body = "\(clientName) \(localized(of: .notificationBodyFiveMinutes))"
                return (title: localized(of: .notificationAppointmentTitle), body: body)
            case .thirtyMinutes:
                let body = "\(clientName) \(localized(of: .notificationBodyThirtyMinutes))"
                return (title: localized(of: .notificationAppointmentTitle), body: body)
            case .oneHour:
                let body = "\(clientName) \(localized(of: .notificationBodyOneHour))"
                return (title: localized(of: .notificationAppointmentTitle), body: body)
            case .twoHour:
                let body = "\(clientName) \(localized(of: .notificationBodyTwoHour))"
                return (title: localized(of: .notificationAppointmentTitle), body: body)
            case .oneDay:
                let body = "\(clientName) \(localized(of: .notificationBodyOneDay))"
                return (title: localized(of: .notificationAppointmentTitle), body: body)
        }
    }
    
    func fetchNotificationSubtitle(of type: NotificationType) -> String {
        return switch type {
            case .fiveMinutes: localized(of: .notificationsMenuFiveMinutes)
            case .thirtyMinutes: localized(of: .notificationsMenuThirtyMinutes)
            case .oneHour: localized(of: .notificationsMenuOneHour)
            case .twoHour: localized(of: .notificationsMenuTwoHour)
            case .oneDay: localized(of: .notificationsMenuOneDay)
        }
    }
}

import UserNotifications
import CoreData

final class LocalNotificationManager {
    
    static let shared = LocalNotificationManager()
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuth() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            guard granted else { return }
            
            self.notificationCenter.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                print(settings)
            }
        }
    }
    
    func setupNotification(_ date: Date) {
        let content = UNMutableNotificationContent()
        
        content.title = "Pussy Juicy"
        content.body = "Come on everybody dance now! Hello every body!"
        content.sound = .defaultCritical
//        content.categoryIdentifier = Constants.delayCategoryId
        content.userInfo = ["NOTIFICATION_ID": "local"]
        
        let dateInfo = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        let request = UNNotificationRequest(identifier: "identifier",
                                            content: content,
                                            trigger: trigger)
        
        let delayFiveMinutes = UNNotificationAction(identifier: "Constants.delayFiveId",
                                                    title: "Отложить на 5 минут!",
                                                    options: [])
        let delayTenMinutes = UNNotificationAction(identifier: "Constants.delayTenId",
                                                    title: "Отложить на 10 минут!",
                                                    options: [])
        let delayTwentyMinutes = UNNotificationAction(identifier: "Constants.delayTwentyId",
                                                    title: "Отложить на 20 минут!",
                                                    options: [])
        let delayThirtyMinutes = UNNotificationAction(identifier: "Constants.delayThirtyId",
                                                    title: "Отложить на 30 минут!",
                                                    options: [])
        let delayHour = UNNotificationAction(identifier: "Constants.delayHourId",
                                                    title: "Отложить на 1 час!",
                                                    options: [])
        
        let actions = [delayFiveMinutes, delayTenMinutes, delayTwentyMinutes, delayThirtyMinutes, delayHour]
        
        let delayCategory = UNNotificationCategory(identifier: "Constants.delayCategoryId",
                                                   actions: actions,
                                                   intentIdentifiers: [],
                                                   hiddenPreviewsBodyPlaceholder: "",
                                                   options: [])
        
        notificationCenter.setNotificationCategories([delayCategory])
        
        notificationCenter.add(request) { error in
            print("Notification Error: \(error?.localizedDescription ?? "nil")")
        }
    }
    
    func registerNotifications(notification: LocalNotification,
                               id identifier: NSManagedObjectID) {
        let content = UNMutableNotificationContent()
        let type = notification.notificationType
        
        content.title = notification.title
        content.body = notification.body
        content.categoryIdentifier = Constants.appointmentCategory
        content.sound = .defaultCritical
        content.userInfo = [Constants.clientObjectIDNotificationKey: identifier.uriRepresentation().absoluteString]
        let date =  decreaseDate(of: type, notification.notificationDate)
        
        print("Notification Date: \(date)")
        
        let dateInfo = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(identifier)",
                                            content: content,
                                            trigger: trigger)
        
        notificationCenter.add(request) { error in
            print("Notification Error: \(error?.localizedDescription ?? "nil")")
        }
    }
    
    private func decreaseDate(of type: NotificationType, _ date: Date) -> Date {
        return switch type {
            case .fiveMinutes: decrease(date, m: 5)
            case .thirtyMinutes: decrease(date, m: 30)
            case .oneHour: decrease(date, h: 1)
            case .twoHour: decrease(date, h: 2)
            case .oneDay: decrease(date, d: 1)
        }
    }
    
    func decrease(_ date: Date,
                  d days: Int = 0,
                  h hours: Int = 0,
                  m minutes: Int = 0) -> Date {
        let component = date.fullDate
        
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            year: component.year,
            month: component.month,
            day: (component.day ?? 0) - days,
            hour: (component.hour ?? 0) - hours,
            minute: (component.minute ?? 0) - minutes,
            second: 0
        )
        return calendar.date(from: components) ?? .now
    }
}
