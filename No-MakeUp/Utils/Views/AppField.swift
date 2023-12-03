//
//  AppField.swift
//  Instaura
//
//  Created by Димон on 26.11.23.
//

import Foundation
import UIKit

final class AppField: UITextField {
    
    private let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 10)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupTextField()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    func setupPlaceholder(_ placeholder: String) {
        self.placeholder = placeholder
    }
    
    private func setupTextField() {
        
        borderStyle = .none
        
        layer.backgroundColor = UIColor.clear.cgColor
        
        layer.cornerRadius = 10
        
        layer.borderWidth = 0.7
        layer.borderColor = UIColor.gray.cgColor
        
//        layer.shadowOpacity = 0.3
//        layer.shadowRadius = 10
//        layer.shadowOffset = CGSize(width: 10, height: 10)
//        layer.shadowColor = UIColor.gray.cgColor
        
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
