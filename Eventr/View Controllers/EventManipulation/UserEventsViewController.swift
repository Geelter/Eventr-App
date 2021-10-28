//
//  UserEventsViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 18/10/2021.
//

import UIKit
import FirebaseFirestore

class UserEventsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    private var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        fetchEvents()
    }
    
    private func fetchEvents() {
        guard let uid = FirebaseAuthManager.shared.getCurrentUser()?.uid else {return}
        let fetchParameters = FetchParameters(fieldName: .creatorUID, fieldValue: uid, fetchOperator: .equalTo, sortBy: .date, sortDescending: false)
        self.showActivityIndicator()
        FirestoreManager.shared.fetchEvents(with: fetchParameters, from: self)
    }
    
    private func deleteEvent(_ event: Event) {
        self.showActivityIndicator()
        FirestoreManager.shared.deleteEvent(event, from: self)
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
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: K.TableViews.eventCellNibName, bundle: nil), forCellReuseIdentifier: K.TableViews.eventCellIdentifier)
    }
    
    private func setUpAlertActions(for alert: UIAlertController, from cellIndex: IndexPath) {
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
        self.hideActivityIndicator()
        self.events = events
        tableView.reloadData()
    }

    func didDeleteEvent(_ firestoreManager: FirestoreManager) {
        guard let eventIndex = tableView.indexPathForSelectedRow else {return}
        
        self.hideActivityIndicator()
        events.remove(at: eventIndex.row)
        tableView.deselectRow(at: eventIndex, animated: true)
        tableView.reloadData()
    }
    
    func didFailWithError(_ firestoreManager: FirestoreManager, errorMessage: String) {
        self.hideActivityIndicator()
        let errorAlert = AlertManager.shared.createInformationAlert(title: "Error fetching events", message: errorMessage, cancelTitle: "Dismiss")
        present(errorAlert, animated: true)
    }
}

//MARK: - TableView DataSource
extension UserEventsViewController: UITableViewDataSource {
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
            
            cell.eventFavouriteIcon.isHidden = true
            cell.fillElements(using: event, uid: uid)

            return cell
        }
    }
}

//MARK: - TableView Delegate
extension UserEventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectionAlert = AlertManager.shared.createEventInteractionEvent()
        setUpAlertActions(for: selectionAlert, from: indexPath)
        present(selectionAlert, animated: true)
    }
}

