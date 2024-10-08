//
//  StaticFunc.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 08.10.2024.
//

import Foundation
import UIKit

class StaticFunc {
    
    static func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = .white.withAlphaComponent(0.05)
        textField.layer.cornerRadius = 12
        textField.placeholder = placeholder
        textField.textColor = .white
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        return textField
    }
    
    static func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white.withAlphaComponent(0.7)
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }
}
