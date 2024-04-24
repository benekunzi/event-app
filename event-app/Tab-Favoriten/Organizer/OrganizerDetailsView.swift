//
//  OrganizerDetailsView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 11.08.23.
//

import Foundation
import SwiftUI

struct OrganizerDetailView: View {
    
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var selectedEvent: Event?
    let organizer: Organizer
    var safeArea: EdgeInsets
    var size: CGSize
    
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var imageOffset: CGFloat = 0
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ArtWork()
                
                VStack(alignment: .leading) {
                    Group {
                        Text("Beschreibung")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.vertical, 10)
                        Text(organizer.beschreibung)
                        
                        Divider()
                            .padding()
                    }
                    
                    Group {
                        Text("Events")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom)
                        VStack {
                            ForEach(organizer.events, id: \.self) { hash in
                                if let matchedEvent = self.eventViewModel.events.first(where: { $0.hash_value == hash }) {
                                    HStack {
                                        Image(uiImage: matchedEvent.image ?? UIImage(named: "noimage")!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: self.size.height / 14.2, height: self.size.height / 14.2)
//                                            .frame(width: 60, height: 60) // Adjust size as needed
                                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text(matchedEvent.title ?? "event tile")
                                                .bold()
                                                .font(.system(size: 15))
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onTapGesture {
                                        self.selectedEvent = matchedEvent
                                    }
                                }
                            }
                        }
                    }
                    
                    Group {
                        Divider()
                            .padding()
                        Text("Links")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Group {
                        Divider()
                            .padding()
                        Text("Email")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal)
                .background(Color.black)
            }
            .padding(.bottom)
            .overlay(HeaderView(), alignment: .top)
            
            Spacer(minLength: self.overlayContentBottomHeight + 10.0)
        }
        .gesture(DragGesture(minimumDistance: 20))
        .background(Color.black)
        .navigationBarHidden(true)
        .coordinateSpace(name: "SCROLL")
    }
    
    @ViewBuilder
    func ArtWork() -> some View {
        let height = size.height * 0.45
        GeometryReader {proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named("SCROLL")).minY
            Image(uiImage: organizer.image ?? UIImage(named: "noimage")!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0))
                .clipped()
                .offset(y: -minY)
        }
        .frame(height: height + safeArea.top )
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
                        .foregroundColor(.black)
                        .background(RemoveBackgroundColor())
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(
                            ZStack {
                                Color.clear
                                    .background(BlurView(style: .systemUltraThinMaterialDark))
                                    .cornerRadius(100)
                                    .overlay(Circle()
                                        .stroke(Color.clear, lineWidth: 1))
                                    .clipped()
                            }
                        )
                }
                Spacer()
            }
            .overlay(
                Text(organizer.name)
                .fontWeight(.semibold)
                .offset(y: -titleProgress > 0.75 ? 0 : 45)
                .clipped()
                .animation(.easeInOut(duration: 0.25), value: -titleProgress > 0.75))
//            .overlay(content: {
//                Text(organizer.name)
//                    .fontWeight(.semibold)
//                    .offset(y: -titleProgress > 0.75 ? 0 : 45)
//                    .clipped()
//                    .animation(.easeInOut(duration: 0.25), value: -titleProgress > 0.75)
//            })
            .padding(.top, getSafeAreaTop() + 10)
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
            .background(RemoveBackgroundColor())
            .background(BlurView(style: .systemUltraThinMaterialDark).opacity(-titleProgress > 0.75 ? 1 : 0))
//            .background(Color.white.opacity(-titleProgress > 0.75 ? 1 : 0))
            .animation(.easeInOut(duration: 0.25), value: -titleProgress > 0.75)
            .offset(y: -minY)
        }
//        .frame(height: 35)
        .frame(height: self.size.height / 24.34)
    }
}

