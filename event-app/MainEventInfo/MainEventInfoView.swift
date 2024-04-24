//
//  MainEventInfoView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 04.06.23.
//

import Foundation
import SwiftUI
import MapKit

struct MainEventInfoView: View {

    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var loginModel: LoginModel
    
    @Binding var selectedEvent: Event?
    @Binding var selectedDate: Date
    @Binding var selectedRegion: MKCoordinateRegion

    @State private var selectedTab: Tab = .house
    @State private var showCalendar = false
    @State private var showTodaysEvents: Bool = true
    @State var overlayContentBottomHeight: CGFloat = 0
    @State var userRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    private let size = UIScreen.main.bounds.size
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    
                    if self.selectedTab == .house {
                        ZStack {
//                            EventMapView()
                            
                            EventAppleMapView(region: self.$selectedRegion, selectedEvent: self.$selectedEvent, selectedDate: self.$selectedDate, userRegion: self.$userRegion)
                            
                            CustomSheet(showTodaysEvents: self.$showTodaysEvents) {
                                MainInfoView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedDate: self.$selectedDate, selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion)
                            }
                        }
                    }
                    else if self.selectedTab == .bookmark {
                        SavedEventsView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion)
                    }
                    else if self.selectedTab == .heart {
                        OrganizerView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedEvent: self.$selectedEvent)
                    }
                    else if self.selectedTab == .person {
                        PreferencesView(overlayContentBottomHeight: self.$overlayContentBottomHeight)
                    }
//                    switch self.selectedTab {
//                    case .house:
//                        ZStack {
////                            EventMapView()
//                            
//                            EventAppleMapView(region: self.$selectedRegion, selectedEvent: self.$selectedEvent, selectedDate: self.$selectedDate)
//                            
//                            CustomSheet(showTodaysEvents: self.$showTodaysEvents) {
//                                MainInfoView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedDate: self.$selectedDate, selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion)
//                            }
//                        }
//                    case .bookmark:
//                        SavedEventsView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedEvent: self.$selectedEvent)
//                        //            case .book:
//                    case .heart:
//                        OrganizerView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedEvent: self.$selectedEvent)
//                    case .person:
//                        PreferencesView(overlayContentBottomHeight: self.$overlayContentBottomHeight)
//                    }
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
                        DateSelectorView(selectedDate: self.$selectedDate, showCalendar: self.$showCalendar)
                        MapSwitchButtonView(showTodaysEvents: self.$showTodaysEvents)
                            .padding(.top, showCalendar ? -300 : 0)
                    }
                    .padding(.top, getSafeAreaTop())

                }

                Spacer()
                
                TapBarView2(selectedTab: self.$selectedTab)
                    .padding(.bottom, (self.idiom == .pad) ? getSafeAreaBottom()+20 : getSafeAreaBottom())
                    .readHeight {
                        self.overlayContentBottomHeight = $0
                        self.overlayContentBottomHeight += 20
                        print("tapbar height", $0)
                    }
            }
        }
        .onChange(of: self.selectedDate) { newValue in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let todaysDate = dateFormatter.string(from: newValue)
            
            if !self.eventViewModel.loadedEvents.contains(todaysDate) {
                self.eventViewModel.fetchEvents(date: newValue){}
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
