//
//  EventFinderHeaderView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI

struct EventFinderHeaderView: View {
    
    @Binding var selectedDate: Date
    @Binding var overlayContentHeight: CGFloat
    @Binding var searchText: String
    @Binding var showCalendar: Bool
    @Binding var showMenu: Bool
    
    @State var showSearchBar: Bool = false
    @State private var calendarId: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                if self.showSearchBar {
                    HStack {
                        SuperTextField(
                            placeholder: Text("Suche nach Events").foregroundColor(.white.opacity(0.8)),
                            text: self.$searchText)
                        .padding(.leading, 28)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 5)
                        .background(Color("Dark Purple"))
                        .cornerRadius(6)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 18).bold())
                                    .foregroundColor(Color.white)
                                    .padding(.trailing)
                                Spacer()
                                Button {
                                    self.searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color.white)
                                }
                            }
                                .padding(.horizontal, 5)
                                .background(Color.clear)
                        )
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.showSearchBar = false
                            }
                            self.searchText = ""
                        } label: {
                            Text("Löschen")
                                .font(.system(size: 18).bold())
                                .padding(.trailing)
                                .padding(.leading, 0)
                                .foregroundColor(Color("Dark Purple"))
                        }
                    }
                    .padding(.bottom)
                }
                else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.showMenu.toggle()
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18).bold())
                            .foregroundColor(Color("Dark Purple"))
                            .padding(.all)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.showSearchBar.toggle()
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18).bold())
                            .foregroundColor(Color("Dark Purple"))
                            .padding(.all)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, getSafeAreaTop())
        .padding(.horizontal)
        .background(Color("Light Purple"))
        .cornerRadius(25, corners: [.bottomLeft, .bottomRight])
        .edgesIgnoringSafeArea(.top)
    }
}
