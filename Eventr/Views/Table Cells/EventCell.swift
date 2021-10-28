//
//  EventCell.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 04/10/2021.
//

import UIKit

class EventCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var eventTypeIcon: UIImageView!
    @IBOutlet weak var eventDateIcon: UIImageView!
    @IBOutlet weak var eventAddressIcon: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventAddressLabel: UILabel!
    @IBOutlet weak var eventFavouriteIcon: UIImageView!
    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet weak var titleStack: UIStackView!
    @IBOutlet weak var dateStack: UIStackView!
    @IBOutlet weak var addressStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func fillElements(using event: Event, uid: String) {
        self.eventTitleLabel.text = event.title
        self.eventDateLabel.text = DateManager.shared.getDateStringForCell(from: event.dateObject)
        self.eventAddressLabel.text = event.addressDetail
        self.eventTypeIcon.image = event.type.getIconForType()
        self.eventAddressIcon.image = UIImage(systemName: "map.fill")
        self.eventDateIcon.image = UIImage(systemName: "calendar")
        self.eventFavouriteIcon.image = event.participants.contains(uid) ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
    }
}
