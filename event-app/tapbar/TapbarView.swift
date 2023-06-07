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
    case person
}

struct TapbarView: View {
    
    @Binding var selectedTab: Tab
    private var fillImage: String {
        selectedTab.rawValue + ".fill"
    }
    
    var body: some View {
        VStack{
            HStack(alignment: .top) {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                        .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                        .font(.system(size: 18))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            .frame(height: 80)
            .background(.white)
            .cornerRadius(10)
        }
    }
}
