//
//  LoginModel.swift
//  event-app
//
//  Created by Benedict Kunzmann on 08.06.23.
//

import Foundation
import Firebase

class LoginModel: ObservableObject {
    
    enum AuthenticationState: String, CaseIterable {
        case authenticating
        case authenticated
        case unauthenticated
    }
    
    @Published var user: User?
    @Published var authenticationState: AuthenticationState = .unauthenticated
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        self.registerAuthStateHandle()
    }

    func loginUser(email: String, password: String) {
        self.authenticationState = .authenticating
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                    print("Failed due to error:", err)
                    return
            }
            
            print("Successfully logged in with ID: \(result?.user.uid ?? "")")
            return
        }
      }
      
    func createUser(email: String, password: String) {
        self.authenticationState = .authenticating
        Auth.auth().createUser(withEmail: email, password: password, completion: { result, err in
            if let err = err {
                print("Failed due to error:", err)
                return
            }
            
            print("Successfully created account with ID: \(result?.user.uid ?? "")")
            return
        })
      }
    
    func logoutUser() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func registerAuthStateHandle() {
        if self.authStateHandle == nil {
            self.authStateHandle = Auth.auth().addStateDidChangeListener({ auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
            })
        }
    }
}
