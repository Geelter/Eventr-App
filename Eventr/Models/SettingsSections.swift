//
//  SettingsSections.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 23/10/2021.
//

import Foundation

enum SettingsSections: Int, CaseIterable, CustomStringConvertible {
    case accountManagement
    case signOut
    
    var description: String {
        switch self {
        case .accountManagement:
            return "Account Management"
        case .signOut:
            return "Sign Out"
        }
    }
}

enum AccountManagementOptions: Int, CaseIterable, CustomStringConvertible {
    case displayName
    case email
    case password
    
    var description: String {
        switch self {
        case .displayName:
            return "Display Name"
        case .email:
            return "Email"
        case .password:
            return "Password"
        }
    }
}

enum SignOutOptions: Int, CaseIterable, CustomStringConvertible {
    case signOut
    
    var description: String {
        switch self {
        case .signOut:
            return "Sign Out"
        }
    }
}
