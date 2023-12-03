//
//  DateExtensions.swift
//  Instaura
//
//  Created by Димон on 25.11.23.
//

import Foundation

extension Date {
    var dateOnly: DateComponents { Calendar.current.dateComponents([.year, .month, .day], from: self) }
    var timeOnly: DateComponents { Calendar.current.dateComponents([.hour, .minute], from: self) }
    var fullDate: DateComponents { Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self) }
    
    var dateAppointment: Date {
        let component = self.dateOnly
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            timeZone: TimeZone(secondsFromGMT: +3),
            year: component.year,
            month: component.month,
            day: component.day,
            hour: 0,
            minute: 0,
            second: 0
        )
        return calendar.date(from: components) ?? .now
    }
    
    var timeAppointment: Date {
        let component = self.fullDate
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            year: component.year,
            month: component.month,
            day: component.day,
            hour: component.hour,
            minute: component.minute,
            second: 0
        )
        return calendar.date(from: components) ?? .now
    }
    
    
    var timeFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    var dateFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM, yyyy"
        return formatter.string(from: self)
    }
    
    func dateWithTime(with time: Date) -> Date {
        let dateComponent = self.fullDate
        let timeComponent = time.timeOnly
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            year: dateComponent.year,
            month: dateComponent.month,
            day: dateComponent.day,
            hour: timeComponent.hour,
            minute: timeComponent.minute,
            second: 0
        )
        return calendar.date(from: components) ?? .now
    }
}
