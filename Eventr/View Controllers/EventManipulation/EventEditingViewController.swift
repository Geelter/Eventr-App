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
    let saveConfirmAlert = AlertManager.shared.createInformationAlert(title: "Are you sure you want to save your changes?", message: "", cancelTitle: "Cancel")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDatePicker(datePicker, with: Date())
        setUpTypePicker(typePicker, for: self)
        address = Address(from: event)
        populateView()
        setUpAlertActions()
        eventTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func updateEvent() {
        guard let title = eventTitle.text else {return}
        let event = Event(updatedTitle: title, updatedtype: eventType, updatedDate: datePicker.date, updatedAddress: address, originalEvent: self.event)
        self.showActivityIndicator()
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

//MARK: - PickerView Delegate
extension EventEditingViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        eventType = EventTypes.allCases[row]
        print(eventType.rawValue)
    }
}

//MARK: - PickerView DataSource
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

//MARK: - Firestore Manager delegation
extension EventEditingViewController: FirestoreManagerSaveDelegate {
    func didSaveEvent(_ firestoreManager: FirestoreManager, _ event: Event) {
        self.hideActivityIndicator()
        self.event = event
        performSegue(withIdentifier: K.Segues.unwindToManage, sender: self)
    }

    func didFailWithError(_ firestoreManager: FirestoreManager, errorMessage: String) {
        self.hideActivityIndicator()
        let errorAlert = AlertManager.shared.createInformationAlert(title: "Error saving event", message: errorMessage, cancelTitle: "Dismiss")
        present(errorAlert, animated: true)
    }

}
