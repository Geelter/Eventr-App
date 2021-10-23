//
//  Validator.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 24/09/2021.
//

import Foundation

class Validator {
    func validate(text: String, with rules: [Rule]) -> String? {
        return rules.compactMap({ $0.check(text) }).first
    }
    
    func validate(input: InputView, with rules: [Rule]) -> String? {
        guard let message = validate(text: input.textField.text ?? "", with: rules) else {
            input.messageLabel.isHidden = true
            return nil
        }
        
        input.messageLabel.isHidden = false
        input.messageLabel.text = message
        return "validation failed"
    }
}
