//
//  MainEventViewModel.swift
//  event-app
//
//  Created by Benedict Kunzmann on 04.06.23.
//

import Foundation

class MapEventViewModel: ObservableObject {
    // for event info view
    @Published var showTodaysEvents: Bool = true
    @Published var selectedDate = Date()
    @Published var selectedEvent: Event?
    @Published var shouldUpdateAnnotations: Bool = false
    @Published var presentEventInfoSheet: Bool = false
}
