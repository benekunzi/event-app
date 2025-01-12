import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var eventViewModel: EventViewModel = EventViewModel()
    @ObservedObject private var mapEventViewModel: MapEventViewModel = MapEventViewModel()
    @ObservedObject private var loginModel: LoginModel = LoginModel()
    
    @State private var selectedEvent: Event = Event(
        name: "",
        eventDescription: "",
        city: "",
        street: "",
        zip: "",
        houseNumber: "",
        coordinate: CLLocationCoordinate2D(),
        locationName: "",
        startDate: Date(),
        endDate: Date(),
        organizer: "",
        entry: 0,
        privateEvent: false,
        maxViewers: 0,
        canceled: false,
        cancelDescription: "",
        hash_value: "",
        socials: [],
        categories: [],
        languages: [],
        specials: [])
    @State private var selectedDate: Date = Date()
    @State private var selectedRegion: MKCoordinateRegion = MKCoordinateRegion()
    @State var overlayContentBottomHeight: CGFloat = 0
    
    @State private var hasEvents: Bool = false
    @State private var loadedWithoutEvents: Bool = false
    @State var timeElapsed: Int = 0
    @State var startDate = Date()
    @State var xAxis: CGFloat = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if (self.loginModel.authenticationState == .authenticated || self.loginModel.authenticationState == .skipped)  {
                    if (self.hasEvents || self.loadedWithoutEvents) {
                        ZStack {
                            MainEventInfoView2(selectedEvent: self.$selectedEvent,
                                               selectedDate: self.$selectedDate,
                                               selectedRegion: self.$selectedRegion,
                                               overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                               xAxis: self.$xAxis)
                        }
                        .ignoresSafeArea()
                    }
                    else {
                        ProgressView()
                            .onReceive(timer) { firedDate in
                                timeElapsed = Int(firedDate.timeIntervalSince(startDate))
                                print("time elapsed \(timeElapsed)")
                                
                                if (self.eventViewModel.events.isEmpty && timeElapsed >= 3) {
                                    self.loadedWithoutEvents = true
                                }
                            }
                    }
                }
                else {
                    LoginView(loginModel: self.loginModel)
                        .ignoresSafeArea()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.light)
        .environment(\.locale, Locale(identifier: "de"))
        .environmentObject(self.locationManager)
        .environmentObject(self.mapEventViewModel)
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
        .onChange(of: self.eventViewModel.events) { newValue in
            self.hasEvents = true
        }
    }
}
