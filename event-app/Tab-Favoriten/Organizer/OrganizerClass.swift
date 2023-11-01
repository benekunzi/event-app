//
//  organizer.swift
//  event-app
//
//  Created by Benedict Kunzmann on 11.08.23.
//

import Foundation
import SwiftUI

class Organizer: NSObject, Identifiable {
    let uuid: String
    let name: String
    let beschreibung: String
    let email: String
    let events: [String]
    var image: UIImage?
    
    init(uuid: String, name: String, beschreibung: String, email: String, events: [String]) {
        self.uuid = uuid
        self.name = name
        self.beschreibung = beschreibung
        self.email = email
        self.events = events
    }
}
