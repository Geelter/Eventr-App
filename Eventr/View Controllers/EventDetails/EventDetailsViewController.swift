//
//  EventDetailsViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 22/10/2021.
//

import UIKit
import FirebaseFirestore

class EventDetailsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var typeIcon: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var participationButton: UIButton!
    
    var event: Event!
    var eventIndex: Int!
    private var participationAttempted: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillElements(using: event)
        participationAttempted = false
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        participationAttempted = false
//    }
    
    //MARK: - IBActions
    @IBAction func showOnMapPressed(_ sender: UIButton) {
        // Triggers segue to MapViewController
    }
    
    @IBAction func participationTogglePressed(_ sender: UIButton) {
        guard let uid = FirebaseAuthManager.shared.getCurrentUser()?.uid else {return}
        let index = event.participants.firstIndex(of: uid)
        if !participationAttempted {
            if index == nil {
                event.participants.append(uid)
            } else {
                event.participants.remove(at: index!)
            }
        participationAttempted = true
        }
        self.showActivityIndicator()
        FirestoreManager.shared.saveEvent(event, from: self)
    }
    
    //MARK: - Segue related methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? MapViewController else {return}
        
        destinationVC.address = Address(from: event)
        destinationVC.showOnly = true
    }
    
    //MARK: - Helper methods
    private func fillElements(using event: Event) {
        typeIcon.image = event.type.getIconForType()
        typeLabel.text = event.type.rawValue
        titleLabel.text = event.title
        dateLabel.text = DateManager.shared.getDateStringForCell(from: event.dateObject)
        addressLabel.text = event.addressDetail
        let buttonTitle = event.participants.contains(FirebaseAuthManager.shared.getCurrentUser()!.uid) ? "Leave" : "Join"
        participationButton.setTitle(buttonTitle, for: .normal)
    }
}

//MARK: - Extensions

//MARK: - Firestore Manager delegation
extension EventDetailsViewController: FirestoreManagerSaveDelegate {
    func didSaveEvent(_ firestoreManager: FirestoreManager, _ event: Event) {
        self.hideActivityIndicator()
        performSegue(withIdentifier: K.Segues.unwindToBrowse, sender: self)
    }

    func didFailWithError(_ firestoreManager: FirestoreManager, errorMessage: String) {
        self.hideActivityIndicator()
        let alert = AlertManager.shared.createInformationAlert(title: "Error declaring event participation", message: errorMessage, cancelTitle: "Dismiss")
        present(alert, animated: true)
    }
}
