import SwiftUI
import MapKit

struct EventInfoSheetView: View {
    @Binding var participations: [String: [String: Bool]]
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var event: Event
    let onRouteButtonPressed: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var loginModel: LoginModel
    
    @State var eventLiked: Bool = false
    @State var participationStatus: Bool = false
    @State var overlayContentTopHeight: CGFloat = 0

    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let size = $0.size
//            NavigationView {
                ZStack(alignment: .top) {
                    Image(uiImage: event.image ?? UIImage(named: "EventImage")!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .readHeight {
                            self.overlayContentTopHeight = $0
                        }
                    
                    EventInfoScrollViewContent(
                        overlayContentTopHeight: self.$overlayContentTopHeight, 
                        overlayContentBottomHeight: self.$overlayContentBottomHeight,
                        participations: self.$participations,
                        selectedRegion: self.$selectedRegion,
                        event: self.$event,
                        eventLiked: self.$eventLiked,
                        participationStatus: self.$participationStatus,
                        safeArea: safeArea,
                        size: size)
                    
                    
                }
//            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            if self.loginModel.authenticationState != .skipped {
                self.participationStatus = self.eventViewModel.participations[transformDate(date: self.event.date)]?[event.hash_value] == true
                self.eventLiked = self.eventViewModel.participations[transformDate(date: self.event.date)]?[event.hash_value] == true
            }
        }
        .onChange(of: self.participations) { newValue in
            self.participationStatus = self.participations[transformDate(date: self.event.date)]?[event.hash_value] == true
            self.eventLiked = self.participations[transformDate(date: self.event.date)]?[event.hash_value] == true
        }
    }
}

struct EventInfoScrollViewContent: View {
    
    @Binding var overlayContentTopHeight: CGFloat
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var participations: [String: [String: Bool]]
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var event: Event
    @Binding var eventLiked: Bool
    @Binding var participationStatus: Bool
    var safeArea: EdgeInsets
    var size: CGSize
    
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var loginModel: LoginModel
    
    @State var startTime: String = ""
    @State var endTime: String = ""
    
