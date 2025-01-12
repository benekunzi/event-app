//
//  OrganizerSearchBarView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var overlayContentHeight: CGFloat
    @Binding var showMenu: Bool
    var body: some View {
        VStack(spacing: 5) {
            VStack(spacing: 5) {
                HStack {
                    Text("Veranstaltende")
                        .font(.title3.bold())
                        .foregroundColor(Color("Dark Purple"))
                        .padding(.all)
                    
                    Spacer()
                    
                    Button {
                        self.showMenu = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3.bold())
                            .foregroundColor(Color("Dark Purple"))
                            .padding(.all)
                    }
                }
                
                HStack {
                    HStack {
                        SuperTextField(
                            placeholder: Text("Suche nach Veranstaltenden")
                                .foregroundColor(.white.opacity(0.8)),
                            text: self.$searchText)
                            .disableAutocorrection(true)
                            .padding(.leading, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 5)
                    .background(Color("Dark Purple"))
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18))
                                .foregroundColor(Color.white)
                            Spacer()
                            Button {
                                self.searchText = ""
                                UIApplication.shared.endEditing()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.white)
                            }
                        }
                        .padding(.horizontal, 5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .padding(.top, getSafeAreaTop())
        .readHeight {
            self.overlayContentHeight = $0
        }
        .background(Color("Light Purple"))
        .cornerRadius(25, corners: [.bottomLeft, .bottomRight])
        .edgesIgnoringSafeArea(.top)
    }
}
