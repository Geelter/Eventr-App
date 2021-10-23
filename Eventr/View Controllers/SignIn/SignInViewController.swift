//
//  LoginViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 14/09/2021.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailMessage: UILabel!
    @IBOutlet weak var passwordMessage: UILabel!
    
    var inputViews = [String: InputView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inputViews = [
            K.UserData.email:    InputView(textField: emailField, messageLabel: emailMessage),
            K.UserData.password: InputView(textField: passwordField, messageLabel: passwordMessage)
        ]
        
        for (_, inputView) in inputViews {
            inputView.textField.delegate = self
            inputView.messageLabel.isHidden = true
        }
    }
    
    //MARK: - IBActions
    @IBAction func loginPressed(_ sender: UIButton) {
        let signInData = trimInput(from: inputViews)
        FirebaseAuthManager.shared.login(with: signInData, from: self)
    }
    
    //MARK: - Form Input Sanitazation
    func trimInput(from inputViews: [String: InputView]) -> SignInForm {
        var formData = [String: String]()
        for (key, inputView) in inputViews {
            formData[key] = inputView.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let signInForm = SignInForm(email: formData[K.UserData.email]!, password: formData[K.UserData.password]!)
        
        return signInForm
    }

    //MARK: - Navigation related methods
    func transitionToTabBar() {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setRootViewController(to: .tabBar)
    }
}

//MARK: - Extensions
extension SignInViewController: FirebaseAuthManagerAuthDelegate {
    func didFailWithError(_ firebaseAuthManager: FirebaseAuthManager, _ error: Error) {
        guard let errorCode = AuthErrorCode(rawValue: error._code) else {return}
        
        var message: String!
        
        switch errorCode {
        case .wrongPassword:
            message = "Wrong password"
        case .userNotFound:
            message = "No user with this email address"
        default:
            message = "Error during login attempt: \(error)"
        }
        let errorAlert = AlertManager.shared.createErrorAlert(title: "Error during signin attempt", message: message)
        present(errorAlert, animated: true)
    }
    
    func authenticationSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        transitionToTabBar()
    }
    
    func signOutSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        
    }
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        default:
            passwordField.resignFirstResponder()
        }
        return true
    }
}
