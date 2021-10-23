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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingCell.self, forCellReuseIdentifier: K.TableViews.settingCellIdentifier)
        //tableView.register(UINib(nibName: K.TableViews.settingCellNibName, bundle: nil), forCellReuseIdentifier: K.TableViews.settingCellIdentifier)
    }

    //MARK: - Helper methods
    func assignAlertToManagement(_ managementOption: AccountManagementOptions) -> UIAlertController {
        let optionDescription = managementOption.description.lowercased()
        let alert = AlertManager.shared.createProfileUpdateAlert(optionDescription: optionDescription)
        
        switch managementOption {
        case .displayName:
            alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { [weak self] action in
                guard let newValue = alert.textFields?.first?.text else {return}
                guard let self = self else {return}
                
                FirebaseAuthManager.shared.updateDisplayName(to: newValue, from: self)
            }))
        case .email:
            alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { [weak self] action in
                guard let newValue = alert.textFields?.first?.text else {return}
                guard let self = self else {return}
                
                FirebaseAuthManager.shared.updateUserEmail(with: newValue, from: self)
            }))
        case .password:
            break
        }
        return alert
    }
    
    func assignAlertToSignOut() -> UIAlertController {
        let alert = AlertManager.shared.createConfirmationAlert(title: "Are you sure you want to sign out?", message: "")
        
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
                cell.textLabel?.text = managementOption.description
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
        
    }
    
    func signOutSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setRootViewController(to: .initial)
    }
    
    func displayNameChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        
    }
    
    func emailChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        
    }
    
    func passwordChangeSuccessful(_ firebaseAuthManager: FirebaseAuthManager) {
        
    }
    
    func didFailWithError(_ firebaseAuthManager: FirebaseAuthManager, _ error: Error) {
        
    } 
}
