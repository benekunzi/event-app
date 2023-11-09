//
//  Subviews.swift
//  event-app
//
//  Created by Benedict Kunzmann on 10.04.23.
//

import Foundation
import SwiftUI

struct RouteHeaderView: View {
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    
    private let size = UIScreen.main.bounds.size
    
    var body: some View {
        HStack {
            Text("Route")
                .foregroundColor(.black)
                .bold()
                .font(.title2)
            Spacer()
            Button(action: {
                self.routeViewModel.showRouteInfo = false
            }) {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 12, height: 12)
                    .frame(width: self.size.height / 71, height: self.size.height / 71)
                    .padding(8)
                    .foregroundColor(.black)
                    .background(Circle().fill(Color.gray.opacity(0.3)))
            }
        }
    }
}

struct RouteHeaderOptionsView: View {
    var body: some View {
        HStack {
            Spacer()
            Button {
            } label: {
                HStack(spacing: 10) {
                    Text(Date(), style: .time)
                    Image(systemName: "arrowtriangle.down.fill")
                }
                .font(.footnote)
                .padding(5)
                .padding(.horizontal, 5)
                .foregroundColor(.white)
                .background(Color.blue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
           
            Spacer()
            
            Button {
            } label: {
                HStack(spacing: 15) {
                    Text("Optionen")
                    Image(systemName: "arrowtriangle.down.fill")
                }
                .font(.footnote)
                .padding(5)
                .padding(.horizontal, 5)
                .foregroundColor(.white)
                .background(Color.blue)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            Spacer()
        }
    }
}

struct DepartureArrivalTimeView: View {
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    
    @State private var eventLocation: String = "Event"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("From: \("current location")")
            Divider()
            Text("To: \(self.eventLocation)")
        }
        .padding()
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .onAppear {
            guard let event = self.routeViewModel.selectedEvent else {
                print("no selected event")
                return
            }
            self.eventLocation = event.location
        }
    }
}

struct RouteOptionsView: View {
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    
    let imageSize: CGFloat = UIScreen.main.bounds.width / 21.83
    
    var body: some View {
        VStack {
            Text("")
        }
//        VStack(alignment: .leading) {
//            ForEach(Array(self.locationManager.eventCoordinates.routes.enumerated()), id: \.offset) { routeIndex, route in
//                Button {
////                    self.routeViewModel.routeIndex = routeIndex
////                    if let mapView = self.locationManager.mapView {
////                        self.locationManager.drawRoute(eventCoordinates: self.locationManager.eventCoordinates, mapView: mapView, routeIndex: self.routeViewModel.routeIndex)
////                    }
////                    else {
////                        print("no mapView")
////                    }
//                } label: {
//                    VStack (alignment: .leading){
//                        if routeIndex == self.routeViewModel.routeIndex {
//                            HStack {
//                                Text("\(route.total_duration) Min.")
//                                    .font(.system(size: 25))
//                                    .bold()
//                                    .foregroundColor(.black)
//                                Spacer()
//                                Image(systemName: "map")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .foregroundColor(Color.blue)
//                                    .frame(width: imageSize, height: imageSize)
//                            }
//                        }
//                        else {
//                            Text("\(route.total_duration) Min.")
//                                .font(.system(size: 25))
//                                .bold()
//                                .foregroundColor(.black)
//                        }
//                        HStack(spacing: 5) {
//                            ForEach(Array(route.steps.enumerated()), id: \.element) { index, step in
//                                StepInfoView(index: index, step: step, stepsCount: route.steps.count, arrivalTime: route.arrivalTime, departureTime: route.departureTime)
//                            }
//                        }
//                    }
//                }
//                Divider()
//            }
//        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct StepInfoView: View {
    let imageSize: CGFloat = 18
    let textSize: CGFloat = 10
    let index: Int
    let step: Step
    let stepsCount: Int
    let arrivalTime: Int?
    let departureTime: Int?
    
    @ViewBuilder
    var body: some View {
        if step.travel_mode == "WALKING" {
            WalkingStepView(imageSize: imageSize, textSize: textSize, step: step)
        }
        else if step.travel_mode == "TRANSIT" {
            TransitStepView(imageSize: imageSize, textSize: textSize, step: step, arrivalTime: arrivalTime, departureTime: departureTime)
        }
        if index < stepsCount - 1 {
            StepArrowView()
        }
        if stepsCount == 1 {
            Spacer()
            Text("\(step.distance.text)")
                .font(.system(size: textSize))
                .foregroundColor(Color.gray.opacity(0.9))
        }
        
        if index == stepsCount - 1 {
            if arrivalTime != nil && departureTime != nil {
                Spacer()
                VStack {
                    Text(Date(timeIntervalSince1970: TimeInterval(departureTime!)), style: .time)
                    Text(Date(timeIntervalSince1970: TimeInterval(arrivalTime!)), style: .time)
                }
                .foregroundColor(Color.gray.opacity(0.8))
                .font(.system(size: textSize))
            }
        }
    }
}

struct WalkingStepView: View {
    let imageSize: CGFloat
    let textSize: CGFloat
    let step: Step
    
    var body: some View {
        HStack {
            Image(systemName: "figure.walk")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.gray)
                .frame(width: imageSize, height: imageSize)
            Text("\(step.duration.text.shortenedDuration())")
                .font(.system(size: textSize))
        }
        .padding(5)
        .foregroundColor(Color.gray.opacity(0.9))
        .background(Color.gray.opacity(0.3))
        .cornerRadius(20)
    }
}

struct TransitStepView: View {
    let imageSize: CGFloat
    let textSize: CGFloat
    let step: Step
    let arrivalTime: Int?
    let departureTime: Int?
    
    var body: some View {
        HStack {
            if let transit_details = step.transit_details {
                Text("\(transit_details.line.name)")
                    .padding(5)
                    .background(transit_details.line.vehicle.type.VehicleToColor(transit_details.line.vehicle.type))
                    .cornerRadius(10)
                    .font(.system(size: textSize))
                    .foregroundColor(.white)
                Image(systemName: transit_details.line.vehicle.type.VehicleToImage(transit_details.line.vehicle.type))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                    .foregroundColor(Color.gray)
            }
            else {
                Text("No transit details available")
                    .font(.system(size: textSize))
            }
        }
    }
}

struct StepArrowView: View {
    var body: some View {
        Image(systemName: "arrowtriangle.right.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 5, height: 5)
            .foregroundColor(Color.black)
    }
}
