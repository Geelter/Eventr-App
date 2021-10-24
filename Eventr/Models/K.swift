//
//  K.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 24/09/2021.
//

import Foundation

struct K {
    struct UserData {
        static let fName = "firstName"
        static let lName = "lastName"
        static let email = "email"
        static let password = "password"
        static let rPassword = "rPassword"
    }
    struct Segues {
        static let initialToTabBar = "InitialToTabBar"
        static let loginToTabBar = "LoginToTabBar"
        static let registerToTabBar = "RegisterToTabBar"
        static let manageToEdit = "ManageToEdit"
        static let localToDetail = "LocalToDetail"
        static let joinedToDetail = "JoinedToDetail"
        static let createToMap = "CreateToMap"
        static let detailToMap = "DetailToMap"
        static let editToMap = "EditToMap"
        static let mapToSearch = "MapToSearch"
        static let unwindToMap = "UnwindToMap"
        static let unwindToManipulation = "UnwindToManipulation"
        static let unwindToManage = "UnwindToManage"
        static let unwindToBrowse = "UnwindToBrowse"
    }
    struct TableViews {
        static let eventCellIdentifier = "EventCell"
        static let eventCellNibName = "EventCell"
        static let settingCellIdentifier = "SettingCell"
        static let settingCellNibName = "SettingCell"
        static let informationCellIdentifier = "InformationCell"
        static let informationCellNibName = "InformationCell"
    }
    struct Firestore {
        
    }
}
