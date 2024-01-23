//
//  CreateAppointmentViewModel.swift
//  Instaura
//
//  Created by Димон on 26.11.23.
//

import CoreData
import UIKit

protocol CreateAppointmentViewModelProtocol {
    
    func createAppointment(date: Date,
                           time: Date,
                           name: String,
                           instagram: String?,
                           notes: String?,
                           notification: LocalNotification?,
                           completion: @escaping () -> Void)
    
    func requestAuthNotifications()
}

final class CreateAppointmentViewModel: CreateAppointmentViewModelProtocol {
    
    func createAppointment(date: Date,
                           time: Date,
                           name: String,
                           instagram: String?,
                           notes: String?,
                           notification: LocalNotification?,
                           completion: @escaping () -> Void) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        delegate.coreDataService.createObject { context in
            let client = Client(context: context)
            client.name = name
            client.instagram = instagram
            client.notes = notes
            client.makeUpAppointmentDate = date
            client.makeUpAppointmentTime = time
            let notificationSet = self.configureNotifications(preparedNotification: notification,
                                                              context: context)
            client.addToNotifications(notificationSet)
            return client
        } completion: { objectID in
            self.registerNotifications(notification: notification, id: objectID)
            completion()
        }

    }
    
    func requestAuthNotifications() {
        LocalNotificationManager.shared.requestAuth()
    }
    
    private func configureNotifications(preparedNotification: LocalNotification?,
                                        context: NSManagedObjectContext) -> NSSet {
        guard let preparedNotification = preparedNotification else { return [] }
        let notificationSet: NSMutableSet = []
        let notification = Notification(context: context)
        notification.title = preparedNotification.title
        notification.body = preparedNotification.body
        notification.notificationTypeRawValue = Int16(preparedNotification.notificationType.rawValue)
        notificationSet.add(notification)
        return notificationSet
    }
    
    private func registerNotifications(notification: LocalNotification?,
                                       id: NSManagedObjectID) {
        guard let notification = notification else { return }
        LocalNotificationManager.shared.registerNotifications(notification: notification, id: id)
    }
}
