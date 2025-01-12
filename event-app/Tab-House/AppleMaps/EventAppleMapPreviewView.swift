//
//  EventAppleMapPreviewView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 01.11.23.
//

import SwiftUI
import MapKit

struct EventAppleMapPreviewView: View {
    @Binding var selectedRegion: MKCoordinateRegion
    let event: [Event]
    
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    
    let size: CGSize = UIScreen.main.bounds.size
    
    var body: some View {
        Map(coordinateRegion: self.$selectedRegion, annotationItems: self.event) { event in
            MapAnnotation(coordinate: event.coordinate) {
                Image(uiImage: event.image ?? UIImage(named: "EventImage")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: self.size.width / 18, height: self.size.width / 18)
                    .clipShape(Circle())
            }
        }
        
    }
}
