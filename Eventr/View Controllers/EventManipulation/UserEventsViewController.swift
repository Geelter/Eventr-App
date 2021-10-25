//
//  UserEventsViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 18/10/2021.
//

import UIKit
import FirebaseFirestore

class UserEventsViewController: EventViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        fetchEvents()
    }
    
    func fetchEvents() {
        guard let uid = FirebaseAuthManager.shared.getCurrentUser()?.uid else {return}
        print(uid)
        let fetchParameters = FetchParameters(fieldName: "creatorUID", fieldValue: uid, fetchOperator: .equalTo)
        FirestoreManager.shared.fetchEvents(with: fetchParameters, from: self)
    }
    
    func deleteEvent(_ event: Event) {
        FirestoreManager.shared.deleteEvent(event, from: self)
    }

    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.isEmpty ? 1 : events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if events.isEmpty {
            let cellMessage = "No personal events created."
            
            return setUpInformationCell(withMessage: cellMessage)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.TableViews.eventCellIdentifier, for: indexPath) as! EventCell
            let event = events[indexPath.row]
            
            cell.eventFavouriteIcon.isHidden = true
            fillElements(of: cell, using: event)

            return cell
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectionAlert = AlertManager.shared.createEventInteractionEvent()
        setUpAlertActions(for: selectionAlert, from: indexPath)
        present(selectionAlert, animated: true)
    }
    
    //MARK: - Segue related methods
    @IBAction func appendFromCreation(unwindSegue: UIStoryboardSegue) {
        guard let source = unwindSegue.source as? EventCreationViewController else {return}
        
        events.append(source.event!)
        events.sort(by: { $0.dateObject < $1.dateObject })
        tableView.reloadData()
    }
    
    @IBAction func updateFromEditing(unwindSegue: UIStoryboardSegue) {
        guard let source = unwindSegue.source as? EventEditingViewController else {return}
        
        events[source.eventIndex] = source.event
        events.sort(by: { $0.dateObject < $1.dateObject })
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndex = tableView.indexPathForSelectedRow?.row else {return}
        
        guard let destinationVC = segue.destination as? EventEditingViewController else {return}
        
        destinationVC.event = events[selectedIndex]
        destinationVC.eventIndex = selectedIndex
    }
    
    //MARK: - Helper methods
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: K.TableViews.eventCellNibName, bundle: nil), forCellReuseIdentifier: K.TableViews.eventCellIdentifier)
    }
    
    func setUpAlertActions(for alert: UIAlertController, from cellIndex: IndexPath) {
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] action in
            self?.performSegue(withIdentifier: K.Segues.manageToEdit, sender: self)
            self?.tableView.deselectRow(at: cellIndex, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] action in
            guard let event = self?.events[cellIndex.row] else {return}
            self?.deleteEvent(event)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] action in
            self?.tableView.deselectRow(at: cellIndex, animated: true)
        }))
    }
}

//MARK: - Extensions

//MARK: - Firestore Manager delegation
extension UserEventsViewController: FirestoreManagerFetchDelegate, FirestoreDeleteDelegate {
    func didFetchEvents(_ firestoreManager: FirestoreManager, events: [Event]) {
        self.events = events.sorted(by: { $0.dateObject < $1.dateObject })
        tableView.reloadData()
    }

    func didDeleteEvent(_ firestoreManager: FirestoreManager) {
        guard let eventIndex = tableView.indexPathForSelectedRow else {return}
        
        events.remove(at: eventIndex.row)
        tableView.deselectRow(at: eventIndex, animated: true)
        tableView.reloadData()
    }
    
    func didFailWithError(_ firestoreManager: FirestoreManager, errorMessage: String) {
        let errorAlert = AlertManager.shared.createInformationAlert(title: "Error fetching events", message: errorMessage, cancelTitle: "Dismiss")
        present(errorAlert, animated: true)
    }
}
