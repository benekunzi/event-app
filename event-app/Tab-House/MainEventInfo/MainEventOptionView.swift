//
//  MainEventOptionView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI

struct MainEventOptionView: View {
    
    @Binding var selectedDate: Date
    @Binding var showCalendar: Bool
    
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "E d.MM.yy"
            return formatter
        }()
    
    var body: some View {
        HStack(spacing: 20) {
            OptionPillShapeView(title: Self.dateFormatter.string(from: self.selectedDate))
            .onTapGesture {
                self.showCalendar.toggle()
            }
            
            OptionPillShapeView(title: "Stadt")
            
            OptionPillShapeView(title: "Kategorie")
            
            Spacer()
        }
        .padding(.leading)
    }
}

