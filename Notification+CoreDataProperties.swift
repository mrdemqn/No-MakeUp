//
//  Notification+CoreDataProperties.swift
//  No-MakeUp
//
//  Created by Димон on 28.11.23.
//
//

import Foundation
import CoreData


extension Notification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
        return NSFetchRequest<Notification>(entityName: "Notification")
    }

    @NSManaged public var body: String?
    @NSManaged public var notificationTypeRawValue: Int16
    @NSManaged public var title: String?
    @NSManaged public var client: Client?

    var notificationType: NotificationType {
        NotificationType(rawValue: Int(notificationTypeRawValue)) ?? .fiveMinutes
    }
}

extension Notification : Identifiable {

}
