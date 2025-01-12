//
//  OptionPillShapeView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 22.11.24.
//

import SwiftUI

struct OptionPillShapeView: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .padding(5)
            .padding(.horizontal, 3)
            .font(.footnote.bold())
            .background(Capsule(style: .continuous).fill(Color("Light Purple")))
            .foregroundColor(Color("Purple"))
    }
}
