//
//  draggableSheet.swift
//  event-app
//
//  Created by Benedict Kunzmann on 08.04.23.
//

import Foundation
import SwiftUI

struct DraggableSheet<Content: View>: View {
    @Binding var currentOffsetY: CGFloat
    @Binding var endingOffsetY: CGFloat
    @Binding var openSheet: Bool
    @Binding var startingOffsetY: CGFloat
    let topOffset: CGFloat
    
    let cremeWhite = Color(red: 250/255, green: 250/255, blue: 240/255)
    
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Handle()
                    .gesture(
                        DragGesture()
                        .onChanged({ value in
                            withAnimation(.spring()) {
                                self.currentOffsetY = value.translation.height
                            }
                        })
                        .onEnded { value in
                            let thresholdYTop = UIScreen.main.bounds.height*0.15
                            let thresholdYBottom = UIScreen.main.bounds.height*0.1
                            let thresholdYBottomClosing = UIScreen.main.bounds.height*0.5
                            
//                            print(value.translation.height, thresholdYBottom, thresholdYBottomClosing, thresholdYTop, endingOffsetY, currentOffsetY)
                            
                            withAnimation(.spring()) {
                                if currentOffsetY < -thresholdYTop {
                                    endingOffsetY = -startingOffsetY + topOffset
                                }
                                else if self.endingOffsetY == 0.0 && currentOffsetY > thresholdYBottom {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        endingOffsetY = 0.0
                                        startingOffsetY = UIScreen.main.bounds.height * 0.66
                                        self.openSheet = false
                                    }
                                }
                                else if self.endingOffsetY != 0 && self.currentOffsetY > thresholdYBottom && self.currentOffsetY < thresholdYBottomClosing {
                                    endingOffsetY = 0
                                }
                                else if self.endingOffsetY != 0 && self.currentOffsetY > thresholdYBottom && self.currentOffsetY > thresholdYBottomClosing {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        self.openSheet = false
                                        endingOffsetY = 0.0
                                        startingOffsetY = UIScreen.main.bounds.height * 0.66
                                    }
                                }
                                currentOffsetY = 0
                            }
                        }
                    )
                content()
            }
            .frame(height: geometry.size.height, alignment: .top)
            .background(cremeWhite)
            .cornerRadius(10)
            .shadow(radius: 5)
            .offset(y: self.startingOffsetY)
            .offset(y: self.currentOffsetY)
            .offset(y: self.endingOffsetY)
        }
    }
}

struct Handle: View {
    
    let size = UIScreen.main.bounds
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 2.5)
//                .frame(width: 50, height: 5)
                .frame(width: self.size.width / 7.86, height: self.size.height / 170.4)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity)
    }
}
