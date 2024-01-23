//
//  FadeNavigationController.swift
//  No-MakeUp
//
//  Created by Димон on 14.12.23.
//

import UIKit

final class FadeNavigationController: UINavigationController {

    private var interactionController: UIPercentDrivenInteractiveTransition?
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var edgeScreenGesture: UIScreenEdgePanGestureRecognizer!
    
    var animationType: AnimationType = .standard

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
//        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        edgeScreenGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        edgeScreenGesture.edges = .left
        view.addGestureRecognizer(edgeScreenGesture)
    }

    @objc private func handleSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
//        let percent = max(gestureRecognizer.translation(in: view).x, 0) / view.frame.width
        print("HandleSwipe")
        let percent = gestureRecognizer.translation(in: gestureRecognizer.view!).x / gestureRecognizer.view!.bounds.size.width
        delegate = self
        if gestureRecognizer.state == .began {
            interactionController = UIPercentDrivenInteractiveTransition()
            popViewController(animated: true)
        } else if gestureRecognizer.state == .changed {
            interactionController?.update(percent)
        } else if gestureRecognizer.state == .ended {
            if percent > 0.5 && gestureRecognizer.state != .cancelled {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        }
        
//        switch gestureRecognizer.state {
//            case .began:
//                interactionController = UIPercentDrivenInteractiveTransition()
//                interactionController?.completionCurve = .easeIn
//                delegate = self
//                popViewController(animated: true)
//                interactionController?.update(percent)
//            case .changed:
//                interactionController?.update(percent)
//            case .ended:
//                let velocity = gestureRecognizer.velocity(in: view).x
//                
//                if (percent > 0.5 || velocity > 1000)  {
//                    interactionController?.finish()
//                } else {
//                    interactionController?.cancel()
//                }
//                interactionController = nil
//            case .cancelled, .failed:
//                interactionController?.cancel()
//            default: break
//        }
    }
    
    func setDelegate() {
        delegate = self
    }
}

extension FadeNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch animationType {
            case .standard:
                delegate = nil
                return nil
            case .fade:
                print("FadeAnimationController")
                return FadeAnimationController(presenting: operation == .push)
        }
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        switch animationType {
            case .standard:
                delegate = nil
                return nil
            case .fade: return interactionController
        }
    }
}

enum AnimationType {
    case standard
    case fade
}
