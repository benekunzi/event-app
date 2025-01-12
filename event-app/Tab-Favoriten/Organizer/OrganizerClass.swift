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
    let city: String
    var events: NSDictionary?
    var image: UIImage?
    var loadedEvents: [Event]
    var socials: [Social]?
    var persons: [Person]?
    
    init(uuid: String, name: String, beschreibung: String, city: String, loadedEvents: [Event]) {
        self.uuid = uuid
        self.city = city
        self.name = name
        self.beschreibung = beschreibung
        self.loadedEvents = loadedEvents
    }
}

class Person: NSObject, Identifiable{
    var Name: String = ""
    var Beschreibung: String = ""
    var Musikrichtung: [Musikrichtung] = []
    var Socials: [Social] = []
    var Image: UIImage?
}

class Social: NSObject, Identifiable {
    let id = UUID().uuidString
    var name: String
    var image: String
    var link: String
    
    init(name: String, image: String, link: String) {
        self.name = name
        self.image = image
        self.link = link
    }
}

class Musikrichtung: NSObject, Identifiable {
    let id = UUID().uuidString
    var genre: String
    var color: Color
    
    init(genre: String, color: Color) {
        self.genre = genre
        self.color = color
    }
}
