//
//  OrganizerScrollContentView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI
import MapKit

struct OrganizerScrollContentView: View {
    
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var filteredOrganizers: [Organizer]
    @Binding var moreOffsetBottom: CGFloat
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
            LazyVGrid(columns: self.columns) {
                ForEach(filteredOrganizers.indices, id: \.self) { index in
                    let organizerBinding = Binding<Organizer>(
                        get: { filteredOrganizers[index] }, // Get the organizer at the current index
                        set: { newOrganizer in
                            filteredOrganizers[index] = newOrganizer // Update the organizer in the array
                        }
                    )
                    NavigationLink(
                        destination:
                            OrganizerDetailView(
                                overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                organizer: organizerBinding,
                                selectedEvent: self.$selectedEvent,
                                selectedRegion: self.$selectedRegion)
                            .ignoresSafeArea(.container, edges: .top),
                        label: {
                            VStack(alignment: .center) {
                                Image(uiImage: filteredOrganizers[index].image ?? UIImage(named: "EventImage")!)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                Text(filteredOrganizers[index].name)
                                    .foregroundColor(.black)
                                    .bold()
                                    .lineLimit(1)
                                Text(filteredOrganizers[index].city)
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 5)
                            .readHeight {
                                self.moreOffsetBottom = $0
                            }
                            //                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        })
                }
            }
        .frame(maxWidth: .infinity)
    }
}

