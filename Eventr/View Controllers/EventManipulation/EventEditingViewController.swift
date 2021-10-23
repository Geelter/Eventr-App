//
//  EventEditingViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 16/10/2021.
//

import UIKit
import FirebaseFirestore

class EventEditingViewController: EventManipulationViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventCity: UILabel!
    @IBOutlet weak var eventAddress: UILabel!
    
    var event: Event!
    var address: Address!
    var eventIndex: Int!
    
    var eventType = EventTypes.general
    let saveConfirmAlert = AlertManager.shared.createConfirmationAlert(title: "Are you sure you want to save your changes?", message: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDatePicker(datePicker, with: Date())
        setUpTypePicker(typePicker, for: self)
        address = Address(from: event)
        populateView()
        setUpAlertActions()
    }
    
    func updateEvent() {
        guard let title = eventTitle.text else {return}
        let event = Event(updatedTitle: title, updatedtype: eventType, updatedDate: datePicker.date, updatedAddress: address, originalEvent: self.event)
        FirestoreManager.shared.saveEvent(event, from: self)
    }
    
    //MARK: - IBActions
    @IBAction func updateEventPressed(_ sender: UIButton) {
        guard eventTitle.text!.count > 4 else {
            eventTitle.placeholder = "Title must be at least 5 characters long"
            return
        }
        guard address != nil else {return}
        
        present(saveConfirmAlert, animated: true)
    }
    
    @IBAction func changeAddressPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segues.editToMap, sender: self)
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
        
        destinationVC.address = address
    }
    
    //MARK: - Helper methods
    func populateView() {
        eventTitle.text = event.title
        setTypePickerRow(to: event.type)
        datePicker.date = event.dateObject
        eventCity.text = event.city
        eventAddress.text = event.addressDetail
    }
    
    func setTypePickerRow(to eventType: EventTypes) {
        let typeIndex = EventTypes.allCases.firstIndex(of: eventType)
        typePicker.selectRow(typeIndex!, inComponent: 0, animated: true)
    }
    
    func setUpAlertActions() {
        saveConfirmAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [weak self] action in
            self?.updateEvent()
        }))
    }
}

//MARK: - Extensions
extension EventEditingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventType = EventTypes.allCases[row]
        print(eventType.rawValue)
    }
}

extension EventEditingViewController: UIPickerViewDataSource {
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

extension EventEditingViewController: FirestoreManagerDelegate {
    func didFetchEvents(_ firestoreManager: FirestoreManager, events: [Event]) {
        print("Events fetched")
    }

    func didSaveEvent(_ firestoreManager: FirestoreManager, _ event: Event) {
        self.event = event
        performSegue(withIdentifier: K.Segues.unwindToManage, sender: self)
    }
    
    func didDeleteEvent(_ firestoreManager: FirestoreManager) {
        
    }
    
    func didFailWithError(_ firestoreManager: FirestoreManager, error: Error?) {
        guard let errorCode = FirestoreErrorCode(rawValue: error!._code) else {return}
        var message: String!
        
        switch errorCode {
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
