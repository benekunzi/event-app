//
//  MainEventInfoView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 04.06.23.
//

import Foundation
import SwiftUI
import MapKit

struct MainEventInfoView2: View {
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var loginModel: LoginModel
    
    @Binding var selectedEvent: Event
    @Binding var selectedDate: Date
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var xAxis: CGFloat

    @State private var selectedTab: String = "house"
    @State private var showCalendar = false
    @State private var showTodaysEvents: Bool = true
    @State var overlayContentTopHeight: CGFloat = 0
    @State var userRegion: MKCoordinateRegion = MKCoordinateRegion()
    @State var didReadHeight: Bool = false
    
    private let size = UIScreen.main.bounds.size
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: self.$selectedTab)
            {
                ZStack(alignment: .top) {
                    EventAppleMapView(selectedEvent: self.$selectedEvent, selectedDate: self.$selectedDate, userRegion: self.$userRegion, selectedRegion: self.$selectedRegion)
                        .edgesIgnoringSafeArea([.bottom, .top])
                    
                    NavigationLink(
                        destination: 
                            EventInfoView(
                                overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                selectedEvent: self.$selectedEvent,
                                selectedRegion: self.$selectedRegion),
                        isActive: self.$eventViewModel.showEventSheet,
                        label: {
                            EmptyView()
                        })
                    
                    MainInfoView(overlayContentTopHeight: self.$overlayContentTopHeight,
                                 overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                 selectedDate: self.$selectedDate,
                                 selectedEvent: self.$selectedEvent,
                                 selectedRegion: self.$selectedRegion)
                    .background(BlurView(style: .light))
                    .edgesIgnoringSafeArea([.bottom, .top])
                    .offset(x:0, y: self.showTodaysEvents ? 0 : self.size.height)
                    
                    VStack(spacing: 0) {
                        HStack {
                            if !self.showTodaysEvents {
                                Spacer()
                                DateSelectorMainView(selectedDate: self.$selectedDate,
                                                     showCalendar: self.$showCalendar)
                                //                                .padding(.top, showCalendar ? 300 : 0)
                                Spacer()
                            } else {
                                MainEventOptionView(selectedDate: self.$selectedDate,
                                                    showCalendar: self.$showCalendar)
                            }
                        }
                        .padding(.top, getSafeAreaTop())
                        .padding(.bottom, 15)
                        .background(
                            ZStack {
                                if self.showTodaysEvents {
                                    BlurView(style: .systemUltraThinMaterialLight)
                                } else {
                                    Color.clear
                                }
                            }
                        )
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
                    
                    if self.showCalendar {
                        DatePickerView(selectedDate: self.$selectedDate,
                                       showCalendar: self.$showCalendar)
                        .zIndex(1)
                    }
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
            TabBarView(selectedTab: self.$selectedTab, xAxis: self.$xAxis)
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
            if self.loginModel.authenticationState == .authenticated {
                self.eventViewModel.getAllParticipatedEvents(
                    userID: self.loginModel.user!.uid)
            }
            UITabBar.appearance().isHidden = true
        }
        .animation(.easeInOut(duration: 0.3), value: self.showCalendar)
    }
}
