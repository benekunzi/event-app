//
//  EventFinderView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 25.04.24.
//

import Foundation
import MapKit
import SwiftUI

struct EventFinderView: View {
    
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion

    @State var selectedDate: Date = Date()
    @State var overlayContentHeight: CGFloat = 0
    @State var searchText: String = ""
    @State var showCalendar: Bool = false
    @State var showMenu: Bool = false
    @State private var calendarId: Int = 0
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    
    let size: CGSize = UIScreen.main.bounds.size

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                Spacer(minLength: self.overlayContentHeight + 20)
                ScrollViewReader { proxy in
                    EventFinderScrollViewContent(
                        searchText: self.$searchText,
                        selectedDate: self.$selectedDate,
                        selectedEvent: self.$selectedEvent,
                        selectedRegion: self.$selectedRegion, 
                        overlayContentBottomHeight: self.$overlayContentBottomHeight,
                        size: self.size,
                        scrollViewProxy: proxy)
                }
                Spacer(minLength: self.overlayContentBottomHeight)
            }
            .background(
                ZStack{
                    Color("Smoke White")
                }
                    .edgesIgnoringSafeArea(.top))
            
            EventFinderHeaderView(selectedDate: self.$selectedDate,
                                  overlayContentHeight: self.$overlayContentHeight,
                                  searchText: self.$searchText,
                                  showCalendar: self.$showCalendar,
                                  showMenu: self.$showMenu)
            .readHeight {
                overlayContentHeight = $0
            }
            .padding(.top, getSafeAreaTop())
            .edgesIgnoringSafeArea(.top)
            
            if showMenu {
                MenuView(showMenu: self.$showMenu,
                         selectedDate: self.$selectedDate,
                         showCalendar: self.$showCalendar)
            }
            
            if showCalendar {
                VStack{
                    DatePicker(selection: $selectedDate, displayedComponents: .date, label: { EmptyView() })
                        .datePickerStyle(.graphical)
                        .environment(\.calendar, .gregorianWithMondayFirst)
                        .labelsHidden()
                        .padding()
                        .background(Color("Purple"))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .frame(maxHeight: .infinity)
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .padding(.horizontal)
                        .id(self.calendarId)
                        .onChange(of: selectedDate) { _ in
                            withAnimation(.easeInOut) {
                                showCalendar.toggle()
                                self.calendarId += 1
                            }
                        }
                        .background(
                            BlurView(style: .systemUltraThinMaterialLight)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.showCalendar.toggle()
                                    }
                                }
                                .edgesIgnoringSafeArea(.bottom)
                        )
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
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

struct SuperTextField: View {
    
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
    
}
