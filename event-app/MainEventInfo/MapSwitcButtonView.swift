//
//  MapSwitcButtonView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 30.08.23.
//
import SwiftUI

struct MapSwitchButtonView: View {
    
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @State private var showTodaysEvents: Bool = true
    private let size = UIScreen.main.bounds.size
    
    var body: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.mapEventViewModel.showTodaysEvents.toggle()
                }
            } label: {
                Image(systemName: self.mapEventViewModel.showTodaysEvents ? "map.fill" : "list.dash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(RemoveBackgroundColor())
                    .frame(width: self.size.height / 50, height: self.size.height / 50)
                    .foregroundColor(Color.black.opacity(0.9))
                    .padding(10)
                    .background(
                        ZStack {
                            Color.clear
                                .background(BlurView(style: .systemUltraThinMaterialDark))
                                .cornerRadius(100)
                                .overlay(Circle()
                                    .stroke(Color.black.opacity(0.5), lineWidth: 1))
                        }
                    )
            }
        }
        .padding(.horizontal)
        .sync(self.$mapEventViewModel.showTodaysEvents, with: self.$showTodaysEvents)
    }
}

extension View{
    func sync<T:Equatable>(_ published:Binding<T>, with binding:Binding<T>)-> some View{
        self
            .onChange(of: published.wrappedValue) {
                binding.wrappedValue = $0
            }
            .onChange(of: binding.wrappedValue) {
                published.wrappedValue = $0
            }
            .onAppear {
                binding.wrappedValue = published.wrappedValue
            }
    }
}
