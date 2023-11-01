//
//  MapSwitcButtonView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 30.08.23.
//
import SwiftUI

struct MapSwitchButtonView: View {
    
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    
    private let size = UIScreen.main.bounds.size
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.mapEventViewModel.showTodaysEvents.toggle()
                }
            } label: {
                Image(systemName: self.mapEventViewModel.showTodaysEvents ? "map.fill" : "list.dash")
                    .resizable()
                    .frame(width: self.size.height / 47.33, height: self.size.height / 47.33)
                    .aspectRatio(contentMode: .fit)
                    .background(RemoveBackgroundColor())
                    .frame(width: self.size.height / 47.33, height: self.size.height / 47.33)
                    .foregroundColor(.gray)
                    .padding()
                    .background(
                        ZStack {
                            Color.clear
                                .background(BlurView(style: .systemUltraThinMaterialLight))
                                .cornerRadius(100)
                                .overlay(Circle()
                                    .stroke(Color.gray, lineWidth: 1))
                        }
                    )
            }
        }
        .padding(.horizontal)
    }
}

