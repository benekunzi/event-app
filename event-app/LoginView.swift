//
//  LoginView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 08.06.23.
//

import Foundation
import SwiftUI

struct LoginView: View {
    
    @StateObject var loginModel: LoginModel
    @State var email = ""
    @State var password = ""
    
    let size = UIScreen.main.bounds.size
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("", selection: self.$loginModel.loginTab) {
                Text("Log In")
                    .tag(true)
                Text("Create Account")
                    .tag(false)
            }.pickerStyle(SegmentedPickerStyle())
                .padding()
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .frame(width: self.size.width / 1.4, height: self.size.height / 18.93, alignment: .center)
//                .frame(width: 280, height: 45, alignment: .center)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .frame(width: self.size.width / 1.4, height: self.size.height / 18.93, alignment: .center)
//                .frame(width: 280, height: 45, alignment: .center)
            Spacer()
            Button(action: {
                if self.loginModel.loginTab {
                    self.loginModel.loginUser(email: self.email, password: self.password)
                } else {
                    self.loginModel.createUser(email: self.email, password: self.password)
                }
            }, label: {
                Text(self.loginModel.loginTab ? "Log In" : "Create Account")
                    .foregroundColor(.white)
            })
            .frame(width: self.size.width / 1.4, height: self.size.height / 18.93, alignment: .center)
//            .frame(width: 280, height: 45, alignment: .center)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding(.vertical, 30)
        .padding(.top, 10)
    }
}
