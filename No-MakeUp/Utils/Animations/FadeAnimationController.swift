//
//  FadeAnimationController.swift
//  No-MakeUp
//
//  Created by Димон on 14.12.23.
//

import UIKit

final class FadeAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let container = transitionContext.containerView
        
        if presenting {
            container.addSubview(toView)
            toView.alpha = 0.0
        } else {
            container.insertSubview(toView, belowSubview: fromView)
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) { [unowned self] in
            if presenting {
                toView.alpha = 1.0
            } else {
                fromView.alpha = 0.0
            }
        } completion: { _ in
            let success = !transitionContext.transitionWasCancelled
            
            if !success {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(success)
        }
    }
}

final class CupertinoAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let container = transitionContext.containerView
        
        let width = container.frame.width
        
        var offsetLeft = fromView.frame
        offsetLeft.origin.x = width
        
        var offscreenRight = toView.frame
        offscreenRight.origin.x = -width / 3.33;
        
        toView.frame = offscreenRight;
        
        fromView.layer.shadowRadius = 5.0
        fromView.layer.shadowOpacity = 1.0
        toView.layer.opacity = 0.9
        
        container.insertSubview(toView, belowSubview: fromView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut) {
            
            toView.frame = (fromView.frame)
            fromView.frame = offsetLeft
            
            toView.layer.opacity = 1.0
            fromView.layer.shadowOpacity = 0.1
            
        } completion: { finished in
            toView.layer.opacity = 1.0
            toView.layer.shadowOpacity = 0
            fromView.layer.opacity = 1.0
            fromView.layer.shadowOpacity = 0
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
