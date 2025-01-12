//
//  date-helpers.swift
//  event-app
//
//  Created by Benedict Kunzmann on 12.06.23.
//

import Foundation

func isSameDay(date1: Date, date2: Date) -> Bool {
    let calender = Calendar.current
    return calender.isDate(date1, inSameDayAs: date2)
}

func extraDate(currentDate: Date) -> [String] {
    let calender = Calendar.current
    let month = calender.component(.month, from: currentDate) - 1
    let year = calender.component(.year, from: currentDate)
    
    return ["\(year)", calender.monthSymbols[month]]
}

func getCurrentMonth(currentMonth: Int) -> Date {
    let calender = Calendar.current
    guard let currentMonth = calender.date(byAdding: .month, value: currentMonth, to: Date()) else {
        return Date()
    }
    return currentMonth
}

func extractDate() -> [DateValue] {
    let calendar = Calendar.current
    var allMonths: [DateValue] = []

    for monthOffset in 0..<12 { // Loop through 12 months
        var currentMonth = getCurrentMonth(currentMonth: monthOffset)
        currentMonth = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: currentMonth)!
        let days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first!.date)

        var monthDates = days
        for _ in 1..<firstWeekday {
            monthDates.insert(DateValue(day: -1, date: Date()), at: 0)
        }

        // Remove placeholder days before the start of the month
        if let index = monthDates.firstIndex(where: { $0.day == 1 }) {
            monthDates.removeSubrange(0..<index)
        }

        allMonths.append(contentsOf: monthDates)
    }

    return allMonths
}



struct DateValue: Identifiable {
var id = UUID().uuidString
var day: Int
var date: Date
}

extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}
