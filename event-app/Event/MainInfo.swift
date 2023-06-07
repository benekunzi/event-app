//
//  MainInfo.swift
//  event-app
//
//  Created by Benedict Kunzmann on 24.04.23.
//

import Foundation
import SwiftUI

struct MainInfoView: View {
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 25) {
                ForEach(eventViewModel.events.filter { $0.date.isSameDay(as: mapEventViewModel.selectedDate) }){ event in
                    
                    let (startTime, endTime) = extractStartAndEndTime(timeWindow: event.timeWindow)
                    Button {
                        self.locationManager.showRouteToEvent(event: event, locationManager: locationManager.locationManager, mapView: self.locationManager.mapView!)
                        self.mapEventViewModel.selectedEvent = event
                    } label: {
                        VStack(alignment: .leading) {
                            VStack {
                                Image(uiImage: event.image ?? UIImage(named: "noimage")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(15)
                            }
                            Text("\(event.title ?? "")")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .bold()
                            Text(event.location)
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                            HStack {
                                Text(startTime)
                                Text("-")
                                Text(endTime)
                                
                            }
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            
                            Text("Eintritt: Frei")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                    }
                }
                
            }
        }
    }
}
