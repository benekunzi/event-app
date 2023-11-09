//
//  PreferencesView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 28.08.23.
//

import Foundation
import SwiftUI

struct PreferencesView: View {
    
    @Binding var overlayContentBottomHeight: CGFloat
    
    @EnvironmentObject var loginModel: LoginModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.loginModel.logoutUser()
                }) {
                    HStack {
                        Text("Logout")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                Spacer()
            }
        }
        .padding(.bottom, self.overlayContentBottomHeight + 10)
        .background(Color.black)
    }
}
