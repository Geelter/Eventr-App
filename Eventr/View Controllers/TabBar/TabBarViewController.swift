//
//  TabBarViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 17/10/2021.
//

import UIKit
import MapKit

class TabBarViewController: UITabBarController {
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationPermissions()
    }
    
    func checkLocationPermissions() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            break
        case .denied:
            let deniedAlert = AlertManager.shared.createConfirmationAlert(title: "Eventr was denied location access", message: "To use this apps full capabilities go to your location services settings and allow this app access to device location while in use")
            present(deniedAlert, animated: true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            let restrictedAlert = AlertManager.shared.createInformationAlert(title: "Use of location services restricted", message: "Your device may use parental controls to restrict use of location services. Request for permissions to use this apps full capabilities.")
            present(restrictedAlert, animated: true)
        case .authorizedAlways:
            break
        }
    }
}

//MARK: - Extensions

extension TabBarViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissions()
    }
}
