//
//  event_appApp.swift
//  event-app
//
//  Created by Benedict Kunzmann on 02.04.23.
//

import SwiftUI
import GoogleMaps
import Firebase

let API_KEY = "AIzaSyAXIFnUlTArloAcPJECpKy5NwlNN9GSFWQ"

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      GMSServices.provideAPIKey(API_KEY)
    return true
  }
}

@main
struct event_appApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
