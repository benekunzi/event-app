//
//  EventViewModel.swift
//  event-app
//
//  Created by Benedict Kunzmann on 04.04.23.
//

import Foundation
import FirebaseDatabase
import FirebaseCore
import CoreLocation
import FirebaseStorage
import UIKit

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    init() {
            fetchEvents {}
        }

    func fetchEvents(completion: @escaping () -> Void) {
        let ref = Database.database().reference()
        let dispatchGroup = DispatchGroup()
        
        func downloadImage(for event: Event, imageName: String, completion: @escaping (UIImage?) -> Void) {
            let storage = Storage.storage(url:"gs://event-app-382418.appspot.com")
            let storageRef = storage.reference()
            let imageRef = storageRef.child("images/\(imageName)_image.jpg")

            imageRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                    completion(nil)
                } else {
                    if let data = data {
                        event.image = UIImage(data: data)
                        completion(event.image)
                    } else {
                        completion(nil)
                    }
                }
            }
        }

        ref.observe(.value, with: { snapshot in
            guard let eventDict = snapshot.value as? [String: [String: Any]] else { return }

            for dateKey in eventDict.keys {
                guard let dayEvents = eventDict[dateKey] as? [String: [String: Any]] else { continue }

                for event in dayEvents.values {
                    guard let coordinates = event["coordinates"] as? [Double],
                          let dateStr = event["date"] as? String,
                          let description = event["description"] as? String,
                          let eventName = event["event name"] as? String,
                          let location = event["location"] as? String,
                          let timeWindow = event["time window"] as? String,
                          let latitude = coordinates.first,
                          let longitude = coordinates.last else { continue }
                    
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    guard let date = dateFormatter.date(from: dateStr) else { continue }
                    
                    let newEvent = Event(title: eventName, coordinate: coordinate, eventDescription: description, date: date, location: location, timeWindow: timeWindow)
                    let imageName = eventName // Replace this with the appropriate value
                    
                    dispatchGroup.enter() // Enter the DispatchGroup
                    
                    downloadImage(for: newEvent, imageName: imageName) { image in
                        if let image = image {
                            newEvent.image = image
                        }
                        dispatchGroup.leave() // Leave the DispatchGroup
                    }
                    self.events.append(newEvent)
                }
            }
        })
        
        dispatchGroup.notify(queue: .main) {
            // This block will execute when all images have been loaded
            // Update the annotations on the map
            completion()
            print("completed")
        }
    }
}

