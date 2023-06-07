//
//  DateSelecotr.swift
//  event-app
//
//  Created by Benedict Kunzmann on 02.04.23.
//

import Foundation
import SwiftUI

struct DateSelectorView: View {
    @Binding var selectedDate: Date
    @Namespace private var animation
    
    @State private var showCalendar = false
    
    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }, label: {
                    Image(systemName: "chevron.left")
                })

                Button(action: {
                    withAnimation(.easeInOut) {
                        showCalendar.toggle()
                    }
                }, label: {
                    Text(selectedDate, style: .date)
                })

                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }, label: {
                    Image(systemName: "chevron.right")
                })
            }
            .foregroundColor(Color.black.opacity(0.9))
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .padding(.top, showCalendar ? 50 : 0)
            .background(.white)
            .cornerRadius(15)
            .shadow(color: .gray, radius: 5, x: 0, y: 5)
            
            if showCalendar {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .environment(\.calendar, .gregorianWithMondayFirst)
                    .frame(width: UIScreen.main.bounds.width - 50, height: 300)
                    .labelsHidden()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .padding(.horizontal, 25)
                    .onChange(of: selectedDate) { newValue in
                        print(newValue)
                        withAnimation(.easeInOut) {
                            showCalendar.toggle()
                        }
                    }
            }
        }
    }
}

extension Calendar {
    static var gregorianWithMondayFirst: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // 1 is Sunday, 2 is Monday, and so on
        return calendar
    }
}

struct CalendarKey: EnvironmentKey {
    static let defaultValue: Calendar = .current
}

extension EnvironmentValues {
    var calendar: Calendar {
        get { self[CalendarKey.self] }
        set { self[CalendarKey.self] = newValue }
    }
}
