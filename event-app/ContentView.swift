import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var eventViewModel: EventViewModel = EventViewModel()
    @ObservedObject private var mapEventViewModel: MapEventViewModel = MapEventViewModel()
    @ObservedObject private var routeViewModel: RouteViewModel = RouteViewModel()
    @ObservedObject private var loginModel: LoginModel = LoginModel()
    
    @State private var selectedEvent: Event?
    @State private var selectedDate: Date = Date()
    @State private var selectedRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    var body: some View {
        VStack(spacing: 0) {
            if self.loginModel.authenticationState == .authenticated {
                MainEventInfoView(selectedEvent: self.$selectedEvent, selectedDate: self.$selectedDate, selectedRegion: self.$selectedRegion)
                    .ignoresSafeArea()
                    .sheet(item: self.$selectedEvent) { event in
                        EventInfoView(participations: self.$eventViewModel.participations, region: $selectedRegion, event: event, onRouteButtonPressed: {
//                            self.routeViewModel.selectedEvent = event
                            self.selectedEvent = nil
                            
//                                self.locationManager.drawRoute(eventCoordinates: self.locationManager.eventCoordinates, mapView: mapView, routeIndex: self.routeViewModel.routeIndex)
                            
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                                self.routeViewModel.showRouteInfo = true
//                                self.routeViewModel.routeIndex = 0
//                            }
                        })
                        .onAppear {
//                            self.locationManager.selectedMarker?.map = nil
                        }
                        .onDisappear {
//                            self.locationManager.selectedMarker?.map = self.locationManager.mapView
                            self.selectedEvent = nil
                        }
                    }
            }
            else {
                LoginView(loginModel: self.loginModel)
                    .ignoresSafeArea()
            }
        }
        .preferredColorScheme(.dark)
        .environment(\.locale, Locale(identifier: "de"))
        .environmentObject(self.locationManager)
        .environmentObject(self.mapEventViewModel)
        .environmentObject(self.routeViewModel)
        .environmentObject(self.eventViewModel)
        .environmentObject(self.loginModel)
        .onAppear {
            self.eventViewModel.fetchEvents(date: self.selectedDate){}
            self.eventViewModel.fetchOrganizer {}
            
            print("DEVICE VALUES")
            print("width: ", UIScreen.main.bounds.size.width)
            print("height", UIScreen.main.bounds.size.height)
            print("--------------")
        }
    }
}
