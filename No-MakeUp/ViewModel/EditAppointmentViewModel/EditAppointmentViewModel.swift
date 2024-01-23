//
//  EditAppointmentViewModel.swift
//  No-MakeUp
//
//  Created by Димон on 10.12.23.
//

import Foundation
import UIKit
import CoreData

protocol EditAppointmentViewModelProtocol {
    
    func editAppointment(date: Date,
                         time: Date,
                         name: String,
                         instagram: String?,
                         notes: String?,
                         notification: LocalNotification?,
                         client: Client,
                         completion: @escaping (Client) -> Void)
    
    func requestAuthNotifications()
}

final class EditAppointmentViewModel: EditAppointmentViewModelProtocol {
    
    func editAppointment(date: Date,
                         time: Date,
                         name: String,
                         instagram: String?,
                         notes: String?,
                         notification: LocalNotification?,
                         client: Client,
                         completion: @escaping (Client) -> Void) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = delegate.coreDataService.context
        client.name = name
        client.instagram = instagram
        client.notes = notes
        client.makeUpAppointmentDate = date
        client.makeUpAppointmentTime = time
        if !client.notificationsArray.isEmpty {
            LocalNotificationManager.shared.removeNotification(id: client.objectID)
        }
        let notificationSet = configureNotifications(preparedNotification: notification,
                                                     context: context)
        client.notifications = notificationSet
        registerNotifications(notification: notification, id: client.objectID)
        delegate.coreDataService.saveContext()
        completion(client)
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
