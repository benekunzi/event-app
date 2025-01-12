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
    @State var email: String = ""
    @State var password: String = ""
    @State var loginTab: loginTab = .signIn
    
    let size = UIScreen.main.bounds.size
    
    enum loginTab: String, CaseIterable {
        case signIn
        case signUp
    }
    
    let cornerRadius: CGFloat = 15
    
    var body: some View {
//        NavigationView {
            VStack(alignment: .center, spacing: 40) {
                Image(uiImage: UIImage(named: "EventImage")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                
                VStack(alignment: .center, spacing: 20) {
                    NavigationLink {
                        CreateAccountView(loginModel: self.loginModel)
                    } label: {
                        Text("Account erstellen")
                            .frame(maxWidth: .infinity)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .padding(.horizontal, 50)
                            .background(Color("Dark Purple"))
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                            .frame(maxWidth: .infinity)
                    }
                    NavigationLink {
                        LoginAccountView(loginModel: self.loginModel)
                    } label: {
                        Text("Einloggen")
                            .frame(maxWidth: .infinity)
                            .font(.body)
                            .foregroundColor(Color("Dark Purple"))
                            .padding(.vertical)
                            .padding(.horizontal, 50)
                            .background(Color.white)
                            .clipShape(
                                RoundedRectangle(cornerRadius: cornerRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color("Dark Purple"), lineWidth: 1))
                    }
                }.frame(width: 250)
                
                Button(action: {
                    self.loginModel.authenticationState = .skipped
                }, label: {
                    Text("Überspringen")
                        .font(.callout)
                        .foregroundColor(.gray)
                })
            }
//        }
    }
}

struct LoginAccountView: View {
    @StateObject var loginModel: LoginModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            Spacer()
            
            Image(uiImage: UIImage(named: "EventImage")!) // Replace with your logo image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 100)
                .clipShape(Circle())
                .padding()
            
            VStack(alignment: .center, spacing: 15) {
                
                TextField("E-Mail", text: $email)
                    .padding()
                    .background(Color(.white))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("Dark Purple"), lineWidth: 1))
                    .padding(.horizontal, 20)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Passwort", text: $password)
                    .padding()
                    .background(Color(.white))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("Dark Purple"), lineWidth: 1))
                    .padding(.horizontal, 20)
            }
            
            Button(action: {
                self.loginModel.loginUser(email: self.email, password: self.password)
            }) {
                Text("Einloggen")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Dark Purple"))
                    .cornerRadius(5)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.purple.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }
}

struct CreateAccountView: View {
    
    @StateObject var loginModel: LoginModel
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isAgreed: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            Spacer()
            
            Image(uiImage: UIImage(named: "EventImage")!) // Replace with your logo image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 100)
                .clipShape(Circle())
                .padding()
            
            VStack(alignment: .center, spacing: 15) {
                TextField("Nutzername", text: $username)
                    .padding()
                    .background(Color(.white))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("Dark Purple"), lineWidth: 1))
                    .padding(.horizontal, 20)
                
                TextField("E-Mail", text: $email)
                    .padding()
                    .background(Color(.white))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("Dark Purple"), lineWidth: 1))
                    .padding(.horizontal, 20)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Passwort", text: $password)
                    .padding()
                    .background(Color(.white))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("Dark Purple"), lineWidth: 1))
                    .padding(.horizontal, 20)
                
                SecureField("Passwort wiederholen", text: $confirmPassword)
                    .padding()
                    .background(Color(.white))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("Dark Purple"), lineWidth: 1))
                    .padding(.horizontal, 20)
            }
            
//            Toggle(isOn: $isAgreed) {
//                Text("Ich habe die")
//                    .font(.footnote)
//                + Text(" Datenschutzhinweise")
//                    .foregroundColor(.blue)
//                    .underline()
//                    .font(.footnote)
//                + Text(" und")
//                    .font(.footnote)
//                + Text(" Nutzungsbedingungen")
//                    .foregroundColor(.blue)
//                    .underline()
//                    .font(.footnote)
//                + Text(" gelesen und stimme ihnen zu.")
//                    .font(.footnote)
//            }
//            .padding(.horizontal, 20)
            
            Button(action: {
                self.loginModel.createUser(email: self.email, password: self.password)
            }) {
                Text("REGISTRIEREN")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Dark Purple"))
                    .cornerRadius(5)
                    .padding(.horizontal, 20)
            }
            .disabled(!isAgreed)
            
            Spacer()
        }
        .padding(.horizontal)
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.purple.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }
}
