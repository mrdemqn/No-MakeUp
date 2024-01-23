//
//  TableViewExtensions.swift
//  No-MakeUp
//
//  Created by Димон on 14.12.23.
//

import UIKit

extension UITableView {

    func setEmptyView() {
        let stack = UIStackView()
        stack.axis = .vertical
        let titleLabel = UILabel()
        let imageView = UIImageView()
        
//        emptyView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = localized(of: .noAppointmentsYet)
        titleLabel.textColor = .darkGray
        titleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        
        imageView.image = UIImage(resource: .sadEmoji).withTintColor(.darkGray)
        imageView.sizeToFit()
        
        stack.addSubview(titleLabel)
        stack.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: stack.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: stack.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: stack.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        backgroundView = stack
    }
    func clearBackgroundView() {
        backgroundView = nil
    }
}
