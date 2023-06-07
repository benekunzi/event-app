//
//  RouteInfoView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 07.04.23.
//

import Foundation
import SwiftUI

struct RouteInfoView: View {
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    
    @State var openDetailedRouteView: Bool = false

    let cremeWhite = Color(red: 250/255, green: 250/255, blue: 240/255)

    var body: some View {
        ScrollView(.vertical) {
            if !self.openDetailedRouteView {
                VStack(spacing: 15) {
                    RouteHeaderView()
                    RouteHeaderOptionsView()
                    DepartureArrivalTimeView()
                    RouteOptionsView()
                }
                Spacer()
            }
        }
        .padding()
        .background(cremeWhite)
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: Value = 0

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}


extension String {
    func shortenedDuration() -> String {
        return self.replacingOccurrences(of: "Minuten", with: "Min.")
            .replacingOccurrences(of: "Minute", with: "Min.")
    }
    
    func VehicleToImage(_ vehicleType: String) -> String {
        var systemImageString: String = "x.circle.fill"
        
        switch vehicleType {
        case "BUS":
            systemImageString = "bus.fill"
        case "SUBWAY":
            systemImageString = "tram.fill.tunnel"
        case "TRAM":
            systemImageString = "tram.fill"
        case "HEAVY_RAIL":
            systemImageString = "tram.fill"
        default:
            systemImageString = "x.circle.fill"
        }
        
        return systemImageString
    }
    
    func VehicleToColor(_ vehicleType: String) -> Color {
        var color: Color = .clear
        
        switch vehicleType {
        case "BUS":
            color = .orange
        case "SUBWAY":
            color = .teal
        case "TRAM":
            color = .purple
        case "HEAVY_RAIL":
            color = .green
        default:
            color = .red
        }
        
        return color
    }

}

extension Int {
    var formattedDuration: String {
        if self < 60 {
            return "\(self) Min."
        } else {
            let hours = self / 60
            let minutes = self % 60
            return "\(hours) Std. \(minutes) Min."
        }
    }
}
