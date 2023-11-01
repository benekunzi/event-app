//
//  EventMapPreviewView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 07.09.23.
//

import Foundation
import SwiftUI
import GoogleMaps

struct EventMapPreviewView: UIViewRepresentable {
    
    let singleEvent: Event
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    
    private let size = UIScreen.main.bounds.size
    let disableTap: Bool = true
    let zoom: Float = 13.0

    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: EventMapPreviewView

        init(_ parent: EventMapPreviewView) {
            self.parent = parent
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            return true
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: self.singleEvent.coordinate.latitude, longitude: self.singleEvent.coordinate.longitude, zoom: self.zoom, bearing: 0.0, viewingAngle: 0.0)

        let mapView = GMSMapView(frame: CGRect.zero, camera: camera)
        mapView.delegate = context.coordinator
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = false
        
        let _ = self.addMarker(on: mapView)
        
        if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        } else {
            print("Unable to find map_style.json")
        }
        
        self.locationManager.mapView = mapView
        
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Update the camera's target position when the centerCoordinate changes
    }
    
    func mapView(_ mapView: GMSMapView, didFinishRenderingMarker marker: GMSMarker) {
        marker.tracksViewChanges = false
        if !self.isMarkerWithinScreen(marker: marker, mapView: mapView) {
            let camera = GMSCameraPosition(target: marker.position, zoom: self.zoom)
            mapView.animate(to: camera)
        }
    }
    
    func addMarker(on mapView: GMSMapView) -> GMSMarker{
        
        let marker = GMSMarker(position: self.singleEvent.coordinate)
        let targetSize = CGSize(width: self.size.height / 40,
                                height: self.size.height / 40)
        
        if let eventImage = self.singleEvent.image {
            if let resizedAndCompressedImage = resizeAndCompressImage(eventImage, targetSize: targetSize) {
                marker.icon = resizedAndCompressedImage
                marker.userData = self.singleEvent
                marker.map = mapView
                marker.tracksViewChanges = true
            }
        }
        else {
            let noImage = UIImage(named: "noimage")!.withRenderingMode(.alwaysOriginal)
            if let resizedAndCompressedImage = resizeAndCompressImage(noImage, targetSize: targetSize) {
                marker.icon = resizedAndCompressedImage
                marker.userData = self.singleEvent
                marker.map = mapView
                marker.tracksViewChanges = true
            }
        }
        
        return marker
    }
    
    func resizeAndCompressImage(_ originalImage: UIImage, targetSize: CGSize) -> UIImage? {
        // Resize the image using UIGraphicsImageRenderer
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { (context) in
            originalImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        // Create a circular image by masking
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: targetSize))
        
        let circularImage = UIGraphicsImageRenderer(size: targetSize).image { (context) in
            // Set background color to clear
            UIColor.clear.setFill()
            UIRectFill(CGRect(origin: .zero, size: targetSize))
            
            circlePath.addClip()
            resizedImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }

//        if let resizedImageData = circularImage.pngData() {
//            return UIImage(data: resizedImageData)
//        }
//
//        return nil
        
        return circularImage
    }
    
    func isMarkerWithinScreen(marker: GMSMarker, mapView: GMSMapView) -> Bool {
        let region = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: region)
        return bounds.contains(marker.position)
    }

    
//    func resizeAndCompressImage(_ originalImage: UIImage, targetSize: CGSize) -> UIImage? {
//        // Resize the image
//
//        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
//        originalImage.draw(in: CGRect(origin: .zero, size: targetSize))
//        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        // Create a circular image by masking
//        let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: targetSize))
//        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
//
//        // Set background color to clear
//        UIColor.clear.setFill()
//        UIRectFill(CGRect(origin: .zero, size: targetSize))
//
//        circlePath.addClip()
//        resizedImage?.draw(in: CGRect(origin: .zero, size: targetSize))
//        let circularImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        if let resizedImageData = circularImage?.pngData() {
//            return UIImage(data: resizedImageData)
//        }
//
//        return nil
//    }
}
