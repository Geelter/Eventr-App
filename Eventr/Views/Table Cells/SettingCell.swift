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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
