//
//  NSObjectExtensions.swift
//  Instaura
//
//  Created by Димон on 24.11.23.
//

import Foundation

extension NSObject {
    
    func localized(of key: Localization) -> String {
        return NSLocalizedString(key.rawValue, comment: "")
    }
}
