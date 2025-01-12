//
//  MapSwitcButtonView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 30.08.23.
//
import SwiftUI

struct MapSwitchButtonView: View {
    @Binding var showTodaysEvents: Bool
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    private let size = UIScreen.main.bounds.size
    
    var body: some View {
        HStack {
            Button {
                withAnimation(.spring(duration: 0.75)) {
                    self.showTodaysEvents.toggle()
                }
            } label: {
                Image(systemName: self.showTodaysEvents ? "map.fill" : "list.dash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .font(.system(size: 10).bold())
                    .frame(height: 18)
                    .padding(8)
                    .foregroundColor(Color("Purple"))
                    .background(
                        Color("Light Purple")
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        )
            }
        }
        .padding(.horizontal)
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
