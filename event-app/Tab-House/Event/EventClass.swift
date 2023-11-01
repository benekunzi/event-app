//
//  EventClass.swift
//  event-app
//
//  Created by Benedict Kunzmann on 02.04.23.
//

import Foundation
import SwiftUI
import MapKit
import UIKit

class Event: NSObject, Identifiable, MKAnnotation {
    let id = UUID()
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let eventDescription: String
    let date: Date
    let location: String
    let locationName: String
    let timeWindow: String
    var image: UIImage?
    let hash_value: String
    let organizer: String
    let entry: Int

    init(title: String, coordinate: CLLocationCoordinate2D, eventDescription: String, date: Date, location: String, locationName: String, timeWindow: String, hash_value: String, organizer: String, entry: Int) {
        self.title = title
        self.coordinate = coordinate
        self.eventDescription = eventDescription
        self.locationName = locationName
        self.date = date
        self.location = location
        self.timeWindow = timeWindow
        self.hash_value = hash_value
        self.organizer = organizer
        self.entry = entry
    }
}

