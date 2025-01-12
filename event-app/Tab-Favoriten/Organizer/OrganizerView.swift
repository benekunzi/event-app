//
//  OrganizerView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 11.08.23.
//

import Foundation
import MapKit
import SwiftUI

struct OrganizerView: View {
    
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var selectedEvent: Event
    @Binding var selectedRegion: MKCoordinateRegion
    
    @State var searchText: String = ""
    @State var overlayContentHeight: CGFloat = 0.0
    @State var moreOffsetBottom: CGFloat = 0.0
    @State var filteredOrganizers: [Organizer] = []
    @State var showMenu: Bool = false
    
    var groupedAlbums: [String: [Organizer]] {
        Dictionary(grouping: filteredOrganizers.map { $0 }, by: { String($0.name.prefix(1)).uppercased() })
    }
    
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
    
    @State private var scrollToLetter: String? = nil
    
    let size: CGSize = UIScreen.main.bounds.size
    
    @EnvironmentObject var eventViewModel: EventViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    Spacer(minLength: self.overlayContentHeight)
                    
                    ScrollViewReader { proxy in
                        
                        ForEach(alphabet, id: \.self) { letter in
                            if let items = groupedAlbums[letter], !items.isEmpty {
                                VStack(alignment: .leading) {
                                    let eventsBinding = Binding<[Organizer]>(
                                        get: { items },
                                        set: { _ in }
                                    )
                                    Text(letter)
                                        .font(.headline)
                                    OrganizerScrollContentView(overlayContentBottomHeight: self.$overlayContentBottomHeight,
                                                               selectedEvent: self.$selectedEvent,
                                                               selectedRegion: self.$selectedRegion,
                                                               filteredOrganizers: eventsBinding,
                                                               moreOffsetBottom: self.$moreOffsetBottom)
                                    .id(letter)
                                    .onChange(of: self.scrollToLetter) { newLetter in
                                        proxy.scrollTo(newLetter, anchor: .center)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top)
                            }
                        }
                    }
                    Spacer(minLength: self.overlayContentBottomHeight)
                }
                
                Spacer()
                
                AlphabetSidebar(scrollToLetter: self.$scrollToLetter, alphabet: self.alphabet)
            }
            .frame(maxWidth: .infinity)
            .background(
                ZStack{
                    Color("Smoke White")
                }
                    .edgesIgnoringSafeArea(.top))
            
            .edgesIgnoringSafeArea(.bottom)
            
            SearchBarView(searchText: self.$searchText,
                          overlayContentHeight: self.$overlayContentHeight,
                          showMenu: self.$showMenu)
            
            if self.showMenu {
                OrganizerMenuView(showMenu: self.$showMenu)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: self.showMenu)
        .navigationBarHidden(true)
        .onChange(of: searchText) { newSearchText in
            if newSearchText.isEmpty {
                filteredOrganizers = eventViewModel.organizer
            } else {
                filteredOrganizers = eventViewModel.organizer.filter { organizer in
                    return organizer.name.lowercased().contains(newSearchText.lowercased())
                }
            }
        }
        .onAppear {
            if !searchText.isEmpty { // Check if there's search text
                filteredOrganizers = eventViewModel.organizer.filter { organizer in
                    return organizer.name.lowercased().contains(searchText.lowercased())
                }
            }
            else {
                self.filteredOrganizers = eventViewModel.organizer
            }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func readOffset(onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Spacer()
                    .preference(
                        key: OffsetPreferenceKey.self,
                        value: geometryProxy.frame(in: .global).minY
                    )
            }
        )
        .onPreferenceChange(OffsetPreferenceKey.self, perform: onChange)
    }
}
    
fileprivate struct OffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

