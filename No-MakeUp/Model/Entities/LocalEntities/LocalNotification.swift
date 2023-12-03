//
//  LocalNotification.swift
//  No-MakeUp
//
//  Created by Димон on 28.11.23.
//

import Foundation

struct LocalNotification {
    var title: String
    var body: String
    var notificationType: NotificationType
    var notificationDate: Date = .now
}
