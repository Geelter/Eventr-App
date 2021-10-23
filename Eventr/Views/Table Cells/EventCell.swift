//
//  EventCell.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 04/10/2021.
//

import UIKit

class EventCell: UITableViewCell {

    //MARK: - Outlets
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
    
    //MARK: - Variables
    //var didSetupConstraints = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        eventDateIcon.image = UIImage(systemName: "calendar")
//        eventAddressIcon.image = UIImage(systemName: "safari")
//        eventFavouriteIcon.image = UIImage(systemName: "star")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
