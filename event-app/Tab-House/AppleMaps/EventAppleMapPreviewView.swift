//
//  EventAppleMapPreviewView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 01.11.23.
//

import SwiftUI
import MapKit

struct EventAppleMapPreviewView: View {
    let event: [Event]
    
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    
    let size: CGSize = UIScreen.main.bounds.size
    
    var body: some View {
        Map(coordinateRegion: self.$mapEventViewModel.region, annotationItems: self.event) { event in
            MapAnnotation(coordinate: event.coordinate) {
                Image(uiImage: event.image ?? UIImage(named: "noimage")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: self.size.width / 14, height: self.size.width / 14)
                    .clipShape(Circle())
            }
        }
        
    }
}
