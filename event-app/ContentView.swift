import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var eventViewModel: EventViewModel = EventViewModel()
    @ObservedObject private var mapEventViewModel: MapEventViewModel = MapEventViewModel()
    @ObservedObject private var routeViewModel: RouteViewModel = RouteViewModel()

    var body: some View {
        MainEventInfoView()
            .ignoresSafeArea()
            .environmentObject(self.locationManager)
            .environmentObject(self.mapEventViewModel)
            .environmentObject(self.routeViewModel)
            .environmentObject(self.eventViewModel)
            .onAppear {
                self.locationManager.checkIfLocationServiceIsEnabled()
                self.mapEventViewModel.startingEventOffsetY =  UIScreen.main.bounds.height * 0.1
                self.routeViewModel.startingOffsetY = UIScreen.main.bounds.height * 0.66
            }
            .sheet(item: self.$mapEventViewModel.selectedEvent) { event in
                EventInfoView(event: event, onRouteButtonPressed: {
                    if let mapView = self.locationManager.mapView{
                        self.routeViewModel.selectedEvent = event
                        self.mapEventViewModel.selectedEvent = nil
                        
                        self.locationManager.drawRoute(eventCoordinates: self.locationManager.eventCoordinates, mapView: mapView, routeIndex: self.routeViewModel.routeIndex)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.mapEventViewModel.showTodaysEvents = false
                            self.routeViewModel.showRouteInfo = true
                            self.routeViewModel.routeIndex = 0
                        }
                    }
                    else {
                        print("no mapview in eventCoordinates")
                    }
                })
                    .onAppear {
                        self.locationManager.selectedMarker?.map = nil
                    }
                    .onDisappear {
                        self.locationManager.selectedMarker?.map = self.locationManager.mapView
                        self.mapEventViewModel.selectedEvent = nil
                    }
            }
        .preferredColorScheme(.light)
    }
}
