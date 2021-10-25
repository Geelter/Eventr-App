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
        self.showActivityIndicator()
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

//MARK: - FirebaseAuth Manager delegation
extension SignInViewController: FirebaseAuthManagerAuthDelegate {
    func didFailWithError(_ firebaseAuthManager: FirebaseAuthManager, _ errorMessage: String) {
        self.hideActivityIndicator()
        let errorAlert = AlertManager.shared.createInformationAlert(title: "Error during signin attempt", message: errorMessage, cancelTitle: "Dismiss")
        present(errorAlert, animated: true)
    }
    
    func authenticationSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        self.hideActivityIndicator()
        transitionToTabBar()
    }
    
    func signOutSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        // Not called
    }
}

//MARK: - TextField Delegate
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
