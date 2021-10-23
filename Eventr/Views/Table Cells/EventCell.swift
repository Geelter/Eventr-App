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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
