//
//  CustomSheet.swift
//  event-app
//
//  Created by Benedict Kunzmann on 14.08.23.
//

import Foundation
import SwiftUI

struct CustomSheet<Content: View>: View {
    
    var scrollViewContent: () -> Content
    
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @State var offset: CGFloat = 0
    private let maxheight = UIScreen.main.bounds.height / 1.4
    
    let size = UIScreen.main.bounds.size
    let cyan: Color = Color("cyan")
    let cblue: Color = Color("cblue")
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack {
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: self.size.width / 6.55, height: self.size.height / 213)
                        .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
                
                scrollViewContent()
                    .frame(height: self.maxheight)
            }
            .background(
                ZStack {
                    LinearGradient(
                        colors: [self.cyan.opacity(0.9), self.cblue],
                        startPoint: .top,
                        endPoint: .bottomTrailing)
                    Circle()
                        .frame(width: self.size.width / 1.5)
                        .foregroundColor(Color.red.opacity(0.5))
                        .blur(radius: 10)
                        .offset(x: -100, y: 150)
                    
                    Circle()
                        .frame(width: self.size.width / 1.5)
                        .foregroundColor(Color.purple.opacity(0.5))
                        .blur(radius: 10)
                        .offset(x: 200, y: -150)
                }.clipShape(CustomCorner(corners: [.topLeft, .topRight]))
            )
            .offset(y: self.offset)
            .gesture(
                DragGesture()
                    .onChanged(onChanged(value:))
                    .onEnded(onEnded(value:))
            )
            .offset(y: self.mapEventViewModel.showTodaysEvents ? 0 : UIScreen.main.bounds.height)
        }
    }
    
    private func onChanged(value: DragGesture.Value) {
        if value.translation.height > 0 {
            self.offset = value.translation.height
        }
    }
    
    private func onEnded(value: DragGesture.Value) {
        if value.translation.height > 0 {
            withAnimation(.easeIn(duration: 0.2)) {
                let height = self.maxheight
                
                if value.translation.height > height / 5 {
                    self.mapEventViewModel.showTodaysEvents.toggle()
                }
                self.offset = 0
            }
        }
    }
}

struct CustomCorner: Shape {
    
    var corners: UIRectCorner
    let size = UIScreen.main.bounds
    
    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
//                                 cornerRadii: CGSize(width: 35, height: 35))
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: self.size.width / 11.23,
                                                    height: self.size.height / 24.37))
        return Path(path.cgPath)
    }
}
