//
//  FirebaseAuthenticationManager.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 06/10/2021.
//

import Foundation
import FirebaseAuth

struct FirebaseAuthManager {
    static let shared = FirebaseAuthManager()
    
    private let authRef = Auth.auth()
    
    //MARK: - Authentication related methods
    func login(with signInForm: SignInForm, from delegate: FirebaseAuthManagerAuthDelegate) {
        authRef.signIn(withEmail: signInForm.email, password: signInForm.password) { (authResult, error) in
            if error != nil {
                guard let errorMessage = AuthErrorCode.init(rawValue: error!._code)?.getErrorMessage() else {return}
                delegate.didFailWithError(self, errorMessage)
            } else {
                delegate.authenticationSuccessful(self)
            }
        }
    }
    
    func register(with signUpForm: SignUpForm, from delegate: FirebaseAuthManagerAuthDelegate) {
        authRef.createUser(withEmail: signUpForm.email, password: signUpForm.password) { (authResult, error) in
            if error != nil {
                guard let errorMessage = AuthErrorCode.init(rawValue: error!._code)?.getErrorMessage() else {return}
                delegate.didFailWithError(self, errorMessage)
            }
            
            let changeRequest = authRef.currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = "\(signUpForm.fName) \(signUpForm.lName)"
            changeRequest?.commitChanges { error in
                if error != nil {
                    guard let errorMessage = AuthErrorCode.init(rawValue: error!._code)?.getErrorMessage() else {return}
                    delegate.didFailWithError(self, errorMessage)
                } else {
                    delegate.authenticationSuccessful(self)
                }
            }
        }
    }
    
    func reauthenticateUser(email: String, password: String, change profileProperty: UserProfileProperties, to newValue: String, from delegate: FirebaseAuthManagerCompleteDelegate) {
        guard let user = getCurrentUser() else {return}
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user.reauthenticate(with: credential, completion: { (authResult, error) in
            guard error == nil else {return}
            switch profileProperty {
            case .displayName:
                updateDisplayName(to: newValue, from: delegate)
            case .email:
                updateUserEmail(with: newValue, from: delegate)
            case .password:
                updateUserPassword(with: newValue, from: delegate)
            }
        })
    }
    
    func signOut(from delegate: FirebaseAuthManagerAuthDelegate) {
        do {
            try authRef.signOut()
            delegate.signOutSuccessful(self)
        } catch {
            if let errorMessage = AuthErrorCode.init(rawValue: error._code)?.getErrorMessage() {
                delegate.didFailWithError(self, errorMessage)
            } else {
                print(error)
            }
        }
    }
    
    //MARK: - User profile related methods
    func getCurrentUser() -> User? {
        return authRef.currentUser
    }
    
    func updateDisplayName(to displayName: String, from delegate: FirebaseAuthManagerProfilePropertyDelegate) {
        let changeRequest = authRef.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges { error in
            if error != nil {
                let errorMessage = AuthErrorCode.init(rawValue: error!._code)?.getErrorMessage() ?? "Error. Try again."
                delegate.didFailWithError(self, errorMessage)
            } else {
                delegate.userProfilePropertyChangeSuccessful(self, propertyName: "Display name")
            }
        }
    }
    
    func updateUserEmail(with email: String, from delegate: FirebaseAuthManagerProfilePropertyDelegate) {
        authRef.currentUser?.updateEmail(to: email, completion: { error in
            if error != nil {
                let errorMessage = AuthErrorCode.init(rawValue: error!._code)?.getErrorMessage() ?? "Error. Try again."
                delegate.didFailWithError(self, errorMessage)
            } else {
                delegate.userProfilePropertyChangeSuccessful(self, propertyName: "Email")
            }
        })
    }
    
    func updateUserPassword(with password: String, from delegate: FirebaseAuthManagerProfilePropertyDelegate) {
        authRef.currentUser?.updatePassword(to: password, completion: { error in
            if error != nil {
                let errorMessage = AuthErrorCode.init(rawValue: error!._code)?.getErrorMessage() ?? "Error. Try again."
                delegate.didFailWithError(self, errorMessage)
            } else {
                delegate.userProfilePropertyChangeSuccessful(self, propertyName: "Password")
            }
        })
    }
}

//MARK: - Protocols
protocol FirebaseAuthUserDelegate {
    func authenticationSuccessful(_ firebaseAuthManager: FirebaseAuthManager)
    func signOutSuccessful(_ firebaseAuthManager: FirebaseAuthManager)
}

protocol FirebaseAuthProfilePropertyDelegate {
    func userProfilePropertyChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager, propertyName: String)
}

protocol FirebaseAuthErrorDelegate {
    func didFailWithError(_ firebaseAuthManager: FirebaseAuthManager, _ errorMessage: String)
}

typealias FirebaseAuthManagerAuthDelegate = FirebaseAuthUserDelegate & FirebaseAuthErrorDelegate
typealias FirebaseAuthManagerProfilePropertyDelegate = FirebaseAuthProfilePropertyDelegate & FirebaseAuthErrorDelegate
typealias FirebaseAuthManagerCompleteDelegate = FirebaseAuthUserDelegate & FirebaseAuthProfilePropertyDelegate & FirebaseAuthErrorDelegate


