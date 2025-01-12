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
    
    @Binding var selectedEvent: Event
    @Binding var selectedDate: Date
    @Binding var selectedRegion: MKCoordinateRegion

    @State private var selectedTab: String = "house"
    @State private var showCalendar = false
    @State private var showTodaysEvents: Bool = true
    @State var overlayContentBottomHeight: CGFloat = 0
    @State var overlayContentTopHeight: CGFloat = 0
    @State var userRegion: MKCoordinateRegion = MKCoordinateRegion()
    @State var didReadHeight: Bool = false
    
    private let size = UIScreen.main.bounds.size
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    let whiteSmoke = Color(hue: 0, saturation: 0, brightness: 0.96)

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: self.$selectedTab) {
                ZStack(alignment: .top) {
                    EventAppleMapView(selectedEvent: self.$selectedEvent, selectedDate: self.$selectedDate, userRegion: self.$userRegion, selectedRegion: self.$selectedRegion)
                        .edgesIgnoringSafeArea(.top)
                    
                    MainInfoView(overlayContentTopHeight: self.$overlayContentTopHeight,
                                 overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                 selectedDate: self.$selectedDate,
                                 selectedEvent: self.$selectedEvent,
                                 selectedRegion: self.$selectedRegion)
                    //                    .background(whiteSmoke)
                    .background(BlurView(style: .light))
                    .edgesIgnoringSafeArea(.top)
                    .offset(x:0, y: self.showTodaysEvents ? 0 : self.size.height)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            DateSelectorMainView(selectedDate: self.$selectedDate,
                                                 showCalendar: self.$showCalendar)
                            //                                .padding(.top, showCalendar ? 300 : 0)
                            Spacer()
                        }
                        .padding(.top, getSafeAreaTop())
                        .padding(.bottom, 15)
                        .readHeight {
                            if !self.didReadHeight {
                                self.overlayContentTopHeight = $0
                                self.didReadHeight.toggle()
                            }
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            MapSwitchButtonView(showTodaysEvents: self.$showTodaysEvents)
                                .opacity(showCalendar ? 0 : 1)
                                .disabled(((showCalendar ? 0 : 1) != 1))
                        }
                        .padding(.bottom)
                    }
                    .edgesIgnoringSafeArea(.top)
                }
                
                SavedEventsView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion)

                
                OrganizerView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion)

                
                PreferencesView(overlayContentBottomHeight: self.$overlayContentBottomHeight)

            }
//            .background(Color.white)
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

struct MainEventInfoView2: View {

    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var loginModel: LoginModel
    
    @Binding var selectedEvent: Event
    @Binding var selectedDate: Date
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var overlayContentBottomHeight: CGFloat

    @State private var selectedTab: String = "house"
    @State private var showCalendar = false
    @State private var showTodaysEvents: Bool = true
    @State var overlayContentTopHeight: CGFloat = 0
    @State var userRegion: MKCoordinateRegion = MKCoordinateRegion()
    @State var didReadHeight: Bool = false
    
    private let size = UIScreen.main.bounds.size
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    let whiteSmoke = Color(hue: 0, saturation: 0, brightness: 0.96)

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: self.$selectedTab)
            {
                ZStack(alignment: .top) {
                    EventAppleMapView(selectedEvent: self.$selectedEvent, selectedDate: self.$selectedDate, userRegion: self.$userRegion, selectedRegion: self.$selectedRegion)
                        .edgesIgnoringSafeArea([.bottom, .top])
                    
                    MainInfoView(overlayContentTopHeight: self.$overlayContentTopHeight,
                                 overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                 selectedDate: self.$selectedDate,
                                 selectedEvent: self.$selectedEvent,
                                 selectedRegion: self.$selectedRegion)
                    //                    .background(whiteSmoke)
                    .background(BlurView(style: .light))
                    .edgesIgnoringSafeArea([.bottom, .top])
                    .offset(x:0, y: self.showTodaysEvents ? 0 : self.size.height)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            DateSelectorMainView(selectedDate: self.$selectedDate,
                                                 showCalendar: self.$showCalendar)
                            //                                .padding(.top, showCalendar ? 300 : 0)
                            Spacer()
                        }
                        .padding(.top, getSafeAreaTop())
                        .padding(.bottom, 15)
                        .readHeight {
                            if !self.didReadHeight {
                                self.overlayContentTopHeight = $0
                                self.didReadHeight.toggle()
                            }
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            MapSwitchButtonView(showTodaysEvents: self.$showTodaysEvents)
                                .opacity(showCalendar ? 0 : 1)
                                .disabled(((showCalendar ? 0 : 1) != 1))
                        }
                        .padding(.bottom, self.overlayContentBottomHeight)
                    }
                    .edgesIgnoringSafeArea(.top)
                }.tag("house")
                
                SavedEventsView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion)
                    .tag("bookmark")
                    .edgesIgnoringSafeArea([.bottom, .top])
                
                OrganizerView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion)
                    .tag("heart")
                    .edgesIgnoringSafeArea([.bottom, .top])
                
                PreferencesView(overlayContentBottomHeight: self.$overlayContentBottomHeight)
                    .tag("person")
                    .edgesIgnoringSafeArea([.bottom, .top])
            }
            // Custom tab bar
            TabBarView(selectedTab: self.$selectedTab)
                .readHeight {
                    self.overlayContentBottomHeight = $0
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
            UITabBar.appearance().isHidden = true
        }
    }
}
