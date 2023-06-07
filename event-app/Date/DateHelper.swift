//
//  DateHelper.swift
//  event-app
//
//  Created by Benedict Kunzmann on 02.04.23.
//

import Foundation

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy"
    return formatter
}()

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: otherDate, toGranularity: .day)
    }
}
