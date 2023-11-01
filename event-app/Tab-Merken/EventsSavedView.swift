//
//  EventsSavedView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 12.06.23.
// https://www.fivestars.blog/articles/safe-area-insets-2/


import Foundation
import SwiftUI

struct SavedEventsView: View {
    
    @State var currentDate: Date = Date()
    @EnvironmentObject var loginModel: LoginModel
    @EnvironmentObject var eventViewModel: EventViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                //            CustomDatePicker(currentDate: self.$currentDate)
                EventFinderView()
            }
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .padding(.top, getSafeAreaTop())
        .onAppear{
            self.eventViewModel.getAllParticipatedEvents(userID: self.loginModel.user!.uid)
        }
    }
}

struct EventFinderView: View {

    @State var selectedDate: Date = Date()
    @State var overlayContentHeight: CGFloat = 0
    @State var searchText: String = ""
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel

    let cyan: Color = Color("cyan")
    let cblue: Color = Color("cblue")
    let size: CGSize = UIScreen.main.bounds.size

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                Spacer(minLength: self.overlayContentHeight + 10.0)
                ScrollViewReader { proxy in
                    EventFinderScrollViewContent(
                        searchText: self.$searchText,
                        selectedDate: self.$selectedDate,
                        size: self.size,
                        scrollViewProxy: proxy)
                }
            }
            .background(
                ZStack{
                    LinearGradient(
                        colors: [self.cyan.opacity(0.7), self.cblue.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottomTrailing)
                    
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(LinearGradient(colors: [Color.purple.opacity(0.5), Color.green.opacity(0.5)], startPoint: .top, endPoint: .leading))
                        .frame(width: self.size.height / 1.7, height: self.size.height / 1.7)
                        .blur(radius: 30)
                        .rotationEffect(.degrees(30))
                        .offset(x: self.size.width / 1.3)
                })
            EventFinderHeaderView(selectedDate: self.$selectedDate,
                                  overlayContentHeight: self.$overlayContentHeight,
                                  searchText: self.$searchText)
        }
    }
}

struct EventFinderScrollViewContent: View {
    @Binding var searchText: String
    @Binding var selectedDate: Date
    let size: CGSize
    let scrollViewProxy: ScrollViewProxy

    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel

    var eventsGroupedByDate: [Date: [Event]] {
        if searchText.isEmpty {
            return Dictionary(grouping: eventViewModel.events, by: { calendar.startOfDay(for: $0.date) })
        } else {
            return Dictionary(grouping: eventViewModel.events.filter { event in
                return event.title?.lowercased().contains(searchText.lowercased()) ?? false
            }, by: { calendar.startOfDay(for: $0.date) })
        }
    }

    let calendar = Calendar.current

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(eventsGroupedByDate.sorted(by: { $0.key < $1.key }), id: \.key) { date, eventsInDate in
                if let firstEvent = eventsInDate.first(where: { event in
                    return eventViewModel.participations[event.hash_value] == true
                }) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(date, style: .date)
                            .foregroundColor(.white)
                            .padding(.vertical, 5)

                        ForEach(eventsInDate) { event in
                            if eventViewModel.participations[event.hash_value] == true {
                                EventRowView(event: event, size: size)
                                    .onTapGesture {
                                        mapEventViewModel.selectedEvent = event
                                    }
                            }
                        }
                    }
                    .id(Int(self.calendar.startOfDay(for: date).timeIntervalSince1970))
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


struct EventRowView: View {
    let event: Event
    let size: CGSize

    var body: some View {
        HStack {
            Image(uiImage: event.image ?? UIImage(named: "noimage")!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width / 6.55, height: size.height / 14.2)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(event.title ?? "Event Title")
                    .bold()
                    .font(.system(size: 15))
                // Add more event information here if needed
            }
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}



//struct EventFinderScrollViewContent: View {
//    @Binding var selectedDate: Date
//    @Binding var searchText: String
//    let size: CGSize
//    let scrollViewProxy: ScrollViewProxy
//
//    @EnvironmentObject var eventViewModel: EventViewModel
//    @EnvironmentObject var mapEventViewModel: MapEventViewModel
//
//    let calendar = Calendar.current
//
//    var filteredEvents: [Event] {
//        if searchText.isEmpty {
//            return eventViewModel.events
//        } else {
//            return eventViewModel.events.filter { event in
//                return event.title?.lowercased().contains(searchText.lowercased()) ?? false
//            }
//        }
//    }
//
//    var body: some View {
//        LazyVStack(alignment: .leading, spacing: 8) {
//            ForEach(extractDate()) { value in
//                if let singleEvent = self.filteredEvents.first(where: { singleEvent in
//                    return ( (isSameDay(date1: value.date, date2: singleEvent.date))
//                             && (self.eventViewModel.participations[singleEvent.hash_value] == true) )
//                }) {
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text(value.date, style: .date)
//                        Divider()
//                    }
//                    .foregroundColor(.gray)
//                    .padding(.vertical, 5)
//                    .id(Int(self.calendar.startOfDay(for: singleEvent.date).timeIntervalSince1970))
//                }
//
//                ForEach(self.filteredEvents) { event in
//                    if ((isSameDay(date1: value.date, date2: event.date)) && (self.eventViewModel.participations[event.hash_value] == true) ) {
//                        HStack {
//                            Image(uiImage: event.image ?? UIImage(named: "noimage")!)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: self.size.width / 6.55,
//                                       height: self.size.height / 14.2)
//                            //                                        .frame(width: 60, height: 60) // Adjust size as needed
//                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                            VStack(alignment: .leading, spacing: 10) {
//                                Text(event.title ?? "event tile")
//                                    .bold()
//                                    .font(.system(size: 15))
//                            }
//                        }
//                        .padding(.vertical, 5)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .onTapGesture {
//                            self.mapEventViewModel.selectedEvent = event
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal)
//            .onAppear {
//                scrollViewProxy.scrollTo(Int(self.calendar.startOfDay(for: selectedDate).timeIntervalSince1970), anchor: .bottom)
//            }
//            .onChange(of: self.selectedDate) { _ in
//                scrollViewProxy.scrollTo(Int(self.calendar.startOfDay(for: selectedDate).timeIntervalSince1970), anchor: .bottom)
//            }
//        }
//    }
//}

struct EventFinderHeaderView: View {
    
