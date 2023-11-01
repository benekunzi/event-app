//
//  extensions.swift
//  event-app
//
//  Created by Benedict Kunzmann on 08.04.23.
//

import Foundation
import CoreLocation

extension AllRoutes: Equatable {
    static func == (lhs: AllRoutes, rhs: AllRoutes) -> Bool {
        return lhs.coordinates == rhs.coordinates &&
        lhs.index == rhs.index &&
        lhs.steps == rhs.steps &&
        lhs.total_duration == rhs.total_duration &&
        lhs.arrivalTime == rhs.arrivalTime &&
        lhs.departureTime == rhs.departureTime
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension DirectionResponse: Equatable {
    static func == (lhs: DirectionResponse, rhs: DirectionResponse) -> Bool {
        return lhs.routes == rhs.routes
    }
}

extension Route: Equatable {
    static func == (lhs: Route, rhs: Route) -> Bool {
        return lhs.overview_polyline == rhs.overview_polyline &&
               lhs.legs == rhs.legs
    }
}

extension Leg: Equatable {
    static func == (lhs: Leg, rhs: Leg) -> Bool {
        return lhs.steps == rhs.steps
    }
}

extension Step: Equatable {
    static func == (lhs: Step, rhs: Step) -> Bool {
        return lhs.html_instructions == rhs.html_instructions &&
               lhs.polyline == rhs.polyline &&
               lhs.travel_mode == rhs.travel_mode &&
               lhs.transit_details == rhs.transit_details &&
               lhs.distance == rhs.distance
    }
}

extension TransitDetails: Equatable {
    static func == (lhs: TransitDetails, rhs: TransitDetails) -> Bool {
        return lhs.arrival_stop == rhs.arrival_stop &&
               lhs.departure_stop == rhs.departure_stop &&
               lhs.line == rhs.line &&
               lhs.arrival_time == rhs.arrival_time &&
               lhs.departure_time == rhs.departure_time &&
               lhs.num_stops == rhs.num_stops
    }
}

extension Duration: Equatable {
    static func == (lhs: Duration, rhs: Duration) -> Bool {
        return lhs.text == rhs.text &&
               lhs.value == rhs.value
    }
}

extension Stop: Equatable {
    static func == (lhs: Stop, rhs: Stop) -> Bool {
        return lhs.name == rhs.name &&
               lhs.location == rhs.location
    }
}

extension Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.lat == rhs.lat &&
               lhs.lng == rhs.lng
    }
}

extension Line: Equatable {
    static func == (lhs: Line, rhs: Line) -> Bool {
        return lhs.name == rhs.name &&
               lhs.short_name == rhs.short_name &&
               lhs.vehicle == rhs.vehicle
    }
}

extension Vehicle: Equatable {
    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        return lhs.name == rhs.name &&
               lhs.type == rhs.type
    }
}

extension Time: Equatable {
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.text == rhs.text &&
               lhs.time_zone == rhs.time_zone &&
               lhs.value == rhs.value
    }
}

extension Polyline: Equatable {
    static func == (lhs: Polyline, rhs: Polyline) -> Bool {
        return lhs.points == rhs.points
    }
}

extension Distance: Equatable {
    static func == (lhs: Distance, rhs: Distance) -> Bool {
        return lhs.text == rhs.text &&
               lhs.value == rhs.value
    }
}

extension Step: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(html_instructions)
        hasher.combine(polyline)
        hasher.combine(travel_mode)
        hasher.combine(transit_details)
        hasher.combine(duration)
    }
}

extension Polyline: Hashable {
    func hash(into hasher: inout Hasher) {
            hasher.combine(points)
        }
}

extension TransitDetails: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(arrival_stop)
        hasher.combine(departure_stop)
        hasher.combine(line)
        hasher.combine(arrival_time)
        hasher.combine(departure_time)
        hasher.combine(num_stops)
    }
}

extension Duration: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(value)
    }
}

extension Stop: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(location)
    }
}

extension Line: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(short_name)
        hasher.combine(vehicle)
    }
}

extension Time: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(time_zone)
        hasher.combine(value)
    }
}

extension Location: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(lat)
        hasher.combine(lng)
    }
}

extension Vehicle: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
    }
}

extension Distance: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(value)
    }
}

extension AllRoutes: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinates)
        hasher.combine(steps)
        hasher.combine(total_duration)
        hasher.combine(index)
        hasher.combine(arrivalTime)
        hasher.combine(departureTime)
    }
}

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(longitude)
        hasher.combine(latitude)
    }
}
