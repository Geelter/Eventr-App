//
//  SettingsViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 23/10/2021.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    var user = FirebaseAuthManager.shared.getCurrentUser()
    var currentAlert: UIAlertController!
    var firstTextFieldCorrect = false
    var secondTextFieldCorrect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setUpTableView()
    }

    //MARK: - Alert creation methods
    private func createSignOutAlert() -> UIAlertController {
        let alert = AlertManager.shared.createInformationAlert(title: "Are you sure you want to sign out?", message: "", cancelTitle: "Cancel")
        
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] action in
            guard let self = self else {return}
            
            FirebaseAuthManager.shared.signOut(from: self)
        }))
        return alert
    }
    
    private func createProfilePropertyChangeAlert(for property: AccountManagementOptions) -> UIAlertController {
        let propertyDescription = property.description.lowercased()
        let alert = UIAlertController(title: "Change your \(propertyDescription)", message: "Enter your new \(propertyDescription) and current password", preferredStyle: .alert)
                
        alert.addTextField { textField in
            textField.placeholder = "New \(propertyDescription)"
            textField.isSecureTextEntry = property == .password ? true : false
            textField.returnKeyType = .continue
            textField.tag = self.textFieldTag(for: property)
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Current password"
            textField.isSecureTextEntry = true
            textField.returnKeyType = .continue
            textField.tag = 4
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        let changeAction = UIAlertAction(title: "Change", style: .default, handler: { [weak self] action in
            guard let email = FirebaseAuthManager.shared.getCurrentUser()?.email,
                  let newValue = alert.textFields?.first?.text,
                  let currentPassword = alert.textFields?[1].text,
                  let self = self
            else {return}
            
            switch property {
            case .displayName:
                FirebaseAuthManager.shared.reauthenticateUser(email: email, password: currentPassword, change: .displayName, to: newValue, from: self)
            case .email:
                FirebaseAuthManager.shared.reauthenticateUser(email: email, password: currentPassword, change: .email, to: newValue, from: self)
            case .password:
                FirebaseAuthManager.shared.reauthenticateUser(email: email, password: currentPassword, change: .password, to: newValue, from: self)
            }
            self.currentAlert = nil
            action.isEnabled = false
        })
        changeAction.isEnabled = false
        alert.addAction(changeAction)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
    }
    
    //MARK: - Alert TextField input validation methods
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        validateTextField(tag: sender.tag, text: sender.text!)
        if firstTextFieldCorrect && secondTextFieldCorrect {
            currentAlert.actions.first?.isEnabled = true
        } else {
            currentAlert.actions.first?.isEnabled = false
        }
    }
    
    func validateTextField(tag: Int, text: String) {
        let validator = Validator()
        switch tag {
        case 0:
            firstTextFieldCorrect = validator.validate(text: text, with: [.notEmpty]) == nil ? true : false
        case 1:
            firstTextFieldCorrect = validator.validate(text: text, with: [.notEmpty, .validEmail]) == nil ? true : false
        case 2:
            firstTextFieldCorrect = validator.validate(text: text, with: [.notEmpty, .passwordStrength]) == nil ? true : false
        default:
            secondTextFieldCorrect = validator.validate(text: text, with: [.notEmpty]) == nil ? true : false
        }
    }
    
    //MARK: - Helper methods
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingCell.self, forCellReuseIdentifier: K.TableViews.settingCellIdentifier)
    }
    
    private func textFieldTag(for property: AccountManagementOptions) -> Int {
        return property.rawValue
    }
}

//MARK: - Extensions

//MARK: - TableView DataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingsSections(rawValue: section)?.description
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSections.init(rawValue: section) else {return 0}
        
        switch section {
        case .accountManagement:
            return AccountManagementOptions.allCases.count
        case .signOut:
            return SignOutOptions.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.TableViews.settingCellIdentifier, for: indexPath) as! SettingCell
        
        cell.selectionStyle = .none
        cell.accessoryType = .detailDisclosureButton
        
        guard let section = SettingsSections.init(rawValue: indexPath.section) else {return UITableViewCell()}
        
        switch section {
        case .accountManagement:
            if let managementOption = AccountManagementOptions(rawValue: indexPath.row) {
                cell.textLabel?.text = managementOption.userProfileProperty
                cell.alert = createProfilePropertyChangeAlert(for: managementOption)
            }
        case .signOut:
            cell.textLabel?.text = SignOutOptions.init(rawValue: indexPath.row)?.description
            cell.alert = createSignOutAlert()
        }
        return cell
    }
    
}

//MARK: - TableView Delegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SettingCell else {return}
        if cell.alert != nil {
            currentAlert = cell.alert!
            present(currentAlert, animated: true)
        }
    }
}

//MARK: - FirebaseAuth Manager delegation
extension SettingsViewController: FirebaseAuthManagerCompleteDelegate {
    func authenticationSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        // Not triggered
    }
    
    func userProfilePropertyChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager, propertyName: String) {
        tableView.reloadData()
        let changeAlert = AlertManager.shared.createInformationAlert(title: "\(propertyName) changed", message: "", cancelTitle: "Dismiss")
        present(changeAlert, animated: true)
    }
    
    func signOutSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setRootViewController(to: .initial)
    }
    
    func didFailWithError(_ firebaseAuthManager: FirebaseAuthManager, _ errorMessage: String) {
        let alert = AlertManager.shared.createInformationAlert(title: "Error", message: errorMessage, cancelTitle: "Dismiss")
        present(alert, animated: true)
    } 
}
