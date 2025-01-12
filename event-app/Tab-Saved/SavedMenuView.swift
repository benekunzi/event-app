//
//  MenuView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI

struct SavedMenuView: View {
    @Binding var showMenu: Bool
    @Binding var selectedDate: Date
    @Binding var showCalendar: Bool
    
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "E d.MM.yy"
            return formatter
        }()
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 25) {
                VStack(alignment: .leading) {
                    Text("Datum")
                        .font(.system(size: 16).bold())
                    
                    HStack {
                        Image(systemName: "calendar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .font(.system(size: 16).bold())
                            .frame(height: 20)
                        Text("\(self.selectedDate, formatter: Self.dateFormatter)")
                            .font(.system(size: 16).bold())
                        Spacer()
                    }
                    .foregroundColor(Color("Dark Purple"))
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showCalendar.toggle()
                        }
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading) {
                    Text("Stadt")
                        .font(.system(size: 16).bold())
                    HStack {
                        OptionPillShapeView(title: "Magdeburg")
                    }
                }
                
                Divider()
                
                VStack {
                    Text("Kategorie")
                        .font(.system(size: 16).bold())
                    HStack {
                        OptionPillShapeView(title: "Flohmarkt")
                    }
                }
            }
            .padding()
            .background(Color("Smoke White"))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .padding(.horizontal)
            
            Spacer()
        }
        .background(
            BlurView(style: .systemUltraThinMaterial)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.showMenu.toggle()
                    }
                }
        )
    }
}
