//
//  Event.swift
//  Eventr
//
//  Created by Mateusz Jabłoniec on 07/10/2021.
//

import Foundation
import MapKit
import CoreLocation
import FirebaseFirestore

struct Event: Codable {
    let creatorUID: String
    let eventID: String
    var title: String
    var type: EventTypes
    var date: String
    var city: String
    var addressDetail: String
    var location: Geopoint
    var participants: [String]
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: location.latitude, longitude: location.longitude)
    }
    var dateObject: Date {
        return DateManager.shared.dateFromString(using: date)!
    }

//    enum CodingKeys: String, CodingKey {
//        case creatorUID, eventID, title, type, date, city, addressDetail, location, participants
//    }
    
    init(creatorUID: String, title: String, type: EventTypes, date: Date, address: Address) {
        self.creatorUID = creatorUID
        self.title = title
        self.type = type
        self.date = DateManager.shared.stringFromDate(using: date)
        self.city = address.city
        self.addressDetail = address.addressDetail
        self.location = Geopoint(from: address.coordinate)
        self.participants = []
        self.eventID = Firestore.firestore().collection("events").document().documentID
    }
    
    init(updatedTitle: String, updatedtype: EventTypes, updatedDate: Date, updatedAddress: Address, originalEvent: Event) {
        title = updatedTitle
        type = updatedtype
        date = DateManager.shared.stringFromDate(using: updatedDate)
        city = updatedAddress.city
        addressDetail = updatedAddress.addressDetail
        location = Geopoint(from: updatedAddress.coordinate)
        participants = originalEvent.participants
        creatorUID = originalEvent.creatorUID
        eventID = originalEvent.eventID
    }
    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        creatorUID = try values.decode(String.self, forKey: .creatorUID)
//        eventID = try values.decode(String.self, forKey: .eventID)
//        title = try values.decode(String.self, forKey: .title)
//        type = try values.decode(EventTypes.self, forKey: .type)
//        date = try values.decode(String.self, forKey: .date)
//        city = try values.decode(String.self, forKey: .city)
//        addressDetail = try values.decode(String.self, forKey: .addressDetail)
//        location = try values.decode(Geopoint.self, forKey: .location)
//        participants = try values.decode([String].self, forKey: .participants)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(creatorUID, forKey: .creatorUID)
//        try container.encode(eventID, forKey: .eventID)
//        try container.encode(title, forKey: .title)
//        try container.encode(type, forKey: .type)
//        try container.encode(date, forKey: .date)
//        try container.encode(city, forKey: .city)
//        try container.encode(addressDetail, forKey: .addressDetail)
//        try container.encode(location, forKey: .location)
//        try container.encode(participants, forKey: .participants)
//    }
}

struct Geopoint: Codable {
    var longitude: Double
    var latitude: Double
    
//    enum CodingKeys: String, CodingKey {
//        case longitude, latitude
//    }
    
    init(from coordinate: CLLocationCoordinate2D) {
        self.longitude = coordinate.longitude
        self.latitude = coordinate.latitude
    }
    
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        latitude = try values.decode(Double.self, forKey: .latitude)
//        longitude = try values.decode(Double.self, forKey: .longitude)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(latitude, forKey: .latitude)
//        try container.encode(longitude, forKey: .longitude)
//    }
}

