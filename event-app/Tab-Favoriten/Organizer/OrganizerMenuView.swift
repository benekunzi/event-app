//
//  OrganizerMenuView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI

struct OrganizerMenuView: View {
    @Binding var showMenu: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 25) {
                VStack(alignment: .leading) {
                    Text("Stadt")
                        .font(.system(size: 16).bold())
                    HStack {
                        OptionPillShapeView(title: "Magdeburg")
                    }
                }
                
                Divider()
                
                VStack {
                    Text("Kategorie")
                        .font(.system(size: 16).bold())
                    HStack {
                        OptionPillShapeView(title: "Flohmarkt")
                    }
                }
            }
            .padding()
            .background(Color("Smoke White"))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .padding(.horizontal)
            
            Spacer()
        }
        .background(
            BlurView(style: .systemUltraThinMaterial)
                .onTapGesture {
                    self.showMenu = false
                }
        )
    }
}


