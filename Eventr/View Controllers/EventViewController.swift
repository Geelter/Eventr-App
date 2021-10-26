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
    
    func setUpInformationCell(withMessage message: String) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: K.TableViews.informationCellIdentifier)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.text = message
        
        return cell
    }

}
