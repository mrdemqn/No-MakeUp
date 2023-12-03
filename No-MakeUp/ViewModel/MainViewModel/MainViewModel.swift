//
//  MainViewModel.swift
//  Instaura
//
//  Created by Димон on 20.11.23.
//

import CoreData
import UIKit

protocol MainViewModelProtocol {
    
    func createClient(name: String)
}

final class MainViewModel: MainViewModelProtocol {
    
    func createClient(name: String) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        delegate.coreDataService.createObject { context in
            let client = Client(context: context)
            let date = self.createDate()
            let time = self.createTime()
            client.name = "Даша"
            client.instagram = "snyatsauna"
            client.notes = "Лупоглазым не приходить!"
            client.image = ""
            client.makeUpAppointmentDate = date
            client.makeUpAppointmentTime = time
            print("Time: \(time)")
            print("Date: \(date)")
            return client
        } completion: { _ in}
    }
    
    func createDate() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            timeZone: TimeZone(secondsFromGMT: +3),
            year: 2023,
            month: 1,
            day: 30,
            hour: 0,
            minute: 0,
            second: 0
        )
        let gregorian = calendar.date(from: components) ?? .now
        
        return gregorian
    }
    
    func createTime() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(
            year: 2023,
            month: 1,
            day: 31,
            hour: 17,
            minute: 35,
            second: 0
        )
        let gregorian = calendar.date(from: components) ?? .now
        
        return gregorian
    }
}
