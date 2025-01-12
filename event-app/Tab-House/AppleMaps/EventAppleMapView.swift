//
//  EventAppleMapView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 01.11.23.
//

import SwiftUI
import MapKit
import SceneKit

struct EventAppleMapView: View {
    @Binding var selectedEvent: Event
    @Binding var selectedDate: Date
    @Binding var userRegion: MKCoordinateRegion
    @Binding var selectedRegion: MKCoordinateRegion
    
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    
    @State var filteredEvents: [Event] = []
    @State var scene:SCNScene? = .init(named: "Cube.scn")
    
    let size: CGSize = UIScreen.main.bounds.size
        
    var body: some View {
        ZStack {
            CustomMapView(region: self.$locationManager.region,
                          selectedRegion: self.$selectedRegion,
                          selectedEvent: self.$selectedEvent,
                          filteredEvents: self.$filteredEvents,
                          size: self.size)
        }
        .edgesIgnoringSafeArea([.bottom, .top])
        .onReceive(self.locationManager.$region) { newValue in
            self.userRegion = MKCoordinateRegion(center: newValue.center, span: newValue.span)
        }
        .onChange(of: self.eventViewModel.events) { value in
            self.filteredEvents = value.filter { $0.startDate.isSameDay(as: self.selectedDate) }
        }
        .onChange(of: self.selectedDate) { value in
            self.filteredEvents = self.eventViewModel.events.filter { $0.startDate.isSameDay(as: value) }
        }
        .onAppear {
            self.filteredEvents = self.eventViewModel.events.filter { $0.startDate.isSameDay(as: self.selectedDate) }
        }
    }
}
