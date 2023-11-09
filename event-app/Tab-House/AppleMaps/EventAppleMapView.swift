//
//  EventAppleMapView.swift
//  event-app
//
//  Created by Benedict Kunzmann on 01.11.23.
//

import SwiftUI
import MapKit

struct EventAppleMapView: View {
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion()
    
    let size: CGSize = UIScreen.main.bounds.size
    var filteredEvents: [Event] {
        return eventViewModel.events.filter { $0.date.isSameDay(as: self.mapEventViewModel.selectedDate) }
    }
    
    var body: some View {
        Map(coordinateRegion: self.$region, showsUserLocation: true, annotationItems: self.filteredEvents) { event in
            MapAnnotation(coordinate: event.coordinate) {
                Image(uiImage: event.image ?? UIImage(named: "noimage")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: self.size.width / 14, height: self.size.width / 14)
                    .clipShape(Circle())
                    .onTapGesture {
                        self.mapEventViewModel.region = MKCoordinateRegion(center: event.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        self.mapEventViewModel.selectedEvent = event
                    }
            }
        }
        .onReceive(self.locationManager.$region) { newValue in
            self.region = MKCoordinateRegion(center: newValue.center, span: newValue.span)
        }
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
