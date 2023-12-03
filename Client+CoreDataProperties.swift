//
//  Client+CoreDataProperties.swift
//  No-MakeUp
//
//  Created by Димон on 28.11.23.
//
//

import Foundation
import CoreData


extension Client {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client")
    }

    @NSManaged public var image: String?
    @NSManaged public var instagram: String?
    @NSManaged public var makeUpAppointmentDate: Date?
    @NSManaged public var makeUpAppointmentTime: Date?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var notifications: NSSet?
    
    var notificationsArray: [Notification] {
        guard let notifications = notifications?.allObjects as? [Notification] else { return [] }
        return notifications
    }

}

// MARK: Generated accessors for notifications
extension Client {

    @objc(addNotificationsObject:)
    @NSManaged public func addToNotifications(_ value: Notification)

    @objc(removeNotificationsObject:)
    @NSManaged public func removeFromNotifications(_ value: Notification)

    @objc(addNotifications:)
    @NSManaged public func addToNotifications(_ values: NSSet)

    @objc(removeNotifications:)
    @NSManaged public func removeFromNotifications(_ values: NSSet)

}

extension Client : Identifiable {

}
