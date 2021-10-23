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
    
    let authRef = Auth.auth()
    
    func login(with signInForm: SignInForm, from delegate: FirebaseAuthManagerGeneralDelegate) {
        authRef.signIn(withEmail: signInForm.email, password: signInForm.password) { (authResult, error) in
            guard error == nil else {delegate.didFailWithError(self, error!); return}
            delegate.authenticationSuccessful(self)
        }
    }
    
    func register(with signUpForm: SignUpForm, from delegate: FirebaseAuthManagerGeneralDelegate) {
        authRef.createUser(withEmail: signUpForm.email, password: signUpForm.password) { (authResult, error) in
            guard error == nil else {delegate.didFailWithError(self, error!); return}
            
            let changeRequest = authRef.currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = "\(signUpForm.fName) \(signUpForm.lName)"
            changeRequest?.commitChanges { error in
                guard error == nil else {delegate.didFailWithError(self, error!); return}
                delegate.authenticationSuccessful(self)
            }
        }
    }
    
    func getCurrentUser() -> User? {
        return authRef.currentUser
    }
    
    func updateUserEmail(with email: String, from delegate: FirebaseAuthManagerCredentialDelegate) {
        authRef.currentUser?.updateEmail(to: email, completion: { error in
            guard error == nil else {delegate.didFailWithError(self, error!); return}
            
            delegate.emailChangeSuccessful(self)
        })
    }
    
    func updateUserPassword(with password: String, from delegate: FirebaseAuthManagerCredentialDelegate) {
        authRef.currentUser?.updatePassword(to: password, completion: { error in
            guard error == nil else {delegate.didFailWithError(self, error!); return}
            
            delegate.passwordChangeSuccessful(self)
        })
    }
}

protocol FirebaseAuthUserDelegate {
    func authenticationSuccessful(_ firebaseAuthManager: FirebaseAuthManager)
}

protocol FirebaseAuthCredentialDelegate {
    func emailChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager)
    func passwordChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager)
}

protocol FirebaseAuthErrorDelegate {
    func didFailWithError(_ firebaseAuthManager: FirebaseAuthManager, _ error: Error)
}

typealias FirebaseAuthManagerGeneralDelegate = FirebaseAuthUserDelegate & FirebaseAuthErrorDelegate
typealias FirebaseAuthManagerCredentialDelegate = FirebaseAuthCredentialDelegate & FirebaseAuthErrorDelegate


