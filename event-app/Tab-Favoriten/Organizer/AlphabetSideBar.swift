//
//  AlphabetSideBar.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI

struct AlphabetSidebar: View {
    @Binding var scrollToLetter: String?
    @State var lastLetter = ""
    let alphabet: [String]
    
    @GestureState private var dragLocation: CGPoint = .zero
    
    var body: some View {
        VStack {
            Spacer()
            ForEach(alphabet, id: \.self) { letter in
                Text(letter)
                .font(.caption)
                .foregroundColor(Color("Dark Purple"))
                .padding(.horizontal, 5)
                .frame(height: 10)
                .background(dragObserver(title: letter))
            }
            Spacer()
        }
        .padding(.vertical, 5)
        .background(Color("Smoke White"))
        .cornerRadius(8)
        .gesture(
          DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .updating($dragLocation) { value, state, _ in
                state = value.location
            }
        )
        .onChange(of: self.scrollToLetter) { letter in
            if let letter = letter {
                if self.lastLetter != letter {
                    self.lastLetter = letter
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }
            }
        }
    }
    
    func dragObserver(title: String) -> some View {
      GeometryReader { geometry in
        dragObserver(geometry: geometry, title: title)
      }
    }

    func dragObserver(geometry: GeometryProxy, title: String) -> some View {
      if geometry.frame(in: .global).contains(dragLocation) {
        DispatchQueue.main.async {
            self.scrollToLetter = title
        }
      }
      return Rectangle().fill(Color.clear)
    }
}
