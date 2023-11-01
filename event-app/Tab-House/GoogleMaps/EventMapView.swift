import SwiftUI
import GoogleMaps

struct EventMapView: UIViewRepresentable {
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    
    private let size = UIScreen.main.bounds.size

    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: EventMapView

        init(_ parent: EventMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            guard let event = marker.userData as? Event else { return false }
            print("tapped on a marker")
            parent.mapEventViewModel.selectedEvent = event
            parent.locationManager.selectedMarker = marker
//            self.parent.locationManager.showRouteToEvent(event: event, locationManager: parent.locationManager.locationManager, mapView: mapView)
            
            return true
        }

        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            parent.triggerUpdateAnnotations()
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            let centerPoint = position.target
            print("Latitude: \(centerPoint.latitude), Longitude: \(centerPoint.longitude)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        var camera: GMSCameraPosition
        let locationManager = self.locationManager.locationManager
        
        if let location = locationManager.location, ((locationManager.authorizationStatus == .authorizedAlways) || (locationManager.authorizationStatus == .authorizedWhenInUse)) {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 15)
        }
        else {
            camera = GMSCameraPosition(latitude: 52.131755, longitude: 11.640564, zoom: 15)
        }
        
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = context.coordinator
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = true
        
        self.locationManager.mapView = mapView
        
        if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        } else {
            print("Unable to find map_style.json")
        }
        return mapView
    }
    
    func mapView(_ mapView: GMSMapView, didFinishRenderingMarker marker: GMSMarker) {
        marker.tracksViewChanges = false
    }

    func triggerUpdateAnnotations() {
        mapEventViewModel.shouldUpdateAnnotations = true
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.clear()
        self.addMarkers(for: self.mapEventViewModel.selectedDate, on: uiView)
    }
    
    func updateAnnotations(for date: Date, on mapView: GMSMapView, completion: @escaping () -> Void, shouldUpdateCompletion: @escaping () -> Void) {
        guard mapEventViewModel.shouldUpdateAnnotations else { return }
        
        completion()
        shouldUpdateCompletion()
    }
    
    func addMarkers(for date: Date, on mapView: GMSMapView) {
        let filteredEvents = eventViewModel.events.filter { $0.date.isSameDay(as: date) }
        for event in filteredEvents {
            let marker = GMSMarker(position: event.coordinate)
            let targetSize = CGSize(width: self.size.height / 40,
                                    height: self.size.height / 40)
            
            if let eventImage = event.image {
                if let resizedAndCompressedImage = resizeAndCompressImage(eventImage, targetSize: targetSize) {
                    marker.icon = resizedAndCompressedImage
                    marker.userData = event
                    marker.map = mapView
                    marker.tracksViewChanges = true
                }
            }
            else {
                let noImage = UIImage(named: "noimage")!.withRenderingMode(.alwaysOriginal)
                if let resizedAndCompressedImage = resizeAndCompressImage(noImage, targetSize: targetSize) {
                    marker.icon = resizedAndCompressedImage
                    marker.userData = event
                    marker.map = mapView
                    marker.tracksViewChanges = true
                }
            }
        }
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
        
        return circularImage
    }
}

//    func resizeAndCompressImage(_ originalImage: UIImage, targetSize: CGSize) -> UIImage? {

// Draw the stroke
//            let strokeColor: UIColor = .red
//            let strokeWidth: CGFloat = 3.0
//            strokeColor.setStroke()
//            circlePath.lineWidth = strokeWidth
//            circlePath.stroke()
//
//        // Resize the image
//        UIGraphicsBeginImageContextWithOptions(targetSize, false, 5.0)
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
