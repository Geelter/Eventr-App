//
//  MapViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 14/10/2021.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var checkIcon: UIImageView!
    @IBOutlet weak var checkButton: UIButton!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1250
    var address: Address?
    var showOnly = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.delegate = self
        
        if showOnly {
            hideButtons()
        }
        
        checkLocationServices()
        if address != nil {
            showMapAnnotation(for: address!)
        }
    }
    
    //MARK: - IBActions
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.mapToSearch, sender: self)
    }
    
    @IBAction func pickAddressButtonPressed(_ sender: Any) {
        guard address != nil else {
            let addressAlert = AlertManager.shared.createInformationAlert(title: "Search for an address first", message: "", cancelTitle: "I understand")
            present(addressAlert, animated: true)
            return
        }
        performSegue(withIdentifier: K.Segues.unwindToManipulation, sender: self)
    }
    
    @IBAction func locationPressed(_ sender: UIBarButtonItem) {
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            centerMapOnUser()
        }
    }
    
    
    //MARK: - Location Services related methods
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationPermissions()
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            let alert = AlertManager.shared.createInformationAlert(title: "This app makes use of location services.", message: "To leverage it's full functionality please turn on location services device wide.", cancelTitle: "I understand")
            present(alert, animated: true)
        }
    }
    
    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationPermissions() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if address == nil {
                centerMapOnUser()
            }
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        }
    }
    
    //MARK: - MapView related methods
    private func centerMapOnUser() {
        if let userLocation = locationManager.location?.coordinate {
            centerMap(on: userLocation)
        }
    }
    
    private func centerMap(on location: CLLocationCoordinate2D, zoom: Double = 1) {
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: (regionInMeters / zoom), longitudinalMeters: (regionInMeters / zoom))
        mapView.setRegion(region, animated: true)
    }
    
    private func createAnnotation(for mapView: MKMapView, using address: Address) {
        let annotation = MKPointAnnotation()
        annotation.title = "\(address.addressDetail), \(address.city)"
        annotation.coordinate = address.coordinate
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
    
    //MARK: - Segue related methods
    @IBAction func getAddressFromSearch(unwindSegue: UIStoryboardSegue) {
        guard let sourceVC = unwindSegue.source as? AddressSearchViewController else {return}
        
        self.address = sourceVC.address
        showMapAnnotation(for: self.address!)
    }
    
    //MARK: - Helper methods
    private func showMapAnnotation(for address: Address) {
        createAnnotation(for: mapView, using: address)
        centerMap(on: address.coordinate)
    }
    
    private func hideButtons() {
        searchIcon.isHidden = true
        searchButton.isHidden = true
        checkIcon.isHidden = true
        checkButton.isHidden = true
    }
}

//MARK: - Extensions

//MARK: - MapView Delegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {return nil}
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
}

//MARK: - CLLocationManager Delegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissions()
    }
}
