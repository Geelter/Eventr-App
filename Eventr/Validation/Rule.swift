//
//  Rule.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 24/09/2021.
//

import Foundation

struct Rule {
    // Return nil if matches, error message otherwise
    let check: (String) -> String?
    
    static let notEmpty = Rule(check: {
        return $0.isEmpty ? "Must not be empty" : nil
    })
    
    static let passwordStrength = Rule(check: {
        let regex = #"^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,64}$"#
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: $0) ? nil : "Password must have 1 uppercase letter, 1 lowercase letter, 1 digit, 1 special character and be at least 8 charactes long."
    })
    
    static let validEmail = Rule(check: {
        let regex = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: $0) ? nil : "Must have valid email"
    })
}
