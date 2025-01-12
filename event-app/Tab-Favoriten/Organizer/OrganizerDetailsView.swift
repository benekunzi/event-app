//
//  OrganizerDetailsView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 11.08.23.
//

import Foundation
import SwiftUI
import MapKit

struct OrganizerDetailView: View {
    
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var organizer: Organizer
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion
    
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var imageOffset: CGFloat = 0
    @State var overlayContentTopHeight: CGFloat = 0
    @State var safeAreaInsets: EdgeInsets = EdgeInsets()
    @State var size: CGSize = CGSize()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                ZStack(alignment: .top) {
                    ArtWork()
                        .readHeight {
                            self.overlayContentTopHeight = $0
                        }
                    
                    VStack(alignment: .leading) {
                        Spacer(minLength: self.overlayContentTopHeight - 25)
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("Beschreibung")
                                    .font(.title3.bold())
                                    .padding(.top, 30)
                                    .padding(.bottom, 10)
                                Text(organizer.beschreibung)
                                    .font(.system(size: 14))
                                    .lineSpacing(7)
                                    .foregroundColor(Color.black.opacity(0.7))
                            }.padding(.bottom)
                            
                            
                            OrganizerEventDetailView(organizer: $organizer,
                                                     selectedEvent: self.$selectedEvent,
                                                     selectedRegion: self.$selectedRegion,
                                                     overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                                     size: size)
                            .padding(.bottom)
                            
                            Group {
                                Text("Folge uns")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer(minLength: self.overlayContentBottomHeight)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        .background(Color("Smoke White"))
                        .cornerRadius(25, corners: [.topLeft, .topRight])
                    }
                    
                    .foregroundColor(Color.black)
                }
                .overlay(HeaderView(), alignment: .top)
            }
            .gesture(DragGesture(minimumDistance: 20))
            .background(
                GeometryReader { geometry in
                    Color("Smoke White")
                        .frame(height: (geometry.size.height / 2))
                        .offset(y: (geometry.size.height / 2))
                }
            )
            .navigationBarHidden(true)
            .coordinateSpace(name: "SCROLL")
            .edgesIgnoringSafeArea([.bottom, .top])
            .onAppear {
                self.updateGeometry(geometry: geometry)
            }
            .onChange(of: geometry.size) { _ in
                self.updateGeometry(geometry: geometry)
            }
            .onChange(of: geometry.safeAreaInsets) { _ in
                self.updateGeometry(geometry: geometry)
            }
        }
    }
    
    @ViewBuilder
    func ArtWork() -> some View {
        let height = size.height * 0.45
        GeometryReader {proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named("SCROLL")).minY
            Image(uiImage: organizer.image ?? UIImage(named: "EventImage")!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0))
                .clipped()
                .offset(y: -minY)
        }
        .frame(height: height + safeAreaInsets.top )
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let height = size.height * 0.45
            let titleProgress = minY / height
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(Color("Dark Purple"))
                        .clipShape(Circle())
                }
                Spacer()
                Text(organizer.name)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Dark Purple"))
                    .offset(y: -titleProgress > 0.75 ? 0 : 45)
                    .clipped()
                    .animation(.spring(), value: -titleProgress > 0.75)
                Spacer()
            }
//            .overlay(content: {
//                Text(organizer.name)
//                    .fontWeight(.semibold)
//                    .offset(y: -titleProgress > 0.75 ? 0 : 45)
//                    .clipped()
//                    .animation(.easeInOut(duration: 0.25), value: -titleProgress > 0.75)
//            })
            .padding(.top, getSafeAreaTop() + 15)
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
            .background(Color("Light Purple").opacity(-titleProgress > 0.75 ? 1 : 0))
//            .background(Color.white.opacity(-titleProgress > 0.75 ? 1 : 0))
            .animation(.easeInOut(duration: 0.25), value: -titleProgress > 0.75)
            .offset(y: -minY)
        }
//        .frame(height: 35)
        .frame(height: self.size.height / 24.34)
    }
    
    private func updateGeometry(geometry: GeometryProxy) {
        self.safeAreaInsets = geometry.safeAreaInsets
        self.size = geometry.size
    }
}

struct OrganizerEventDetailView: View {
    @Binding var organizer: Organizer
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var overlayContentBottomHeight: CGFloat
    var size: CGSize
    
    @EnvironmentObject var eventViewModel: EventViewModel
    
    var body: some View {
        HStack {
            Text("Letze Veranstaltungen")
                .font(.title3.bold())
            Spacer()
            HStack {
                Text("Mehr anzeigen")
                Image(systemName: "chevron.down")
            }
            .font(.callout)
            .foregroundColor(Color("Dark Purple"))
        }
        .padding(.bottom)
        VStack {
            ForEach(self.organizer.loadedEvents, id: \.self) { event in
                NavigationLink(destination: {
                    EventInfoView(overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                  selectedEvent: self.$selectedEvent,
                                  selectedRegion: self.$selectedRegion)
                }, label: {
                    VStack {
                        HStack(alignment: .top) {
                            Image(uiImage: event.image ?? UIImage(named: "EventImage")!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: self.size.height / 8, height: self.size.height / 10)
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            VStack(alignment: .leading, spacing: 15) {
                                Text(event.name)
                                    .font(.system(size: 14).bold())
                                    .lineLimit(2)
                                HStack {
                                    VStack {
                                        Text("Datum")
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                        Text(event.startDate, style: .date)
                                            .font(.system(size: 12))
                                    }
                                    Spacer()
                                    VStack {
                                        Text("Zeitraum")
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
//                                        Text(event.timeWindow)
//                                            .font(.system(size: 12))
                                        
                                    }
                                }
                            }.padding(.vertical)
                        }
                        .frame(height: self.size.height / 10, alignment: .leading)
                        Divider()
                    }.padding(.bottom)
                })
                .simultaneousGesture(TapGesture().onEnded {
                    self.selectedEvent = event
                    self.selectedRegion = MKCoordinateRegion(center: event.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                })
            }
        }
        .onAppear {
            if let events = organizer.events{
                self.eventViewModel.loadOrganizerEvent(organizerEvents: events, hash_value: organizer.uuid)
            }
        }
    }
}

