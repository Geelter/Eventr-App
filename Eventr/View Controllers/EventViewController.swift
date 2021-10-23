//
//  EventViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 21/10/2021.
//

import UIKit
import FirebaseAuth

class EventViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Helper methods
    func fillElements(of cell: EventCell, using event: Event) {
        cell.eventTitleLabel.text = event.title
        cell.eventDateLabel.text = DateManager.shared.getDateStringForCell(from: event.dateObject)
        cell.eventAddressLabel.text = event.addressDetail
        cell.eventTypeIcon.image = event.type.getIconForType()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        cell.eventFavouriteIcon.image = event.participants.contains(uid) ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
    }
    
    func setUpInformationCell(withMessage message: String) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: K.TableViews.informationCellIdentifier)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = message
        
        return cell
    }
}

//MARK: - Extensions
extension EventViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: K.TableViews.informationCellIdentifier)
    }
}

extension EventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
