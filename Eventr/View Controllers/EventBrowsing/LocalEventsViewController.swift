//
//  LocalEventsViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 21/10/2021.
//

import UIKit
import FirebaseFirestore
import MapKit

class LocalEventsViewController: EventViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var changeCityButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var events = [Event]()
    let locationAlert = AlertManager.shared.createLocationAlert()
    var askedForLocation = false
    var delegate: EventCrossReferenceDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpAlertTextfieldAction(for: locationAlert)
        if CLLocationManager.locationServicesEnabled() {
            checkLocationPermission()
        }
        setUpTableView()
        changeCityButton.titleLabel?.textAlignment = .center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !askedForLocation {
            if locationManager.authorizationStatus == .authorizedWhenInUse {
                setUpAlertCLAction(for: locationAlert)
            }
            present(locationAlert, animated: true)
            askedForLocation = true
        }
    }
    
    //MARK: - IBActions
    @IBAction func changeCityPressed(_ sender: UIButton) {
        present(locationAlert, animated: true)
    }
    
    //MARK: - TableView DataSource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.isEmpty ? 1 : events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if events.isEmpty {
            let cellMessage = "No events matching the criteria could be fetched."
            
            return setUpInformationCell(withMessage: cellMessage)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.TableViews.eventCellIdentifier, for: indexPath) as! EventCell
            let event = events[indexPath.row]
            
            fillElements(of: cell, using: event)

            return cell
        }
    }
    
    //MARK: - TableView Delegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Segues.localToDetail, sender: self)
    }
    
    //MARK: - Location services related methods
    private func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            setUpLocationManager()
            locationManager.requestLocation()
        case .denied:
            let deniedAlert = AlertManager.shared.createInformationAlert(title: "Eventr was denied location access", message: "To use this apps full capabilities go to your location services settings and allow this app access to device location while in use", cancelTitle: "I understand")
            present(deniedAlert, animated: true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            let restrictedAlert = AlertManager.shared.createInformationAlert(title: "Use of location services restricted", message: "Your device may use parental controls to restrict use of location services. Request for permissions to use this apps full capabilities.", cancelTitle: "I understand")
            present(restrictedAlert, animated: true)
        case .authorizedAlways:
            break
        }
    }
    
    //MARK: - Segue related methods
    @IBAction func unwindToBrowse(unwindSegue: UIStoryboardSegue) {
        guard let source = unwindSegue.source as? EventDetailsViewController else {return}
        
        events[source.eventIndex] = source.event
        delegate?.didChangeParticipation(self, for: source.event)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndex = tableView.indexPathForSelectedRow else {return}
        
        guard let destinationVC = segue.destination as? EventDetailsViewController else {return}
        
        destinationVC.eventIndex = selectedIndex.row
        destinationVC.event = events[selectedIndex.row]
        tableView.deselectRow(at: selectedIndex, animated: true)
    }
    
    //MARK: - Helper methods
    private func fetchEvents(for city: String) {
        let fetchParameters = FetchParameters(fieldName: "city", fieldValue: city, fetchOperator: .equalTo)
        self.showActivityIndicator()
        FirestoreManager.shared.fetchEvents(with: fetchParameters, from: self)
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: K.TableViews.eventCellNibName, bundle: nil), forCellReuseIdentifier: K.TableViews.eventCellIdentifier)
    }
    
    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setUpAlertTextfieldAction(for alert: UIAlertController) {
        alert.addAction(UIAlertAction(title: "Use textfield", style: .default, handler: { [weak self, weak alert] action in
            guard let city = alert?.textFields?.first?.text else {return}
            
            self?.cityNameLabel.text = city
            self?.fetchEvents(for: city)
        }))
    }
    
    private func setUpAlertCLAction(for alert: UIAlertController) {
        guard let location = locationManager.location else {return}
        alert.addAction(UIAlertAction(title: "Use device location", style: .default, handler: { [weak self] action in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                guard error == nil else {return}
                guard let locality = placemarks?.last?.locality else {return}
                self?.cityNameLabel.text = locality
                self?.fetchEvents(for: locality)
            }
        }))
    }
}

//MARK: - Extensions

//MARK: - Firestore Manager delegation
extension LocalEventsViewController: FirestoreManagerFetchDelegate {
    func didFetchEvents(_ firestoreManager: FirestoreManager, events: [Event]) {
        self.hideActivityIndicator()
        guard let uid = FirebaseAuthManager.shared.getCurrentUser()?.uid else {return}
        let filteredEvents = events.filter { $0.creatorUID != uid }
        self.events = filteredEvents.sorted(by: { $0.dateObject < $1.dateObject })
        tableView.reloadData()
    }

    func didFailWithError(_ firestoreManager: FirestoreManager, errorMessage: String) {
        self.hideActivityIndicator()
        let errorAlert = AlertManager.shared.createInformationAlert(title: "Error fetching events", message: errorMessage, cancelTitle: "Dismiss")
        present(errorAlert, animated: true)
    }
}

//MARK: - CLLocationManager Delegate
extension LocalEventsViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location")
    }
}

//MARK: - EventCrossReference Delegate
extension LocalEventsViewController: EventCrossReferenceDelegate {
    func didChangeParticipation(_ eventViewController: EventViewController, for event: Event) {
        let eventIndex = events.firstIndex { $0.eventID == event.eventID }
        
        if eventIndex != nil {
            events[eventIndex!] = event
            tableView.reloadData()
        }
    }
}
