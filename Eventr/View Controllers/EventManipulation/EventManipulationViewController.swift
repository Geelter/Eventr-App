//
//  EventManipulationViewController.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 19/10/2021.
//

import UIKit

class EventManipulationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Date Picker related methods
    
    func setUpDatePicker(_ datePicker: UIDatePicker, with date: Date) {
        setMinDate(for: datePicker, using: date)
        setMaxDate(for: datePicker, using: date)
    }
    
    func setMaxDate(for datePicker: UIDatePicker, using date: Date) {
        var dateComponents = DateComponents()
        dateComponents.year = 1
        datePicker.maximumDate = Calendar.current.date(byAdding: dateComponents, to: date)
    }
    
    func setMinDate(for datePicker: UIDatePicker, using date: Date) {
        var dateComponents = DateComponents()
        dateComponents.day = 1
        datePicker.minimumDate = Calendar.current.date(byAdding: dateComponents, to: date)
    }
    
    //MARK: - Type Picker related methods
    
    func setUpTypePicker(_ typePicker: UIPickerView, for viewController: UIPickerViewHandler) {
        typePicker.delegate = viewController
        typePicker.dataSource = viewController
    }
}

typealias UIPickerViewHandler = UIPickerViewDelegate & UIPickerViewDataSource
