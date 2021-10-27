//
//  LocalEventsViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 21/10/2021.
//

import UIKit
import FirebaseFirestore
import MapKit

class LocalEventsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var changeCityButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var crossReferenceDelegate: EventCrossReferenceDelegate?
    private let locationManager = CLLocationManager()
    private var events = [Event]()
    private let locationAlert = AlertManager.shared.createLocationAlert()
    private var askedForLocation = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpAlertTextfieldAction(for: locationAlert)
        setUpAlertCLAction(for: locationAlert)
        if CLLocationManager.locationServicesEnabled() {
            checkLocationPermission()
        }
        setUpTableView()
        changeCityButton.titleLabel?.textAlignment = .center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !askedForLocation {
            if locationManager.authorizationStatus == .authorizedWhenInUse {
                locationAlert.actions[1].isEnabled = true
            }
            present(locationAlert, animated: true)
            askedForLocation = true
        }
    }
    
    //MARK: - IBActions
    @IBAction func changeCityPressed(_ sender: UIButton) {
        present(locationAlert, animated: true)
    }
    
    //MARK: - Location services related methods
    private func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            setUpLocationManager()
            locationManager.requestLocation()
        case .denied:
            let deniedAlert = AlertManager.shared.createInformationAlert(title: "Eventr was denied location access",
                                                                         message: "To use this apps full capabilities go to your location services settings and allow this app access to device location while in use",
                                                                         cancelTitle: "I understand")
            present(deniedAlert, animated: true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            let restrictedAlert = AlertManager.shared.createInformationAlert(title: "Use of location services restricted",
                                                                             message: "Your device may use parental controls to restrict use of location services. Request for permissions to use this apps full capabilities.",
                                                                             cancelTitle: "I understand")
            present(restrictedAlert, animated: true)
        case .authorizedAlways:
            break
        }
    }
    
    //MARK: - Segue related methods
    @IBAction func unwindToBrowse(unwindSegue: UIStoryboardSegue) {
        guard let source = unwindSegue.source as? EventDetailsViewController else {return}
        
        events[source.eventIndex] = source.event
        crossReferenceDelegate?.didChangeParticipation(self, for: source.event)
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
        let fetchParameters = FetchParameters(fieldName: .city, fieldValue: city, fetchOperator: .equalTo, sortBy: .date, sortDescending: false)
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
        let locationAction = UIAlertAction(title: "Use device location", style: .default, handler: { [weak self] action in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                guard error == nil else {return}
                guard let locality = placemarks?.last?.locality else {return}
                self?.cityNameLabel.text = locality
                self?.fetchEvents(for: locality)
            }
        })
        locationAction.isEnabled = false
        alert.addAction(locationAction)
    }
}

//MARK: - Extensions

//MARK: - Firestore Manager delegation
extension LocalEventsViewController: FirestoreManagerFetchDelegate {
    func didFetchEvents(_ firestoreManager: FirestoreManager, events: [Event]) {
        self.hideActivityIndicator()
        guard let uid = FirebaseAuthManager.shared.getCurrentUser()?.uid else {return}
        //self.events = filteredEvents.sorted(by: { $0.dateObject < $1.dateObject })
        self.events = events.filter { $0.creatorUID != uid }
        tableView.reloadData()
    }

    func didFailWithError(_ firestoreManager: FirestoreManager, errorMessage: String) {
        self.hideActivityIndicator()
        let errorAlert = AlertManager.shared.createInformationAlert(title: "Error fetching events", message: errorMessage, cancelTitle: "Dismiss")
        present(errorAlert, animated: true)
    }
}

//MARK: - TableView DataSource
extension LocalEventsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.isEmpty ? 1 : events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if events.isEmpty {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.textLabel?.text = "No personal events created"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.TableViews.eventCellIdentifier, for: indexPath) as! EventCell
            let event = events[indexPath.row]
            let uid = FirebaseAuthManager.shared.getCurrentUser()!.uid
            cell.fillElements(using: event, uid: uid)

            return cell
        }
    }
}

//MARK: - TableView Delegate
extension LocalEventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Segues.localToDetail, sender: self)
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
        let alert = AlertManager.shared.createInformationAlert(title: "Error trying to get location", message: "", cancelTitle: "Dismiss")
        present(alert, animated: true)
    }
}

//MARK: - EventCrossReference Delegate
extension LocalEventsViewController: EventCrossReferenceDelegate {
    func didChangeParticipation(_ eventViewController: UIViewController, for event: Event) {
        let eventIndex = events.firstIndex { $0.eventID == event.eventID }
        
        if eventIndex != nil {
            events[eventIndex!] = event
            tableView.reloadData()
        }
    }
}
