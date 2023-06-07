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
    let timeWindow: String
    var image: UIImage?

    init(title: String, coordinate: CLLocationCoordinate2D, eventDescription: String, date: Date, location: String, timeWindow: String) {
        self.title = title
        self.coordinate = coordinate
        self.eventDescription = eventDescription
        self.date = date
        self.location = location
        self.timeWindow = timeWindow
    }
}

