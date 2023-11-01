//
//  TapbarView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 05.06.23.
//

import Foundation
import SwiftUI

enum Tab: String, CaseIterable {
    case house
    case bookmark
//    case book
    case heart
    case person
}

struct TapbarView: View {
    
    @Binding var selectedTab: Tab
    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }
    private let size = UIScreen.main.bounds.size
    
    var body: some View {
        VStack(spacing: 0){
            Divider()
                .foregroundColor(.gray)
            
            HStack(alignment: .top) {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                        .font(.system(size: 20))
                        .onTapGesture {
                            self.selectedTab = tab
                        }
                    Spacer()
                }
            }
            .padding(.top)
            Spacer()
        }
        .frame(maxWidth: .infinity)
//        .padding(.bottom, 20)
//        .frame(height: 80)
        .frame(height: self.size.height / 10.65)
        .background(Color.white)
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