    var body: some View {
        ScrollView(.vertical) {
            Spacer(minLength: self.overlayContentTopHeight - 17.5)
                VStack(alignment: .leading, spacing: 0) {
                    Text(event.title ?? "")
                        .font(.headline)
                        .padding(.vertical, 30)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(alignment: .top) {
                            Image(systemName: "map.fill")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .padding(8)
                                .foregroundColor(Color("Dark Purple"))
                                .background(Color("Light Purple"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading) {
                                if let locationName = event.locationName {
                                    Text(locationName)
                                        .font(.subheadline)
                                }
                                Text(event.location)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.gray)
                            }
                            Spacer()
                        }.frame(maxWidth: .infinity)
                        
                        HStack(alignment: .top) {
                            Image(systemName: "calendar")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .padding(8)
                                .foregroundColor(Color("Dark Purple"))
                                .background(Color("Light Purple"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading) {
                                Text(event.date, style: .date)
                                    .font(.subheadline)
                                
                                Text("\(self.startTime) - \(self.endTime)")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.gray)
                                
                            }
                            Spacer()
                        }.frame(maxWidth: .infinity)
                        
                        HStack(alignment: .center) {
                            Image(systemName: "ticket.fill")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .padding(8)
                                .foregroundColor(Color("Dark Purple"))
                                .background(Color("Light Purple"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Text(event.entry > 0 ? "\(event.entry)€" : "Kostenloser Eintritt")
                                .font(.subheadline)
                            
                            Spacer()
                        }.frame(maxWidth: .infinity)
                        
                        HStack(alignment: .center) {
                            Image("language-symbol")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .padding(8)
                                .foregroundColor(Color("Dark Purple"))
                                .background(Color("Light Purple"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            HStack(spacing: 0) {
                                ForEach(self.event.languages.indices, id:\.self) { index in
                                    if index == 0 {
                                        Text(event.languages[index])
                                    } else {
                                        Text(", \(event.languages[index])")
                                    }
                                }
                            }.font(.subheadline)
                            
                            Spacer(minLength: 0)
                        }.frame(maxWidth: .infinity)
                    }
                    .padding(.bottom)
                    
                    ZStack {
                        // Your map view
                        EventAppleMapPreviewView(selectedRegion: self.$selectedRegion, event: [event])
                            .frame(height: 200)
                            .cornerRadius(20)
                            .shadow(color: Color.gray, radius: 5, x: 5, y: 5)
                            .allowsHitTesting(false)
                        Rectangle()
                            .fill(Color.white.opacity(0.001))
                            .onTapGesture {
                                // Call your custom functions here
                                print("Tapped on the map")
                            }
                    }
                    .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Über das Event")
                            .font(.headline.bold())
                        
                        Text(event.eventDescription)
                            .font(.system(size: 14))
                            .lineSpacing(7)
                            .foregroundColor(Color.black.opacity(0.7))
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .background(
//                                Color("LightGrayBlue")
//                                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                                    .shadow(color: Color.gray, radius: 5, x: 5, y: 5)
//                            )
                    }.padding(.vertical)
                    
                    if let organizer = self.eventViewModel.organizer.first(where: { $0.name == event.organizer}) {
                        let organizerBinding = Binding<Organizer>(
                            get: { organizer },
                            set: { _ in }
                        )
                        NavigationLink(
                            destination:
                                OrganizerDetailView(
                                    overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                    organizer: organizerBinding,
                                    selectedEvent: self.$event,
                                    selectedRegion: self.$selectedRegion,
                                    safeArea: safeArea,
                                    size: size)
                                .ignoresSafeArea(.container, edges: .top),
                            label: {
                                HStack {
                                    Image(uiImage: organizer.image ?? UIImage(named: "EventImage")!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(event.organizer)
                                            .foregroundColor(Color("Dark Purple"))
                                        Text("Veranstaler*in")
                                            .font(.callout)
                                            .foregroundColor(Color.gray)
                                    }
                                }
                                .padding(.vertical)
                                .padding(.bottom)
                            })
                    }

                    HStack {
                        Spacer()
                        Button(action: {
                            self.eventLiked.toggle()
                            self.eventViewModel.updateParticipation(
                                userID: self.loginModel.user!.uid,
                                hash: event.hash_value,
                                status: self.eventLiked,
                                date: event.date)
                            self.eventViewModel.getAllParticipatedEvents(
                                userID: self.loginModel.user!.uid)
                        }) {
                            if !self.participationStatus {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.white)
                                    Text("Merken")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color("Purple"))
                                .cornerRadius(25)
                            }
                            else {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.white)
                                    Text("Nicht merken")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color("Purple"))
                                .cornerRadius(25)
                            }
                            
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .onAppear(perform: {
            let (startTime, endTime) = extractStartAndEndTime(timeWindow: event.timeWindow)
            self.startTime = startTime
            self.endTime = endTime
        })
    }
}

struct EventInfoView: View {
    @Binding var participations: [String: [String: Bool]]
    @Binding var selectedRegion: MKCoordinateRegion
    let event: Event
    let onRouteButtonPressed: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var loginModel: LoginModel
    
    @State var eventLiked: Bool = false
    @State var participationStatus: Bool = false

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 20) {
                        Image(uiImage: event.image ?? UIImage(named: "EventImage")!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.width,
                                   height: proxy.size.height * 0.5)
                            .cornerRadius(10)
                            .padding(.bottom, 10)
                            .clipped()
                        Text(event.title ?? "No title found")
                            .font(.system(size: 25))
                            .bold()
                            .padding(.leading)
                        Divider()
                            .padding(.horizontal)
                        HStack{
                            Text(event.location)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                            Divider()
                            Text(event.date, style: .date)
                        }
                        .padding(.horizontal)
                        Divider()
                            .padding(.horizontal)
                        TimeWindowView(timeWindow: self.event.timeWindow)
                        Divider()
                            .padding(.horizontal)
                        
                        ZStack {
                            // Your map view
                            EventAppleMapPreviewView(selectedRegion: self.$selectedRegion, event: [self.event])
//                            EventMapPreviewView(singleEvent: self.event)
                            .frame(height: 200)
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .allowsHitTesting(false) // Disable hit testing for the map
                            
                            // Overlay a transparent view to capture taps
                            Rectangle()
                                .fill(Color.white.opacity(0.001))
                                .onTapGesture {
                                    // Call your custom functions here
                                    print("Tapped on the map")
                                }
                        }
                        Divider()
                            .padding(.horizontal)
                        Text(event.eventDescription)
                            .padding(.horizontal)

                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            self.eventLiked.toggle()
                            self.eventViewModel.updateParticipation(
                                userID: self.loginModel.user!.uid,
                                hash: self.event.hash_value,
                                status: self.eventLiked,
                                date: self.event.date)
                            self.eventViewModel.getAllParticipatedEvents(
                                userID: self.loginModel.user!.uid)
                        }) {
                            if !self.participationStatus {
                                HStack {
                                    Image(systemName: "star")
                                        .foregroundColor(.white)
                                    Text("anmelden")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                            else {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.white)
                                    Text("abmelden")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                            
                        }
                        Spacer()
                    }
                    .padding(.bottom)
                }
            }
            .frame(width: proxy.size.width)
        }
        .onAppear {
            self.participationStatus = self.eventViewModel.participations[transformDate(date: self.event.date)]?[event.hash_value] == true
            self.eventLiked = self.eventViewModel.participations[transformDate(date: self.event.date)]?[event.hash_value] == true
        }
        .onChange(of: self.participations) { newValue in
            self.participationStatus = self.participations[transformDate(date: self.event.date)]?[event.hash_value] == true
            self.eventLiked = self.participations[transformDate(date: self.event.date)]?[event.hash_value] == true
        }
    }
}

struct TimeWindowView: View {
    
    var timeWindow: String
    
    var body: some View {
        
        let (startTime, endTime) = extractStartAndEndTime(timeWindow: timeWindow)
        
        HStack(spacing: 20) {
            Text(startTime)
                .padding(5)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(5)
                .foregroundColor(.black)


            Text(endTime)
                .padding(5)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(5)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(.leading)
    }
}

func extractStartAndEndTime(timeWindow: String) -> (String, String) {
    let timeComponents = timeWindow.components(separatedBy: " - ")
    guard timeComponents.count == 2 else {
        return ("Invalid time format, Number of elemenst is not 2", "Invalid time format, Number of elemenst is not 2")
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    guard let startDate = dateFormatter.date(from: timeComponents[0]) else {
        return ("invalid time", "invalid time")
    }
    
    guard let endDate = dateFormatter.date(from: timeComponents[1]) else {
        return ("invalid time", "invalid time")
    }
    
    dateFormatter.dateFormat = "HH:mm"
    let startTime = dateFormatter.string(from: startDate)
    let endTime = dateFormatter.string(from: endDate)

    return (startTime, endTime)
}
