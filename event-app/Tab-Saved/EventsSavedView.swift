//
//  EventsSavedView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 12.06.23.


import Foundation
import SwiftUI
import MapKit

struct SavedEventsView: View {
    
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion
    
    @State var currentDate: Date = Date()
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var loginModel: LoginModel
    
    var body: some View {
        VStack {
            if self.loginModel.authenticationState == .authenticated {
                EventFinderView(overlayContentBottomHeight: self.$overlayContentBottomHeight, selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion)
            } else if self.loginModel.authenticationState == .skipped {
                Spacer()
                Text("Melden Sie sich an um Events zu speichern.")
                    .foregroundColor(Color("Dark Purple"))
                    .font(.title3)
                    .frame(maxWidth: .infinity)
            }
            Spacer()
        }
        .background(Color("Smoke White"))
        .onAppear(perform: {
            self.eventViewModel.downloadAllParticipatedEvents()
        })
    }
}
