//
//  EventRowView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI

struct EventRowView: View {
    @Binding var event: Event
    let size: CGSize
    
    @State var startTime: String = ""
    @State var endTime: String = ""
    
    @EnvironmentObject var eventViewModel: EventViewModel

    var body: some View {
        HStack(alignment: .top) {
            Image(uiImage: self.event.image ?? UIImage(named: "EventImage")!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(self.event.name)
                    .bold()
                    .foregroundColor(.black)
                    .font(.system(size: 15))
                    .lineLimit(1)
                
                Text("\(self.startTime) - \(self.endTime)")
                    .font(.callout)
                    .foregroundColor(.gray)
                if let organizer = self.eventViewModel.organizer.first(where: { $0.name == event.organizer}) {
                    Text(organizer.city)
                        .font(.callout)
                        .foregroundColor(.gray)
            }
                // Add more event information here if needed
            }
        }
//            .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 5)
        .onAppear(perform: {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            self.startTime = formatter.string(from: event.startDate)
            self.endTime = formatter.string(from: event.endDate)
        })
    }
}
