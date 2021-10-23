//
//  Address.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 15/10/2021.
//

import Foundation
import MapKit

struct Address {
    let city: String
    let addressDetail: String
    let coordinate: CLLocationCoordinate2D
    
    init(from placemark: MKPlacemark) {
        let detailString = "\(placemark.name ?? ""), \(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")".trimmingCharacters(in: .punctuationCharacters)
        self.city = placemark.locality ?? "Outside a city area"
        self.addressDetail = detailString.trimmingCharacters(in: .whitespacesAndNewlines)
        self.coordinate = placemark.coordinate
    }
    
    init(from event: Event) {
        self.city = event.city
        self.addressDetail = event.addressDetail
        self.coordinate = event.coordinate
    }
    
}
