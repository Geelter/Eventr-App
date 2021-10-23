//
//  EventTypes.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 16/10/2021.
//

import Foundation
import UIKit

enum EventTypes: String, CaseIterable, Codable {
    case general, hobby, dinner, bar, movie, sightseeing
}

extension EventTypes {
    func getIconForType() -> UIImage? {
        switch self {
        case .general:
            return UIImage(systemName: "person.3")
        case .hobby:
            return UIImage(systemName: "gamecontroller")
        case .dinner:
            return UIImage(named: "Fork")
        case .bar:
            return UIImage(systemName: "person.3")
        case .movie:
            return UIImage(systemName: "person.3")
        case .sightseeing:
            return UIImage(systemName: "person.3")
        }
    }
}