    @Binding var selectedDate: Date
    @Binding var overlayContentHeight: CGFloat
    @Binding var searchText: String
    
    @State var showSearchBar: Bool = false
    @State private var calendarId: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                if self.showSearchBar {
                    HStack {
                        HStack {
                            TextField("Suche nach Events", text: self.$searchText)
                                .padding(.leading, 24)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 5)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.gray)
                                Spacer()
                                Button {
                                    self.searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color.gray)
                                }
                            }
                                .padding(.horizontal, 5)
                                
                        )
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.showSearchBar = false
                            }
                            self.searchText = ""
                        } label: {
                            Text("cancel")
                                .padding(.trailing)
                                .padding(.leading, 0)
                        }
                    }
                }
                else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.showSearchBar.toggle()
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                            .foregroundColor(Color.black)
                            .padding(.all)
                    }
                    
                    Spacer()

                    DatePicker("", selection: self.$selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .environment(\.calendar, .gregorianWithMondayFirst)
                        .labelsHidden()
                        .background(Color.clear)
                        .id(self.calendarId)
                        .onChange(of: self.selectedDate, perform: { _ in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.calendarId += 1
                            }
                        })
                        .animation(.easeInOut(duration: 0.2))
                        .preferredColorScheme(.light)
                }
            }
            .readHeight {
                self.overlayContentHeight = $0
            }

            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
            .padding(.top, getSafeAreaTop())
            .padding(.vertical, 5)
            
            Spacer(minLength: 0)
            Divider()
        }
        .background(RemoveBackgroundColor())
        .background(BlurView(style: .systemUltraThinMaterialLight))
        .frame(height: UIScreen.main.bounds.size.height / 9)
        .edgesIgnoringSafeArea(.top)
    }
}

extension View {
  func readHeight(onChange: @escaping (CGFloat) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Spacer()
          .preference(
            key: HeightPreferenceKey.self,
            value: geometryProxy.size.height
          )
      }
    )
    .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
  }
}

private struct HeightPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}


//struct EventFinderView: View {
//
//    @State var currentMonth: Int = 0
//    @State var selectedDate: Date = Date()
//    @EnvironmentObject var eventViewModel: EventViewModel
//    @EnvironmentObject var mapEventViewModel: MapEventViewModel
//
//    let size = UIScreen.main.bounds.size
//
//    var body: some View {
//        ScrollView {
//            LazyVStack(alignment: .leading, spacing: 8) {
//                ForEach(extractDate(currentMonth: self.currentMonth)) { value in
//                    if let singleEvent = self.eventViewModel.events.first(where: { singleEvent in
//                        return ( (isSameDay(date1: value.date, date2: singleEvent.date))
//                                 && (self.eventViewModel.participations[singleEvent.hash_value] == true) )
//                    }) {
//                        VStack(alignment: .leading, spacing: 5) {
//                            Text(value.date, style: .date)
//                            Divider()
//                        }
//                        .foregroundColor(.gray)
//                        .padding(.vertical, 5)
//                    }
//
//                    ForEach(self.eventViewModel.events) { event in
//                        if ((isSameDay(date1: value.date, date2: event.date)) && (self.eventViewModel.participations[event.hash_value] == true) ) {
//                            HStack {
//                                Image(uiImage: event.image ?? UIImage(named: "noimage")!)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: self.size.width / 6.55,
//                                           height: self.size.height / 14.2)
////                                        .frame(width: 60, height: 60) // Adjust size as needed
//                                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                                VStack(alignment: .leading, spacing: 10) {
//                                    Text(event.title ?? "event tile")
//                                        .bold()
//                                        .font(.system(size: 15))
//                                }
//                            }
//                            .padding(.vertical, 5)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .onTapGesture {
//                                self.mapEventViewModel.selectedEvent = event
//                            }
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal)
//        }
//        .safeAreaInset(edge: .top, spacing: 0) {
//            VStack(alignment: .leading, spacing: 5) {
//                HStack {
//                    Button {
//                    } label: {
//                        Image(systemName: "magnifyingglass")
//                            .font(.system(size: 18))
//                    }
//
//                    Spacer()
//
//                    DatePicker("", selection: self.$selectedDate, displayedComponents: [.date])
//                        .datePickerStyle(.compact)
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.all, 5)
//                .padding(.horizontal, 5)
//
//                Divider()
//            }
////            .padding(.bottom)
//
//            .background(RemoveBackgroundColor())
//            .background(.ultraThinMaterial)
//
//        }
//    }
//}


