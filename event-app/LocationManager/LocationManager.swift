//  LocationManager.swift
//  event-app
//
//  Created by Benedict Kunzmann on 02.04.23.
//

import Foundation
import SwiftUI
import CoreLocation
import Alamofire
import MapKit

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: .init(latitude: 52.120326, longitude: 11.627718),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2))

    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.checkLocationAuthorization()
    }
    
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("your location is restricted")
        case .denied:
            print("you have denied that")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            print("location authorized")
            if let location = locationManager.location {
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                print("did set location")
            }
        @unknown default:
            break
        }
        
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did update location")
        let lastLocation = locations.last!
        
        self.region = MKCoordinateRegion(
            center: lastLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
//        DispatchQueue.global(qos: .userInitiated).async {
//                // Perform heavy tasks or calculations here
//
//                DispatchQueue.main.async {
//                    self.region = MKCoordinateRegion(
//                        center: lastLocation.coordinate,
//                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//                    )
//                }
//            }
    }
}
