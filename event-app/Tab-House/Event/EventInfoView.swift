//
//  EventInfoView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 11.07.24.
//

import Foundation
import SwiftUI
import MapKit

struct EventInfoView: View {
    
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion
    
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var imageOffset: CGFloat = 0
    @State var overlayContentTopHeight: CGFloat = 0
    @State var eventLiked: Bool = false
    @State var participationStatus: Bool = false
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
                    
                    EventInfoScrollViewContent(
                        overlayContentTopHeight: self.$overlayContentTopHeight,
                        overlayContentBottomHeight: self.$overlayContentBottomHeight,
                        selectedRegion: self.$selectedRegion,
                        event: self.$selectedEvent,
                        eventLiked: self.$eventLiked,
                        participationStatus: self.$participationStatus)
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
            Image(uiImage: self.selectedEvent.image ?? UIImage(named: "EventImage")!)
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
                Text(selectedEvent.name)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Dark Purple"))
                    .offset(y: -titleProgress > 0.75 ? 0 : 45)
                    .clipped()
                    .animation(.spring(), value: -titleProgress > 0.75)
                Spacer()
            }
            .padding(.top, getSafeAreaTop() + 15)
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
            .background(Color("Light Purple").opacity(-titleProgress > 0.75 ? 1 : 0))
            .animation(.easeInOut(duration: 0.25), value: -titleProgress > 0.75)
            .offset(y: -minY)
        }
        .frame(height: self.size.height / 24.34)
    }
    
    private func updateGeometry(geometry: GeometryProxy) {
        self.safeAreaInsets = geometry.safeAreaInsets
        self.size = geometry.size
    }
}
