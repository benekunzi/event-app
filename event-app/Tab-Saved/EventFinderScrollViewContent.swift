//
//  EventFinderScrollViewContent.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI
import MapKit

struct EventFinderScrollViewContent: View {
    @Binding var searchText: String
    @Binding var selectedDate: Date
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var overlayContentBottomHeight: CGFloat
    let size: CGSize
    let scrollViewProxy: ScrollViewProxy

    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel

    var eventsGroupedByDate: [Date: [Event]] {
        if searchText.isEmpty {
            return Dictionary(grouping: eventViewModel.events, by: { calendar.startOfDay(for: $0.startDate) })
        } else {
            return Dictionary(grouping: eventViewModel.events.filter { event in
                return event.name.lowercased().contains(searchText.lowercased())
            }, by: { calendar.startOfDay(for: $0.startDate) })
        }
    }

    let calendar = Calendar.current

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(eventsGroupedByDate.sorted(by: { $0.key < $1.key }), id: \.key) { date, eventsInDate in
                if let _ = eventsInDate.first(where: { event in
                    return self.eventViewModel.participations[transformDate(date: date)]?[event.hash_value] == true
                }) {
                    let eventsBinding = Binding<[Event]>(
                        get: { eventsInDate },
                        set: { _ in }
                    )
                    EventFinderScrollViewDetailContent(selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion, overlayContentBottomHeight: self.$overlayContentBottomHeight, date: date, eventsInDate: eventsBinding, size: self.size, calendar: self.calendar)
                }
            }
            .padding(.horizontal)
            .onAppear {
                scrollViewProxy.scrollTo(Int(calendar.startOfDay(for: selectedDate).timeIntervalSince1970), anchor: .bottom)
            }
            .onChange(of: self.selectedDate) { _ in
                scrollViewProxy.scrollTo(Int(calendar.startOfDay(for: selectedDate).timeIntervalSince1970), anchor: .bottom)
            }
        }
    }
}

struct EventFinderScrollViewDetailContent: View {
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var overlayContentBottomHeight: CGFloat
    let date: Date
    @Binding var eventsInDate: [Event]
    let size: CGSize
    let calendar: Calendar
    
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(date, style: .date)
                .foregroundColor(.black)
                .font(.headline.bold())
                .padding(.vertical, 5)

            InnerLoop(selectedEvent: self.$selectedEvent, selectedRegion: self.$selectedRegion, eventsInDate: $eventsInDate, overlayContentBottomHeight: self.$overlayContentBottomHeight, size: size, date: date)
            
            Divider()
        }
        .id(Int(self.calendar.startOfDay(for: self.date).timeIntervalSince1970))
        .padding(.vertical, 5)
    }
}

struct InnerLoop: View {
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var eventsInDate: [Event]
    @Binding var overlayContentBottomHeight: CGFloat
    let size: CGSize
    let date: Date
    
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    
    var body: some View {
        ForEach(eventsInDate) { event in
            if (eventViewModel.participations[self.transformDate(date: date)]?[event.hash_value] != nil) == true {
                let eventBinding = Binding<Event>(
                    get: { event },
                    set: { eventInDate in
                        if let index = eventsInDate.firstIndex(of: event) {
                            eventsInDate[index] = eventInDate
                        }
                    }
                )
                NavigationLink {
                    EventInfoView(overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                  selectedEvent: self.$selectedEvent,
                                  selectedRegion: self.$selectedRegion)
                } label: {
                    EventRowView(event: eventBinding, size: size)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    self.selectedEvent = event
                    self.selectedRegion = MKCoordinateRegion(center: event.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                })
            }
        }
    }
    
    private func transformDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
