import SwiftUI
import MapKit

struct EventInfoView: View {
    @Binding var participations: [String: [String: Bool]]
    @Binding var region: MKCoordinateRegion
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
                        if let image = event.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: proxy.size.width,
                                       height: proxy.size.height * 0.5)
                                .cornerRadius(10)
                                .padding(.bottom, 10)
                                .clipped()
                        }
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
                            EventAppleMapPreviewView(region: self.$region, event: [self.event])
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
                        //                    Button(action: {
                        //                        presentationMode.wrappedValue.dismiss()
                        //                        onRouteButtonPressed()
                        //                    }) {
                        //                        HStack {
                        //                            Image(systemName: "tram.fill")
                        //                                .foregroundColor(.white)
                        //                            Text("Route")
                        //                                .foregroundColor(.white)
                        //                        }
                        //                        .padding()
                        //                        .background(Color.blue)
                        //                        .cornerRadius(8)
                        //                    }
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
        return ("Invalid time format", "Invalid time format")
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"

    let startDate = dateFormatter.date(from: timeComponents[0])
    let endDate = dateFormatter.date(from: timeComponents[1])

    dateFormatter.dateFormat = "HH:mm"

    let startTime = startDate.map { dateFormatter.string(from: $0) } ?? "Invalid time format"
    let endTime = endDate.map { dateFormatter.string(from: $0) } ?? "Invalid time format"

    return (startTime, endTime)
}
