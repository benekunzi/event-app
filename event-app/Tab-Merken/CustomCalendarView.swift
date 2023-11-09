//
//  CustomCalendarView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 12.06.23.
//

import Foundation
import SwiftUI

struct CustomDatePicker: View {
    @Binding var currentDate: Date
    
    @State var currentMonth: Int = 0
    @State var year: String = ""
    @State var monthName: String = ""
    
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let days: [String] = ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
    
    var string_date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self.mapEventViewModel.selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 0) {
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(self.year)
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(self.monthName)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Button {
                        withAnimation {
                            self.currentMonth -= 1
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    Button {
                        withAnimation {
                            self.currentMonth += 1
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                
                Divider()
            }
            .background(Color.gray.opacity(0.1))
            
            HStack(spacing: 5) {
                ForEach(days, id:\.self) { day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(extractDate()) { value in
                    CardView(value: value, currentDate: self.$currentDate)
                        .background(
                            Capsule()
                                .fill(.red)
                                .padding(.horizontal, 8)
                                .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1 : 0)
                        )
                }
            }
            
            VStack(spacing: 0) {
                Divider()
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(self.eventViewModel.events) { singleEvent in
                            if ( (isSameDay(date1: singleEvent.date, date2: currentDate))
                                 && (self.eventViewModel.participations[self.string_date]?[singleEvent.hash_value] == true) ) {
                                HStack {
                                    Image(uiImage: singleEvent.image ?? UIImage(named: "noimage")!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60) // Adjust size as needed
                                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(singleEvent.title ?? "event tile")
                                            .bold()
                                            .font(.system(size: 15))
                                    }
                                    .padding(.vertical, 10)
                                }
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .foregroundColor(.black)
            }
        }
        .padding(.vertical, 10)
        .onAppear {
            self.year = extraDate(currentDate: currentDate)[0]
            self.monthName = extraDate(currentDate: currentDate)[1]
        }
        .onChange(of: self.currentMonth) { newValue in
            self.currentDate = getCurrentMonth(currentMonth: newValue)
            self.year = extraDate(currentDate: currentDate)[0]
            self.monthName = extraDate(currentDate: currentDate)[1]
            
        }
    }
}

struct CardView: View {
    
    let value: DateValue
    @Binding var currentDate: Date
    
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    
    var string_date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self.mapEventViewModel.selectedDate)
    }
    
    var body: some View {
        VStack {
            if value.day != -1 {
                
                if let singleEvent = self.eventViewModel.events.first(where: { singleEvent in
                    return ( (isSameDay(date1: value.date, date2: singleEvent.date))
                             && (self.eventViewModel.participations[self.string_date]?[singleEvent.hash_value] == true) )
                }) {
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: currentDate, date2: singleEvent.date) ? .white : .black)
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Circle()
                        .fill(isSameDay(date1: currentDate, date2: singleEvent.date) ? .white : .red)
                        .frame(width: 8, height: 8)
                } else {
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
        .frame(height: 40)
        .padding(.all, 4)
        .onTapGesture {
            self.currentDate = value.date
        }
    }
}
