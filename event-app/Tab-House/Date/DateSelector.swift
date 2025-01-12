//
//  DateSelecotr.swift
//  event-app
//
//  Created by Benedict Kunzmann on 02.04.23.
//

import Foundation
import SwiftUI

struct DateSelectorMainView: View {
    @Binding var selectedDate: Date
    @Namespace private var animation
    @Binding var showCalendar: Bool
    
    @State private var calendarId: Int = 0
    @GestureState private var dragOffset = CGSize.zero
    @State private var lastDragOffset: CGFloat = 0
    @State private var anchor: UnitPoint = .zero
    
    let scaleFactor: CGFloat = 200
    let maxWidth: CGFloat = 250
    
    static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "E d.MM.yy"
            return formatter
        }()
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 10) {
                HStack {
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(.system(size: 14).bold())
                        .frame(height: 16)
                    Text("\(self.selectedDate, formatter: Self.dateFormatter)")
                        .font(.system(size: 14).bold())
                }
                .foregroundColor(Color("Purple"))
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        showCalendar.toggle()
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(
                Color("Light Purple")
                    .clipShape(Capsule())
                    .scaleEffect(x: scaleEffectX(),
                                 y: 1,
                                 anchor: self.anchor)
            )
            .animation(.easeInOut, value: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onChanged({ value in
                        DispatchQueue.main.async {
                            self.updateAnchor()
                            self.updateLastOffset(width: value.translation.width)
                        }
                    })
                    .onEnded { value in
                        if value.translation.width < -100 {
                            // Swiped left
                            withAnimation(.easeInOut) {
                                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                            }
                        } else if value.translation.width > 100 {
                            // Swiped right
                            withAnimation(.easeInOut) {
                                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                            }
                        }
                    }
            )
        }
    }
    
    func scaleEffectX() -> CGFloat {
        var x : CGFloat = 0
        x = ((1 + abs(dragOffset.width) / scaleFactor) < self.maxWidth/scaleFactor) ?  1 + abs(dragOffset.width) / scaleFactor : self.maxWidth/scaleFactor
        return x
    }
    
    @MainActor
    func updateLastOffset(width: CGFloat) {
        self.lastDragOffset = width
    }
    
    @MainActor
    func updateAnchor() {
        self.anchor = self.dragOffset.width > self.lastDragOffset ? .leading : .trailing
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
