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
    @Binding var showCalendar: Bool
    
    @State private var calendarId: Int = 0
    
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "E d. MMMM yyyy"
            return formatter
        }()
    
    var body: some View {
        ZStack {
            HStack(spacing: 10) {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18))
                        .padding(.vertical, 10)
                        .padding(.leading, 8)
                })

                Button(action: {
                    withAnimation(.easeInOut) {
                        showCalendar.toggle()
                    }
                }, label: {
                    Text("\(self.selectedDate, formatter: Self.dateFormatter)")
                        .font(.system(size: 18))
                })

                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18))
                        .padding(.vertical, 10)
                        .padding(.trailing, 8)
                })
            }
            .frame(width: 260)
            .background(RemoveBackgroundColor())
            .foregroundColor(Color.black.opacity(0.9))
            .background(
                ZStack {
                    Color.clear
                        .background(BlurView(style: .systemUltraThinMaterialDark))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.black.opacity(0.5), lineWidth: 1))
                    
                })
            .padding(.top, showCalendar ? -300 : 0)
            
            if showCalendar {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .environment(\.calendar, .gregorianWithMondayFirst)
                    .frame(maxWidth: .infinity)
                    .labelsHidden()
                    .background(RemoveBackgroundColor())
                    .background(
                        ZStack {
                            Color.clear
                                .background(BlurView(style: .systemUltraThinMaterialDark))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black.opacity(0.5), lineWidth: 1))
                            
                        })
                    .cornerRadius(12)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .padding(.horizontal, 25)
                    .id(self.calendarId)
                    .onChange(of: selectedDate) { _ in
                        withAnimation(.easeInOut) {
                            showCalendar.toggle()
                            self.calendarId += 1
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
