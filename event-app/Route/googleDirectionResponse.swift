//
//  googleDirectionResponse.swift
//  event-app
//
//  Created by Benedict Kunzmann on 07.04.23.
//

import Foundation
import SwiftUI
import CoreLocation

struct AllRoutes {
    var coordinates: [CLLocationCoordinate2D]
    var steps: [Step]
    var total_duration: Int
    var index: Int
    var departureTime: Int?
    var arrivalTime: Int?
}

struct DirectionResponse: Decodable {
    let routes: [Route]
}

struct Route: Decodable {
    let overview_polyline: Polyline
    let legs: [Leg]
}

struct Leg: Decodable {
    let steps: [Step]
}

struct Step: Decodable {
    let html_instructions: String
    let polyline: Polyline
    let travel_mode: String
    let transit_details: TransitDetails?
    let duration: Duration
    let distance: Distance
}

struct TransitDetails: Decodable {
    let arrival_stop: Stop
    let arrival_time: Time
    let departure_stop: Stop
    let departure_time: Time
    let headsign: String?
    let headway: Int?
    let line: Line
    let num_stops: Int
}

struct Duration: Decodable {
    var text: String
    let value: Int
}

struct Stop: Decodable {
    let name: String
    let location: Location
}

struct Location: Decodable {
    let lat: Double
    let lng: Double
}

struct Line: Decodable {
    let name: String
    let short_name: String?
    let icon: String?
    let color: String?
    let text_color: String?
    let vehicle: Vehicle
}

struct Vehicle: Decodable {
    let name: String
    let type: String
    let icon: String?
    let local_icon: String?
}

struct Time: Decodable {
    var text: String
    let time_zone: String
    let value: Int
}

struct Polyline: Decodable {
    let points: String
}

struct Distance: Decodable {
    let text: String
    let value: Int
}
