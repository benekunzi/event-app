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
    @EnvironmentObject var loginModel: LoginModel

    @State private var selectedTab: Tab = .house
    @State private var showCalendar = false
    @State var overlayContentBottomHeight: CGFloat = 0
    
    private let size = UIScreen.main.bounds.size

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    switch self.selectedTab {
                    case .house:
                        ZStack {
//                            EventMapView()
                            EventAppleMapView()
                            
                            CustomSheet {
                                MainInfoView(overlayContentBottomHeight: self.$overlayContentBottomHeight)
                            }
                        }
                    case .bookmark:
                        SavedEventsView(overlayContentBottomHeight: self.$overlayContentBottomHeight)
                        //            case .book:
                    case .heart:
                        OrganizerView(overlayContentBottomHeight: self.$overlayContentBottomHeight)
                    case .person:
                        PreferencesView(overlayContentBottomHeight: self.$overlayContentBottomHeight)
                    }
                }
                .frame(maxHeight: .infinity)
                
                Spacer(minLength: 0)
                
//                TapbarView(selectedTab: self.$selectedTab)
            }
            .edgesIgnoringSafeArea(.bottom)

            VStack(spacing: 0) {
                if self.selectedTab == .house {
                    HStack {
                        Spacer()
                        DateSelectorView(selectedDate: self.$mapEventViewModel.selectedDate, showCalendar: self.$showCalendar)
                        MapSwitchButtonView()
                            .padding(.top, showCalendar ? -300 : 0)
                    }
                    .padding(.top, getSafeAreaTop())

                }

                Spacer()
                
                TapBarView2(selectedTab: self.$selectedTab)
                    .padding(.bottom, getSafeAreaBottom())
                    .readHeight {
                        self.overlayContentBottomHeight = $0
                        self.overlayContentBottomHeight += 20
                        print("tapbar height", $0)
                    }
            }
        }
        .onChange(of: self.mapEventViewModel.selectedDate) { newValue in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let todaysDate = dateFormatter.string(from: newValue)
            
            if !self.eventViewModel.loadedEvents.contains(todaysDate) {
                self.eventViewModel.fetchEvents(date: newValue){}
            }
            else {
                print("date is already loaded")
            }
        }
        .onAppear {
            self.eventViewModel.getAllParticipatedEvents(
                userID: self.loginModel.user!.uid)
        }
    }
}

//            if self.routeViewModel.showRouteInfo {
//                DraggableSheet(currentOffsetY: self.$routeViewModel.currentOffsetY,
//                               endingOffsetY: self.$routeViewModel.endingOffsetY,
//                               openSheet: self.$routeViewModel.showRouteInfo,
//                               startingOffsetY: self.$routeViewModel.startingOffsetY,
//                               topOffset: self.routeViewModel.routeTopOffset) {
//                    RouteInfoView()
//                }
//                .edgesIgnoringSafeArea(.bottom)
//                .onDisappear {
//                    self.routeViewModel.routeIndex = 0
//                }
//            }
