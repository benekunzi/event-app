//
//  RouteViewModel.swift
//  event-app
//
//  Created by Benedict Kunzmann on 04.06.23.
//

import Foundation
import SwiftUI

class RouteViewModel: ObservableObject {
//     for route view
    @Published var routeIndex = 0
    @Published var showRouteInfo = false
    @Published var selectedEvent: Event?
}
