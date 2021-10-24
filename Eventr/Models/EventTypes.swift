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
            return UIImage(systemName: "person.3.fill")
        case .hobby:
            return UIImage(systemName: "gamecontroller.fill")
        case .dinner:
            return UIImage(systemName: "fork.knife.circle")
        case .bar:
            return UIImage(systemName: "cup.and.saucer.fill")
        case .movie:
            return UIImage(systemName: "film.fill")
        case .sightseeing:
            return UIImage(systemName: "figure.walk")
        }
    }
}
