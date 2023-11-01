//
//  OrganizerView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 11.08.23.
//

import Foundation
import SwiftUI

struct OrganizerView: View {

    @State var searchText: String = ""
    @State var overlayContentHeight: CGFloat = 0.0

    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    let cyan: Color = Color("cyan")
    let cblue: Color = Color("cblue")
    let size: CGSize = UIScreen.main.bounds.size
    
    private var filteredOrganizer: [Organizer] {
        if searchText.isEmpty {
            return self.eventViewModel.organizer
        } else {
            return self.eventViewModel.organizer.filter { event in
                return event.name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    @EnvironmentObject var eventViewModel: EventViewModel

    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let size = $0.size
            
            NavigationView {
                ZStack(alignment: .top) {
                    
                    ScrollView(.vertical) {
                        
                        Spacer(minLength: self.overlayContentHeight)
                        
                        LazyVGrid(columns: self.columns) {
                            ForEach(self.filteredOrganizer) { organizer in
                                NavigationLink(
                                    destination:
                                        OrganizerDetailView(organizer: organizer, safeArea: safeArea, size: size)
                                        .ignoresSafeArea(.container, edges: .top),
                                    label: {
                                        VStack {
                                            Image(uiImage: organizer.image ?? UIImage(named: "noimage")!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                            Text(organizer.name)
                                                .foregroundColor(.black)
                                                .bold()
                                        }
                                        .padding()
                                    })
                            }
                        }
                        .padding(.horizontal)
                    }
                    .background(
                        ZStack{
                            
                            LinearGradient(
                                colors: [self.cyan.opacity(0.7), self.cblue.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottomTrailing)
                            
                            Circle()
                                .frame(width: self.size.width / 1.5)
                                .foregroundColor(Color.red.opacity(0.5))
                                .blur(radius: 10)
                                .offset(x: -100, y: 150)
                        })
        
                    SearchBarView(searchText: self.$searchText, overlayContentHeight: self.$overlayContentHeight)
                }
                .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var overlayContentHeight: CGFloat
    var body: some View {
        VStack(spacing: 5) {
            Spacer()
            VStack(spacing: 5) {
                VStack(alignment: .center) {
                    Text("Veranstalter:innen")
                        .font(.title3)
                        .bold()
                        .padding(.top)
                    }
                HStack {
                    HStack {
                        TextField("Suche nach Veranstalter:innen", text: self.$searchText)
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
                }
            }
            .readHeight {
                self.overlayContentHeight = $0
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
        .padding(.top, getSafeAreaTop())
        .background(RemoveBackgroundColor())
        .background(BlurView(style: .systemUltraThinMaterialLight))
        .frame(height: UIScreen.main.bounds.size.height / 8)
        .edgesIgnoringSafeArea(.top)
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

