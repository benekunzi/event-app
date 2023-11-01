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
    
    private let size = UIScreen.main.bounds.size
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(eventViewModel.events.filter { $0.date.isSameDay(as: mapEventViewModel.selectedDate) }){ event in
                            
                            let (startTime, endTime) = extractStartAndEndTime(timeWindow: event.timeWindow)
                            Button {
                                //                        self.locationManager.showRouteToEvent(event: event, locationManager: locationManager.locationManager, mapView: self.locationManager.mapView!)
                                self.mapEventViewModel.selectedEvent = event
                            } label: {
                                VStack(alignment: .leading) {
                                    VStack {
                                        Image(uiImage: event.image ?? UIImage(named: "noimage")!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(maxWidth: .infinity,
                                                   minHeight: self.size.height / 4.26,
                                                   maxHeight: self.size.height / 4.26)
                                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                        
                                    }
                                    Text("\(event.title ?? "")")
                                        .font(.system(size: 15))
                                        .foregroundColor(.black)
                                        .bold()
                                    Text(event.location)
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                    HStack {
                                        Text(startTime)
                                        Text("-")
                                        Text(endTime)
                                        
                                    }
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                    
                                    Text("Eintritt: \(event.entry)€")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                    }
                }
//                
//                TopView()
//                    .frame(width: geometry.size.width, height: self.size.height / 14)
//                    .offset(y: -10)
            }
        }
    }
}

struct TopView: View {
    
    let cyan: Color = Color("cyan")
    
    var body: some View {
        ZStack {
            Rectangle()
//                .fill(Color.red)
                .fill(LinearGradient(
                    colors: [self.cyan.opacity(1),
                             self.cyan.opacity(0.8),
                             self.cyan.opacity(0.7),
                             self.cyan.opacity(0.5),
                             self.cyan.opacity(0.3),
                             self.cyan.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom))
        }
    }
}
