//
//  SettingCell.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 23/10/2021.
//

import UIKit

class SettingCell: UITableViewCell {
    
    @IBOutlet weak var settingLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    
    var alert: UIAlertController?
    var delegate: SettingCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true
        settingButton.isUserInteractionEnabled = true
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
        delegate?.presentCellAlert(alert!)
    }
}

protocol SettingCellDelegate {
    func presentCellAlert(_ alert: UIAlertController)
}
