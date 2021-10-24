//
//  FirestoreErrorCodeExtension.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 24/10/2021.
//

import Foundation
import FirebaseFirestore

extension FirestoreErrorCode {
    func getErrorMessage() -> String {
        switch self {
        case .alreadyExists:
            return "This document already exists."
        case .aborted:
            return "Operation was aborted. Try again."
        case .unavailable:
            return "Try again"
        case .cancelled:
            return "Operation was cancelled. Try again."
        default:
            return "Try again."
        }
    }
}
