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
    @Published var startingOffsetY: CGFloat = 0.0
    @Published var endingOffsetY: CGFloat = 0.0
    @Published var currentOffsetY: CGFloat = 0.0
    @Published var routeTopOffset: CGFloat = 0
    @Published var selectedEvent: Event?
}
