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
    
    func login(with signInForm: SignInForm, from delegate: FirebaseAuthManagerAuthDelegate) {
        authRef.signIn(withEmail: signInForm.email, password: signInForm.password) { (authResult, error) in
            guard error == nil else {delegate.didFailWithError(self, error!); return}
            delegate.authenticationSuccessful(self)
        }
    }
    
    func register(with signUpForm: SignUpForm, from delegate: FirebaseAuthManagerAuthDelegate) {
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
    
    func signOut(from delegate: FirebaseAuthManagerAuthDelegate) {
        do {
            try authRef.signOut()
            delegate.signOutSuccessful(self)
        } catch {
            delegate.didFailWithError(self, error)
        }
    }
    
    func getCurrentUser() -> User? {
        return authRef.currentUser
    }
    
    func updateDisplayName(to displayName: String, from delegate: FirebaseAuthManagerCredentialDelegate) {
        let changeRequest = authRef.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges { error in
            if error == nil {
                delegate.displayNameChangeSuccessful(self)
            } else {
                delegate.didFailWithError(self, error!)
            }
        }
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

//MARK: - Protocols
protocol FirebaseAuthUserDelegate {
    func authenticationSuccessful(_ firebaseAuthManager: FirebaseAuthManager)
    func signOutSuccessful(_ firebaseAuthManager: FirebaseAuthManager)
}

protocol FirebaseAuthCredentialDelegate {
    func displayNameChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager)
    func emailChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager)
    func passwordChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager)
}

protocol FirebaseAuthErrorDelegate {
    func didFailWithError(_ firebaseAuthManager: FirebaseAuthManager, _ error: Error)
}

typealias FirebaseAuthManagerAuthDelegate = FirebaseAuthUserDelegate & FirebaseAuthErrorDelegate
typealias FirebaseAuthManagerCredentialDelegate = FirebaseAuthCredentialDelegate & FirebaseAuthErrorDelegate
typealias FirebaseAuthManagerCompleteDelegate = FirebaseAuthUserDelegate & FirebaseAuthCredentialDelegate & FirebaseAuthErrorDelegate


