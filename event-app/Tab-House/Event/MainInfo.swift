//
//  MainInfo.swift
//  event-app
//
//  Created by Benedict Kunzmann on 24.04.23.
//

import Foundation
import SwiftUI
import MapKit

struct MainInfoView: View {
    @Binding var overlayContentTopHeight: CGFloat
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var selectedDate: Date
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion
    
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    
    private let size = UIScreen.main.bounds.size
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ScrollView {
                        Spacer(minLength: self.overlayContentTopHeight)
                        LazyVStack(alignment: .leading, spacing: 25) {
                            ForEach(eventViewModel.events.filter { $0.startDate.isSameDay(as: self.selectedDate) }){ event in
                                NavigationLink {
                                    EventInfoView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion)
                                } label: {
                                    PanelView(event: event, size: self.size)
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    self.selectedEvent = event
                                    self.selectedRegion = MKCoordinateRegion(center: event.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                                })
                            }
                        }
                        Spacer(minLength: self.overlayContentBottomHeight)
                    }
                }
            }
        }
    }
}

struct PanelView: View {
    
    var event: Event
    let size: CGSize
    
    @State var startTime: String = ""
    @State var endTime: String = ""
    
    let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: (event.image ?? UIImage(named: "EventImage"))!) // Replace with your image name
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(20, corners: [.topLeft, .topRight])
                
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.headline)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.vertical, 5)
                    .padding(.top, 5)
                    
                VStack(alignment: .leading, spacing: 2) {
                    if let locationName = event.locationName {
                        Text("\(locationName) · \(self.startTime) - \(self.endTime)")
                            .foregroundColor(.gray)
                    }
                    else {
                        Text("\(event.street) · \(self.startTime) - \(self.endTime)")
                            .foregroundColor(.gray)
                    }
                    
                    Text("Eintritt: \(event.entry)€")
                        .foregroundColor(.gray)
                }
                .font(.system(size: 12))
                .padding(.bottom)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .onAppear(perform: {
            dateFormatter.dateFormat = "HH-mm"
            self.startTime = dateFormatter.string(from: event.startDate)
            self.endTime = dateFormatter.string(from: event.endDate)
        })
        .onChange(of: self.event) { newValue in
            dateFormatter.dateFormat = "HH-mm"
            self.startTime = dateFormatter.string(from: newValue.startDate)
            self.endTime = dateFormatter.string(from: newValue.endDate)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
