//
//  AlertManager.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 20/10/2021.
//

import Foundation
import UIKit

struct AlertManager {
    static let shared = AlertManager()
    
    func createEventInteractionEvent() -> UIAlertController {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        return alert
    }
    
    func createInformationAlert(title: String, message: String, cancelTitle: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
        
        return alert
    }
    
    func createLocationAlert() -> UIAlertController {
        let alert = UIAlertController(title: "What's your location?", message: "Enter a city name or use your devices location if enabled.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter city name"
        }
        
        return alert
    }
}
