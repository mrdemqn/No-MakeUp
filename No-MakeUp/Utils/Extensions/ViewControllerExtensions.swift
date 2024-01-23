//
//  ViewControllerExtensions.swift
//  Instaura
//
//  Created by Димон on 20.11.23.
//

import UIKit

@nonobjc extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }

        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    func push(of viewController: UIViewController,
              animationType: AnimationType = .standard,
              animated: Bool = true) {
        if let controller = navigationController as? FadeNavigationController {
            controller.setDelegate()
            controller.animationType = animationType
        }
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func present(_ viewController: UIViewController, _ animated: Bool = true) {
        present(viewController, animated: animated)
    }
    
    func pop(animationType: AnimationType = .standard,
             _ animated: Bool = true) {
        if let controller = navigationController as? FadeNavigationController {
            controller.setDelegate()
            controller.animationType = animationType
        }
        navigationController?.popViewController(animated: animated)
    }
    
    func handleShortcut(of type: String?) {
        guard let type = type else { return }
        let shortcutType = ShortcutType(rawValue: type) ?? .createAppointment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            switch shortcutType {
                case .createAppointment: self.pushCreateAppointment()
                case .openCalendar: self.pushCalendar()
            }
        }
    }
    
    private func pushCreateAppointment() {
        let controller = CreateNewAppointmentViewController()
        push(of: controller)
    }
    
    private func pushCalendar() {
        let controller = CalendarAppointmentViewController()
        push(of: controller, animationType: .fade)
    }
    
    func showValidationAlert() {
        let dialog = UIAlertController(title: localized(of: .validationErrorTitle),
                                       message: localized(of: .validationErrorSubtitle),
                                       preferredStyle: .alert)
        let okAction = UIAlertAction(title: localized(of: .okAction), style: .cancel)
        dialog.addAction(okAction)
        present(dialog)
    }
    
    func deleteClientAlert(of client: Client,
                           index indexPath: IndexPath,
                           deleteAction: @escaping (IndexPath) -> Void) {
        let dialog = UIAlertController(title: localized(of: .confirmationDeleteTitle), message: "\(localized(of: .confirmationDeleteSubtitle)) \(client.name ?? "Маша")\(localized(of: .questionSymbol))", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: localized(of: .delete), style: .destructive) { action in
            deleteAction(indexPath)
        }
        let cancelAction = UIAlertAction(title: localized(of: .cancel), style: .cancel)
        dialog.addAction(deleteAction)
        dialog.addAction(cancelAction)
        present(dialog)
    }
}
