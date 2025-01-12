//
//  EventClass.swift
//  event-app
//
//  Created by Benedict Kunzmann on 02.04.23.
//

import Foundation
import SwiftUI
import MapKit

class Event: NSObject, Identifiable, MKAnnotation {
    let id = UUID()
    let name: String
    let eventDescription: String
    let city: String
    let street: String
    let zip: String
    let houseNumber: String
    let coordinate: CLLocationCoordinate2D
    let locationName: String?
    let startDate: Date
    let endDate: Date
    let organizer: String
    let entry: Int
    let privateEvent: Bool
    let maxViewers: Int?
    let canceled: Bool
    let cancelDescription: String?
    var image: UIImage?
    let hash_value: String
    let socials: [Social]?
    let categories: [String]
    let languages: [String]
    let specials: [String]?
    
    init(name: String, eventDescription: String, city: String, street: String, zip: String, houseNumber: String, coordinate: CLLocationCoordinate2D, locationName: String?, startDate: Date, endDate: Date, organizer: String, entry: Int, privateEvent: Bool, maxViewers: Int?, canceled: Bool, cancelDescription: String?, image: UIImage? = nil, hash_value: String, socials: [Social]?, categories: [String], languages: [String], specials: [String]?) {
        self.name = name
        self.eventDescription = eventDescription
        self.city = city
        self.street = street
        self.zip = zip
        self.houseNumber = houseNumber
        self.coordinate = coordinate
        self.locationName = locationName
        self.startDate = startDate
        self.endDate = endDate
        self.organizer = organizer
        self.entry = entry
        self.privateEvent = privateEvent
        self.maxViewers = maxViewers
        self.canceled = canceled
        self.cancelDescription = cancelDescription
        self.image = image
        self.hash_value = hash_value
        self.socials = socials
        self.categories = categories
        self.languages = languages
        self.specials = specials
    }
}
