//
//  MainEventInfoView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 04.06.23.
//

import Foundation
import SwiftUI

struct MainEventInfoView: View {
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    
    @State private var selectedTab: Tab = .house
    
    var body: some View {
        ZStack {
            switch self.selectedTab {
            case .house:
                EventMapView()
                    
                    
                if self.mapEventViewModel.showTodaysEvents {
                    DraggableSheet(currentOffsetY: self.$mapEventViewModel.MainViewcurrentOffsetY,
                                   endingOffsetY: self.$mapEventViewModel.MainViewendingOffsetY,
                                   openSheet: self.$mapEventViewModel.showTodaysEvents,
                                   startingOffsetY: self.$mapEventViewModel.startingEventOffsetY,
                                   topOffset: self.mapEventViewModel.eventInfosTopOffset) {
                        MainInfoView()
                    }
                }
            case .person:
                Text("Einstellungen")
            }
            
            VStack {
                if self.selectedTab == .house {
                    DateSelectorView(selectedDate: self.$mapEventViewModel.selectedDate)
                        .padding()
                }
                
                Spacer()
                if self.selectedTab == .house {
                    MapSwitchButtonView()
                }
                TapbarView(selectedTab: self.$selectedTab)
            }.padding(.top, 40)
            
            if self.routeViewModel.showRouteInfo {
                DraggableSheet(currentOffsetY: self.$routeViewModel.currentOffsetY,
                               endingOffsetY: self.$routeViewModel.endingOffsetY,
                               openSheet: self.$routeViewModel.showRouteInfo,
                               startingOffsetY: self.$routeViewModel.startingOffsetY,
                               topOffset: self.routeViewModel.routeTopOffset) {
                    RouteInfoView()
                }
                .edgesIgnoringSafeArea(.bottom)
                .onDisappear {
                    self.routeViewModel.routeIndex = 0
                }
            }
        }
    }
}


struct MapSwitchButtonView: View {
    
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.mapEventViewModel.showTodaysEvents.toggle()
                }
            } label: {
                Image(systemName: self.mapEventViewModel.showTodaysEvents ? "map.fill" : "list.dash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(.blue)
                    )
            }
        }
        .padding(.horizontal)
    }
}
