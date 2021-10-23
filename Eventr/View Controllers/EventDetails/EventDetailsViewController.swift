//
//  EventDetailsViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 22/10/2021.
//

import UIKit
import FirebaseAuth

class EventDetailsViewController: UIViewController {
    
    @IBOutlet weak var typeIcon: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var participationButton: UIButton!
    
    var event: Event!
    var eventIndex: Int!
    var participationAttempted: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillElements(using: event)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        participationAttempted = false
    }
    
    //MARK: - IBActions
    
    @IBAction func showOnMapPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func participationTogglePressed(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let index = event.participants.firstIndex(of: uid)
        if !participationAttempted {
            if index == nil {
                event.participants.append(uid)
            } else {
                event.participants.remove(at: index!)
            }
        participationAttempted = true
        }
        FirestoreManager.shared.saveEvent(event, from: self)
    }
    
    //MARK: - Segue related methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? MapViewController else {return}
        
        destinationVC.address = Address(from: event)
        destinationVC.showOnly = true
    }
    
    //MARK: - Helper methods
    
    func fillElements(using event: Event) {
        typeIcon.image = event.type.getIconForType()
        typeLabel.text = event.type.rawValue
        titleLabel.text = event.title
        dateLabel.text = DateManager.shared.getDateStringForCell(from: event.dateObject)
        addressLabel.text = event.addressDetail
    }
}

extension EventDetailsViewController: FirestoreManagerDelegate {
    func didFetchEvents(_ firestoreManager: FirestoreManager, events: [Event]) {
        
    }
    
    func didSaveEvent(_ firestoreManager: FirestoreManager, _ event: Event) {
        performSegue(withIdentifier: K.Segues.unwindToBrowse, sender: self)
    }
    
    func didDeleteEvent(_ firestoreManager: FirestoreManager) {
        
    }
    
    func didFailWithError(_ firestoreManager: FirestoreManager, error: Error?) {
        let alert = AlertManager.shared.createErrorAlert(title: "Error declaring event participation", message: "Try again")
        present(alert, animated: true)
    }
}
