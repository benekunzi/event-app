//
//  MainEventInfoView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 04.06.23.
//

import Foundation
import SwiftUI

//struct MainEventInfoView: View {
//
//    @EnvironmentObject var routeViewModel: RouteViewModel
//    @EnvironmentObject var mapEventViewModel: MapEventViewModel
//    @EnvironmentObject var locationManager: LocationManager
//    @EnvironmentObject var eventViewModel: EventViewModel
//
//    @State private var selectedTab: Tab = .house
//    @State private var showCalendar = false
//
//    init() {
//        let tabBarAppearance = UITabBarAppearance()
//        tabBarAppearance.configureWithTransparentBackground()
//        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//    }
//
//    var body: some View {
//        ZStack {
//            TabView(selection: self.$selectedTab) {
//                ZStack {
//                    EventMapView()
//                        .edgesIgnoringSafeArea(.top)
//
//                    CustomSheet {
//                        MainInfoView()
//                    }
//                }
//                .tabItem {
//                    Image(systemName: "house.fill")
//                }
//                .tag(Tab.house)
//
//                SavedEventsView()
//                .edgesIgnoringSafeArea(.top)
//                .tabItem {
//                    Image(systemName: "bookmark.fill")
//                }
//                .tag(Tab.bookmark)
//
//
//                OrganizerView()
//                .tabItem {
//                    Image(systemName: "heart.fill")
//                }
//                .tag(Tab.heart)
//
//                PreferencesView()
//                .tabItem {
//                    Image(systemName: "person.fill")
//                }
//                .tag(Tab.person)
//            }
//
////                Spacer(minLength: 0)
//
////                TapbarView(selectedTab: self.$selectedTab)
////            .edgesIgnoringSafeArea(.bottom)
////            .safeAreaInset(edge: .bottom, spacing: 0) {
////                TapbarView(selectedTab: self.$selectedTab)
////            }
//
//            VStack(spacing: 0) {
//                if self.selectedTab == .house {
//                    DateSelectorView(selectedDate: self.$mapEventViewModel.selectedDate, showCalendar: self.$showCalendar)
//                }
//
//                Spacer()
//
//                if self.selectedTab == .house {
//                    MapSwitchButtonView()
//                        .padding(.bottom, 70)
//                        .padding(.bottom, getSafeAreaBottom())
//                }
//            }
//            .padding(.vertical, getSafeAreaTop())
//        }
//    }
//}

struct MainEventInfoView: View {

    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel

    @State private var selectedTab: Tab = .house
    @State private var showCalendar = false
    
    private let size = UIScreen.main.bounds.size

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    switch self.selectedTab {
                    case .house:
                        ZStack {
                            EventMapView()
                            
                            CustomSheet {
                                MainInfoView()
                            }
                        }
                    case .bookmark:
                        SavedEventsView()
                        //            case .book:
                    case .heart:
                        OrganizerView()
                    case .person:
                        PreferencesView()
                    }
                }
                .frame(maxHeight: .infinity)
                
                Spacer(minLength: 0)
                
                if self.selectedTab == .house {
                    TapbarView(selectedTab: self.$selectedTab)
                        .overlay(
                            MapSwitchButtonView()
                                .offset(y: -self.size.height / 12)
                            , alignment: .top
                        )
                }
                else {
                    TapbarView(selectedTab: self.$selectedTab)
                }
            }
            .edgesIgnoringSafeArea(.bottom)

            VStack(spacing: 0) {
                if self.selectedTab == .house {
                    DateSelectorView(selectedDate: self.$mapEventViewModel.selectedDate, showCalendar: self.$showCalendar)
                }

                Spacer()
            }
            .padding(.vertical, getSafeAreaTop())
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
