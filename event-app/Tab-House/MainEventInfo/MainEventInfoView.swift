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

    @EnvironmentObject var routeViewModel: RouteViewModel
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
                                MainEventOptionView(selectedDate: self.$selectedDate, showCalendar: self.$showCalendar)
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
    }
}

struct MainEventOptionView: View {
    
    @Binding var selectedDate: Date
    @Binding var showCalendar: Bool
    
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "E d.MM.yy"
            return formatter
        }()
    
    var body: some View {
        HStack(spacing: 20) {
            OptionPillShapeView(title: Self.dateFormatter.string(from: self.selectedDate))
            .onTapGesture {
                self.showCalendar.toggle()
            }
            
            OptionPillShapeView(title: "Stadt")
            
            OptionPillShapeView(title: "Kategorie")
            
            Spacer()
        }
        .padding(.leading)
    }
}

struct OptionPillShapeView: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .padding(5)
            .padding(.horizontal, 3)
            .font(.footnote.bold())
            .background(Capsule(style: .continuous).fill(Color("Light Purple")))
            .foregroundColor(Color("Purple"))
    }
}

struct DatePickerView: View {
    
    @Binding var selectedDate: Date
    @Binding var showCalendar: Bool
    
    @State private var calendarId: Int = 0
    
    var body: some View {
        VStack {
            Spacer()
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.calendar, .gregorianWithMondayFirst)
                .frame(maxWidth: .infinity)
                .labelsHidden()
                .padding(.horizontal, 20)
                .background(Color("Light Purple"))
                .foregroundColor(Color("Purple"))
                .accentColor(Color("Purple"))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .id(self.calendarId)
                .onChange(of: selectedDate) { _ in
                    withAnimation(.easeInOut) {
                        self.showCalendar.toggle()
                        self.calendarId += 1
                    }
                }
            Spacer()
        }
        .background(BlurView(style: .systemUltraThinMaterial).contentShape(Rectangle()).onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showCalendar.toggle()
            }
        })
        .edgesIgnoringSafeArea(.all)
    }
}
