//
//  JoinedEventsViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 21/10/2021.
//

import UIKit
import FirebaseFirestore

class JoinedEventsViewController: EventViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    var events = [Event]()
    var delegate: EventCrossReferenceDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        fetchEvents()
    }

    // MARK: - TableView DataSource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.isEmpty ? 1 : events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if events.isEmpty {
            let cellMessage = "No events joined at this moment."
            
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
        performSegue(withIdentifier: K.Segues.joinedToDetail, sender: self)
    }
    
    //MARK: - Segue related methods
    @IBAction func unwindToBrowse(unwindSegue: UIStoryboardSegue) {
        guard let source = unwindSegue.source as? EventDetailsViewController else {return}
        guard let uid = FirebaseAuthManager.shared.getCurrentUser()?.uid else {return}
        events[source.eventIndex] = source.event
        delegate?.didChangeParticipation(self, for: source.event)
        events = events.filter { $0.participants.contains(uid) }
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
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: K.TableViews.eventCellNibName, bundle: nil), forCellReuseIdentifier: K.TableViews.eventCellIdentifier)
    }
    
    private func fetchEvents() {
        guard let uid = FirebaseAuthManager.shared.getCurrentUser()?.uid else {return}
        let fetchParameters = FetchParameters(fieldName: "participants", fieldValue: uid, fetchOperator: .arrayContains)
        self.showActivityIndicator()
        FirestoreManager.shared.fetchEvents(with: fetchParameters, from: self)
    }
}

//MARK: - Extensions

//MARK: - Firestore Manager delegation
extension JoinedEventsViewController: FirestoreManagerFetchDelegate {
    func didFetchEvents(_ firestoreManager: FirestoreManager, events: [Event]) {
        self.hideActivityIndicator()
        self.events = events.sorted(by: { $0.dateObject < $1.dateObject })
        tableView.reloadData()
    }

    func didFailWithError(_ firestoreManager: FirestoreManager, errorMessage: String) {
        self.hideActivityIndicator()
        let errorAlert = AlertManager.shared.createInformationAlert(title: "Error fetching events", message: errorMessage, cancelTitle: "Dismiss")
        present(errorAlert, animated: true)
    }
}

//MARK: - EventCrossReference Delegate
extension JoinedEventsViewController: EventCrossReferenceDelegate {
    func didChangeParticipation(_ eventViewController: EventViewController, for event: Event) {
        let eventIndex = events.firstIndex { $0.eventID == event.eventID }
        
        if eventIndex == nil {
            events.append(event)
            events.sort { $0.dateObject < $1.dateObject }
        } else {
            events.remove(at: eventIndex!)
        }
        
        tableView.reloadData()
    }
}
