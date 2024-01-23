//
//  UIViewExtensions.swift
//  No-MakeUp
//
//  Created by Димон on 10.12.23.
//

import UIKit

extension UIView {
    
    func fadeTransition(_ duration: CFTimeInterval = 0.25) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