//struct EventFinderView: View {
//
//    @State var currentMonth: Int = 0
//    @State var selectedDate: Date = Date()
//    @EnvironmentObject var eventViewModel: EventViewModel
//    @EnvironmentObject var mapEventViewModel: MapEventViewModel
//
//    let size = UIScreen.main.bounds.size
//
//    var body: some View {
//        VStack(spacing: 0) {
//            VStack(alignment: .leading, spacing: 0) {
//                HStack {
//                    Button {
//                    } label: {
//                        Image(systemName: "magnifyingglass")
//                            .font(.system(size: 18))
//                    }
//
//                    Spacer()
//
//                    DatePicker("", selection: self.$selectedDate, displayedComponents: [.date])
//                        .datePickerStyle(.compact)
//                }
//                .frame(maxWidth: .infinity)
//            }
//            .padding(.bottom)
//            .padding(.horizontal)
//            .background(RemoveBackgroundColor())
//            .background(BlurView(style: .systemUltraThinMaterialLight))
//
//            Divider()
//
//            ScrollView {
//                LazyVStack(alignment: .leading, spacing: 8) {
//                    ForEach(extractDate(currentMonth: self.currentMonth)) { value in
//                        if let singleEvent = self.eventViewModel.events.first(where: { singleEvent in
//                            return ( (isSameDay(date1: value.date, date2: singleEvent.date))
//                                     && (self.eventViewModel.participations[singleEvent.hash_value] == true) )
//                        }) {
//                            VStack(alignment: .leading, spacing: 5) {
//                                Text(value.date, style: .date)
//                                Divider()
//                            }
//                            .foregroundColor(.gray)
//                            .padding(.vertical, 5)
//                        }
//
//                        ForEach(self.eventViewModel.events) { event in
//                            if ((isSameDay(date1: value.date, date2: event.date)) && (self.eventViewModel.participations[event.hash_value] == true) ) {
//                                HStack {
//                                    Image(uiImage: event.image ?? UIImage(named: "noimage")!)
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                        .frame(width: self.size.width / 6.55,
//                                               height: self.size.height / 14.2)
////                                        .frame(width: 60, height: 60) // Adjust size as needed
//                                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                                    VStack(alignment: .leading, spacing: 10) {
//                                        Text(event.title ?? "event tile")
//                                            .bold()
//                                            .font(.system(size: 15))
//                                    }
//                                }
//                                .padding(.vertical, 5)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .onTapGesture {
//                                    self.mapEventViewModel.selectedEvent = event
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//    }
//}

//
//struct EventFinderScrollViewContent: View {
//    @Binding var currentMonth: Int
//    @Binding var currentDate: Date
//    @Binding var searchText: String
//    let size: CGSize
//    let scrollViewProxy: ScrollViewProxy
//
//    @EnvironmentObject var eventViewModel: EventViewModel
//    @EnvironmentObject var mapEventViewModel: MapEventViewModel
//
//    var filteredEvents: [Event] {
//        if searchText.isEmpty {
//            return eventViewModel.events
//        } else {
//            return eventViewModel.events.filter { event in
//                return event.title?.lowercased().contains(searchText.lowercased()) ?? false
//            }
//        }
//    }
//
//    var body: some View {
//        LazyVStack(alignment: .leading, spacing: 8) {
//            ForEach(extractDate(currentMonth: self.currentMonth)) { value in
//                if let _ = self.filteredEvents.first(where: { singleEvent in
//                    return ( (isSameDay(date1: value.date, date2: singleEvent.date))
//                             && (self.eventViewModel.participations[singleEvent.hash_value] == true) )
//                }) {
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text(value.date, style: .date)
//                        Divider()
//                    }
//                    .foregroundColor(.gray)
//                    .padding(.vertical, 5)
//                }
//
//                ForEach(self.filteredEvents) { event in
//                    if ((isSameDay(date1: value.date, date2: event.date)) && (self.eventViewModel.participations[event.hash_value] == true) ) {
//                        HStack {
//                            Image(uiImage: event.image ?? UIImage(named: "noimage")!)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: self.size.width / 6.55,
//                                       height: self.size.height / 14.2)
//                            //                                        .frame(width: 60, height: 60) // Adjust size as needed
//                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                            VStack(alignment: .leading, spacing: 10) {
//                                Text(event.title ?? "event tile")
//                                    .bold()
//                                    .font(.system(size: 15))
//                            }
//                        }
//                        .padding(.vertical, 5)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .onTapGesture {
//                            self.mapEventViewModel.selectedEvent = event
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal)
//        }
//    }
//}
