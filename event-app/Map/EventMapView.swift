import SwiftUI
import GoogleMaps
import Alamofire

struct EventMapView: UIViewRepresentable {
    
    @EnvironmentObject var routeViewModel: RouteViewModel
    @EnvironmentObject var mapEventViewModel: MapEventViewModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel

    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: EventMapView

        init(_ parent: EventMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            guard let event = marker.userData as? Event else { return false }
            parent.mapEventViewModel.selectedEvent = event
            parent.locationManager.selectedMarker = marker
            self.parent.locationManager.showRouteToEvent(event: event, locationManager: parent.locationManager.locationManager, mapView: mapView)
            
            return false
        }

        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            parent.triggerUpdateAnnotations()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition(latitude: 52.131755, longitude: 11.640564, zoom: 15) // Example coordinates
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
        updateAnnotations(for: mapEventViewModel.selectedDate, on: uiView, completion: {}, shouldUpdateCompletion: {
            DispatchQueue.main.async {
                mapEventViewModel.shouldUpdateAnnotations = true
            }
        })
    }
    
    func updateAnnotations(for date: Date, on mapView: GMSMapView, completion: @escaping () -> Void, shouldUpdateCompletion: @escaping () -> Void) {
        guard mapEventViewModel.shouldUpdateAnnotations else { return }
        
        mapView.clear()
        let filteredEvents = eventViewModel.events.filter { $0.date.isSameDay(as: date) }
        
        for event in filteredEvents {
            let marker = GMSMarker(position: event.coordinate)
            marker.userData = event
            
            if let eventImage = event.image {
                let customAnnotationView = CustomAnnotationView(eventImage: eventImage)
                customAnnotationView.frame = CGRect(x: 0, y: 0, width: 40, height: 60)
                marker.iconView = customAnnotationView
                marker.tracksViewChanges = true
            }
            
            marker.map = locationManager.mapView
        }
        completion()
        shouldUpdateCompletion()
    }
}

extension UIImage {
    func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
    
    func makeCircularImage(size: CGSize, borderWidth: CGFloat) -> UIImage? {
        let newRect = CGRect(origin: CGPoint.zero, size: size).integral
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0)
        UIGraphicsGetCurrentContext()
        let path = UIBezierPath(ovalIn: newRect)
        
        path.addClip()
        draw(in: newRect)
        
        if borderWidth > 0 {
            UIColor.lightGray.setStroke()
            path.lineWidth = borderWidth
            path.stroke()
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

class CustomAnnotationView: UIView {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let triangleView: UIImageView = {
        let triangle = UIImage(systemName: "triangle.fill")
        let imageView = UIImageView(image: triangle)
        imageView.tintColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    init(eventImage: UIImage) {
        super.init(frame: .zero)
        backgroundColor = .clear
        imageView.image = eventImage
        
        addSubview(imageView)
        addSubview(triangleView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            
            triangleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            triangleView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -5),
            triangleView.widthAnchor.constraint(equalToConstant: 10),
            triangleView.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
