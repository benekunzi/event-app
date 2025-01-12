//
//  DatePickerView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI

struct DatePickerView: View {
    
    @Binding var selectedDate: Date
    @Binding var showCalendar: Bool
    
    @State private var calendarId: Int = 0
    
    var body: some View {
        VStack {
            Spacer()
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.calendar, .gregorianWithMondayFirst)
                .frame(maxWidth: .infinity)
                .labelsHidden()
                .padding(.horizontal, 20)
                .background(Color("Light Purple"))
                .foregroundColor(Color("Purple"))
                .accentColor(Color("Purple"))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .id(self.calendarId)
                .onChange(of: selectedDate) { _ in
                    self.showCalendar.toggle()
                    self.calendarId += 1
                }
                .padding()
            Spacer()
        }
        .background(BlurView(style: .systemUltraThinMaterial).contentShape(Rectangle()).onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showCalendar.toggle()
            }
        })
        .edgesIgnoringSafeArea(.all)
    }
}

