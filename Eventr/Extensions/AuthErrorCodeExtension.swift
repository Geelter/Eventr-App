//
//  AuthErrorCodeExtension.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 24/10/2021.
//

import Foundation
import FirebaseAuth

extension AuthErrorCode {
    func getErrorMessage() -> String {
        switch self {
        case .accountExistsWithDifferentCredential:
            return "Account already exists with different credential"
        case .credentialAlreadyInUse:
            return "Credential already used by a different account"
        case .emailAlreadyInUse:
            return "Email already in use"
        case .emailChangeNeedsVerification:
            return "Email change needs verification"
        case .invalidEmail:
            return "Invalid email"
        case .invalidCredential:
            return "Invalid credential"
        case .wrongPassword:
            return "Wrong password"
        default:
            return "Error during authentication. Try again."
        }
    }
}
