//
//  RegisterViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 14/09/2021.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var fNameField: UITextField!
    @IBOutlet weak var lNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var rPasswordField: UITextField!
    
    @IBOutlet weak var fNameMessage: UILabel!
    @IBOutlet weak var lNameMessage: UILabel!
    @IBOutlet weak var emailMessage: UILabel!
    @IBOutlet weak var passwordMessage: UILabel!
    @IBOutlet weak var rPasswordMessage: UILabel!
    
    let validator = Validator()
    //var firebaseAuthManager = FirebaseAuthManager()
    var inputViews = [String: InputView]()
    var validationRules = [String: [Rule]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        inputViews = [
            K.UserData.fName:     InputView(textField: fNameField, messageLabel: fNameMessage),
            K.UserData.lName:     InputView(textField: lNameField, messageLabel: lNameMessage),
            K.UserData.email:     InputView(textField: emailField, messageLabel: emailMessage),
            K.UserData.password:  InputView(textField: passwordField, messageLabel: passwordMessage),
            K.UserData.rPassword: InputView(textField: rPasswordField, messageLabel: rPasswordMessage)
        ]
        
        validationRules = [
            K.UserData.fName:     [.notEmpty],
            K.UserData.lName:     [.notEmpty],
            K.UserData.email:     [.notEmpty, .validEmail],
            K.UserData.password:  [.notEmpty, .passwordStrength],
            K.UserData.rPassword: [.notEmpty]
        ]
        
        for (_, view) in inputViews {
            view.textField.delegate = self
            view.messageLabel.isHidden = true
        }
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if validateUserInput() != 0 {print("validation failed")}
        let signUpData = trimInput(from: inputViews)
        FirebaseAuthManager.shared.register(with: signUpData, from: self)
    }
    
    //MARK: - Form Input Sanitazation
    func trimInput(from inputViews: [String: InputView]) -> SignUpForm {
        var formData = [String: String]()
        for (key, inputView) in inputViews {
            formData[key] = inputView.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let signUpForm = SignUpForm(email: formData[K.UserData.email]!, password: formData[K.UserData.password]!, fName: formData[K.UserData.fName]!, lName: formData[K.UserData.lName]! )
        
        return signUpForm
    }
    
    //MARK: - TextField text changed action (called on EditingChanged and EditingDidEnd)
    @IBAction func textFieldTextChanged(_ sender: UITextField) {
        // May think about doing something with this line
        guard let key = sender.accessibilityIdentifier else {return}
        
        _ = validator.validate(input: inputViews[key]!, with: validationRules[key]!)
    }
    
    //MARK: - Validation related methods
    func validateUserInput() -> Int {
        var validationsFailed = 0
        
        for (key, inputView) in inputViews {
            if validator.validate(input: inputView, with: validationRules[key]!) != nil {validationsFailed += 1}
        }
        if !passwordsMatch(pass1: inputViews[K.UserData.password]!, pass2: inputViews[K.UserData.rPassword]!) {validationsFailed += 1}
        return validationsFailed
    }
    
    func passwordsMatch(pass1: InputView, pass2: InputView) -> Bool {
        if pass1.textField.text! != pass2.textField.text {
            pass2.messageLabel.text = "Passwords must be identical"
            pass2.messageLabel.isHidden = false
            return false
        } else {
            pass2.messageLabel.isHidden = true
            return true
        }
    }
    
    //MARK: - Navigation related methods
    
    func transitionToTabBar() {
        let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setRootViewController(tabBarController)
    }
}

extension SignUpViewController: FirebaseAuthManagerGeneralDelegate {
    func didFailWithError(_ firebaseAuthManager: FirebaseAuthManager, _ error: Error) {
        guard let errorCode = AuthErrorCode(rawValue: error._code) else {return}
        
        var message: String!
        
        switch errorCode {
        case .invalidEmail:
            message = "Invalid email"
        case .emailAlreadyInUse:
            message = "Email already in use"
        case .weakPassword:
            message = "Password too weak"
        default:
            message = "Error during registration attempt: \(error)"
        }
        
        let errorAlert = AlertManager.shared.createErrorAlert(title: "Error during signup attempt", message: message)
        present(errorAlert, animated: true)
    }
    
    func authenticationSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        transitionToTabBar()
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fNameField:
            lNameField.becomeFirstResponder()
        case lNameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            rPasswordField.becomeFirstResponder()
        default:
            rPasswordField.resignFirstResponder()
        }
        return true
    }
}
