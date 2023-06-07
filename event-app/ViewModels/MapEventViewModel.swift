//
//  MainEventViewModel.swift
//  event-app
//
//  Created by Benedict Kunzmann on 04.06.23.
//

import Foundation

class MapEventViewModel: ObservableObject {
    // for event info view
    @Published var startingEventOffsetY: CGFloat = 0.0
    @Published var showTodaysEvents: Bool = true
    @Published var MainViewcurrentOffsetY: CGFloat = 0.0
    @Published var MainViewendingOffsetY: CGFloat = 0.0
    @Published var eventInfosTopOffset: CGFloat = 50
    @Published var selectedDate = Date()
    @Published var selectedEvent: Event?
    @Published var shouldUpdateAnnotations: Bool = false
    @Published var presentEventInfoSheet: Bool = false
}
