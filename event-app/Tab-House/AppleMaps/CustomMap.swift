//
//  CustomMap.swift
//  event-app
//
//  Created by Benedict Kunzmann on 18.06.24.
//

import Foundation
import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var selectedEvent: Event
    @Binding var filteredEvents: [Event]
    var size: CGSize
    
    @EnvironmentObject var eventViewModel: EventViewModel
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(parent: self)
        coordinator.lastFilteredEvents = filteredEvents
        return coordinator
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        var lastFilteredEvents: [Event] = []

        init(parent: CustomMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let eventAnnotation = annotation as? EventAnnotation else { return nil }
            
            let identifier = "EventAnnotation"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }
            
            if let image = eventAnnotation.image {
                let scaledImage = image.scale(newWidth: 30)
                annotationView?.image = scaledImage.withRoundedCorners(radius: 10)
            } else {
                annotationView?.image = UIImage(named: "EventImage")?.scale(newWidth: 40).withRoundedCorners(radius: 10)
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            if let eventAnnotation = view.annotation as? EventAnnotation {
                parent.selectedEvent = eventAnnotation.event
                parent.region = MKCoordinateRegion(center: eventAnnotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                parent.selectedRegion =  MKCoordinateRegion(center: eventAnnotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.parent.eventViewModel.showEventSheet = true
            }
        }
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(self.region, animated: true)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.pointOfInterestFilter = .excludingAll
        
        updateAnnotations(mapView: mapView)
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if context.coordinator.lastFilteredEvents != filteredEvents {
            updateAnnotations(mapView: uiView)
            context.coordinator.lastFilteredEvents = filteredEvents
        }
    }
    
    private func updateAnnotations(mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        
        let annotations = filteredEvents.map { event -> EventAnnotation in
            let annotation = EventAnnotation(event: event)
            annotation.coordinate = event.coordinate
            annotation.title = event.name
            annotation.image = event.image ?? UIImage(named: "EventImage")
            return annotation
        }
        
        mapView.addAnnotations(annotations)
    }
}

class EventAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var event: Event
    var image: UIImage?
    
    init(event: Event) {
        self.coordinate = event.coordinate
        self.title = event.name
        self.event = event
        self.image = event.image
    }
}

extension UIImage
{
    func scale(newWidth: CGFloat) -> UIImage
    {
        guard self.size.width != newWidth else{return self}
        
        let newSize = CGSize(width: newWidth, height: newWidth)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newWidth))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        return newImage ?? self
    }
    
    func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func circle() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        let result = renderer.image { c in
            let isPortrait = size.height > size.width
            let isLandscape = size.width > size.height
            let breadth = min(size.width, size.height)
            let breadthSize = CGSize(width: breadth, height: breadth)
            let breadthRect = CGRect(origin: .zero, size: breadthSize)
            let origin = CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0,
                                 y: isPortrait  ? floor((size.height - size.width) / 2) : 0)
            let circle = UIBezierPath(ovalIn: breadthRect)
            circle.addClip()
            if let cgImage = self.cgImage?.cropping(to: CGRect(origin: origin, size: breadthSize)) {
                UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation).draw(in: rect)
            }
        }
        return result
    }
}
