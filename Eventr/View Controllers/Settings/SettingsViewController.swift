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
    var errorAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingCell.self, forCellReuseIdentifier: K.TableViews.settingCellIdentifier)
    }

    //MARK: - Helper methods
    func assignAlertToManagement(_ managementOption: AccountManagementOptions) -> UIAlertController {
        let optionDescription = managementOption.description.lowercased()
        let alert: UIAlertController!
        
        switch managementOption {
        case .displayName:
            alert = AlertManager.shared.createProfileUpdateAlert(optionDescription: optionDescription)
            alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { [weak self] action in
                guard let newValue = alert.textFields?.first?.text else {return}
                guard let self = self else {return}
                
                FirebaseAuthManager.shared.updateDisplayName(to: newValue, from: self)
            }))
        case .email:
            alert = AlertManager.shared.createCredentialChangeAlert(for: .email)
            alert.textFields?.first?.isSecureTextEntry = false
            alert.textFields?.first?.keyboardType = .emailAddress
            alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { [weak self] action in
                guard let email = FirebaseAuthManager.shared.getCurrentUser()?.email else {return}
                guard let newEmail = alert.textFields?[0].text else {return}
                guard let currentPassword = alert.textFields?[1].text else {return}
                guard let self = self else {return}

                FirebaseAuthManager.shared.reauthenticateUser(email: email, password: currentPassword, change: .email, to: newEmail, from: self)
            }))
        case .password:
            alert = AlertManager.shared.createCredentialChangeAlert(for: .password)
            alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { [weak self] action in
                guard let email = FirebaseAuthManager.shared.getCurrentUser()?.email else {return}
                guard let newPassword = alert.textFields?[0].text else {return}
                guard let currentPassword = alert.textFields?[1].text else {return}
                guard let self = self else {return}
                
                FirebaseAuthManager.shared.reauthenticateUser(email: email, password: currentPassword, change: .password, to: newPassword, from: self)
            }))
        }
        return alert
    }
    
    @objc func alertTextFieldDidChange(_ sender: UITextField, in alert: UIAlertController, for credentialType: String) {
        let validator = Validator()
        var validationRules: [Rule]
        switch credentialType {
        case "email":
            validationRules = [.notEmpty, .validEmail]
        case "password":
            validationRules = [.notEmpty, .passwordStrength]
        default:
            validationRules = [.notEmpty]
        }
        alert.actions[1].isEnabled = validator.validate(text: sender.text!, with: validationRules) == nil ? true : false
    }
    
    func assignAlertToSignOut() -> UIAlertController {
        let alert = AlertManager.shared.createInformationAlert(title: "Are you sure you want to sign out?", message: "", cancelTitle: "Cancel")
        
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] action in
            guard let self = self else {return}
            
            FirebaseAuthManager.shared.signOut(from: self)
        }))
        return alert
    }
}

//MARK: - Extensions
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
                cell.alert = assignAlertToManagement(managementOption)
            }
        case .signOut:
            cell.textLabel?.text = SignOutOptions.init(rawValue: indexPath.row)?.description
            cell.alert = assignAlertToSignOut()
        }
        return cell
    }
    
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SettingCell else {return}
        guard let alert = cell.alert else {return}
        present(alert, animated: true)
    }
}

extension SettingsViewController: FirebaseAuthManagerCompleteDelegate {
    func authenticationSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        // Not triggered
    }
    
    func signOutSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setRootViewController(to: .initial)
    }
    
    func displayNameChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        tableView.reloadData()
        let changeAlert = AlertManager.shared.createInformationAlert(title: "Display name changed", message: "", cancelTitle: "Dismiss")
        present(changeAlert, animated: true)
    }
    
    func emailChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        tableView.reloadData()
        let changeAlert = AlertManager.shared.createInformationAlert(title: "Email changed", message: "", cancelTitle: "Dismiss")
        present(changeAlert, animated: true)
    }
    
    func passwordChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        let changeAlert = AlertManager.shared.createInformationAlert(title: "Password changed", message: "", cancelTitle: "Dismiss")
        present(changeAlert, animated: true)
    }
    
    func didFailWithError(_ firebaseAuthManager: FirebaseAuthManager, _ errorMessage: String) {
        let alert = AlertManager.shared.createInformationAlert(title: "Error", message: errorMessage, cancelTitle: "Dismiss")
        present(alert, animated: true)
    } 
}
