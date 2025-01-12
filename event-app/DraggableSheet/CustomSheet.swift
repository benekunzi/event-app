//
//  CustomSheet.swift
//  event-app
//
//  Created by Benedict Kunzmann on 14.08.23.
//

import Foundation
import SwiftUI

struct CustomSheet<Content: View>: View {
    
    @Binding var showTodaysEvents: Bool
    
    var scrollViewContent: () -> Content
    
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @State var offset: CGFloat = 0
    @State var overlayContentHeight: CGFloat = 0.0
    private let maxheight = UIScreen.main.bounds.height
    
    let size = UIScreen.main.bounds.size
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 0) {
                scrollViewContent()
                    .frame(height: self.maxheight)
            }
            .readHeight{
                self.overlayContentHeight = $0
            }
            .background(
                Color("Smoke White")
//                Image(uiImage: UIImage(named: "background_2")!)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: size.width, height: self.overlayContentHeight)
//                    .opacity(0.7)
//                    .clipShape(CustomCorner(corners: [.topLeft, .topRight]))
//                    .clipped()
            )
            .offset(y: self.offset)
//            .gesture(
//                DragGesture()
//                    .onChanged(onChanged(value:))
//                    .onEnded(onEnded(value:))
//            )
            .offset(y: self.showTodaysEvents ? 0 : UIScreen.main.bounds.height)
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
                    self.showTodaysEvents.toggle()
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
