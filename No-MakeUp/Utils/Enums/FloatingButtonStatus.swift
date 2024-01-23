//
//  FloatingButtonStatus.swift
//  No-MakeUp
//
//  Created by Димон on 11.12.23.
//

enum FloatingButtonStatus {
    case show
    case hide
}

extension FloatingButtonStatus {
    
    var isShowing: Bool { self == .show }
    
    var isHidden: Bool { self == .hide }
}
