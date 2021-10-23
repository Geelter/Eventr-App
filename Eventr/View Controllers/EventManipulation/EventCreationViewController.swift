//
//  EventManipulationViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 14/10/2021.
//

import UIKit
import FirebaseFirestore

class EventCreationViewController: EventManipulationViewController {
    
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventCity: UILabel!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var addressChangeButton: UIButton!
    
    var event: Event?
    var address: Address?
    
    var eventType = EventTypes.general
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDatePicker(datePicker, with: Date())
        setUpTypePicker(typePicker, for: self)
    }
    
    //MARK: - IBActions
    @IBAction func chooseAddressPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.createToMap, sender: self)
    }
    
    @IBAction func saveEventPressed(_ sender: UIButton) {
        guard eventTitle.text!.count > 4 && eventTitle.text!.count <= 60 else {
            eventTitle.placeholder = "Title must be between 5 and 60 characters"
            return
        }
        guard address != nil else {return}
        
        createEvent()
    }
    
    //MARK: - Helper functions
    
    func createEvent() {
        if let uid = FirebaseAuthManager.shared.getCurrentUser()?.uid, let title = eventTitle.text {
            let event = Event(creatorUID: uid, title: title, type: eventType, date: datePicker.date, address: address!)
            self.event = event
            FirestoreManager.shared.saveEvent(event, from: self)
        }
    }
    
    func setTypePickerRow(to eventType: EventTypes) {
        let typeIndex = EventTypes.allCases.firstIndex(of: eventType)
        typePicker.selectRow(typeIndex!, inComponent: 0, animated: true)
    }

    //MARK: - Segue related methods
    @IBAction func getAddressFromMap(unwindSegue: UIStoryboardSegue) {
        guard let sourceVC = unwindSegue.source as? MapViewController else {return}
        
        address = sourceVC.address
        eventCity.text = address?.city
        eventAddress.text = address?.addressDetail
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? MapViewController else {return}
        
        if address != nil {
            destinationVC.address = address
        }
    }
}

extension EventCreationViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventType = EventTypes.allCases[row]
        print(eventType.rawValue)
    }
}

extension EventCreationViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EventTypes.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EventTypes.allCases[row].rawValue
    }
}

extension EventCreationViewController: FirestoreManagerDelegate {
    func didFetchEvents(_ firestoreManager: FirestoreManager, events: [Event]) {
        
    }
    
    func didSaveEvent(_ firestoreManager: FirestoreManager, _ event: Event) {
        performSegue(withIdentifier: K.Segues.unwindToManage, sender: self)
    }
    
    func didDeleteEvent(_ firestoreManager: FirestoreManager) {
        
    }
    
    func didFailWithError(_ firestoreManager: FirestoreManager, error: Error?) {
        guard let errorCode = FirestoreErrorCode(rawValue: error!._code) else {return}
        var message: String!
        
        switch errorCode {
        case .alreadyExists:
            message = "This document already exists."
        case .aborted:
            message = "Operation was aborted. Try again."
        case .unavailable:
            message = "Try again"
        default:
            message = "Error during event saving. Try again."
        }
        
        let errorAlert = AlertManager.shared.createErrorAlert(title: "Error saving event", message: message)
        present(errorAlert, animated: true)
    }
    
    
}
