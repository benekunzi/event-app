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
import Firebase

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var organizer: [Organizer] = []
    @Published var participations: [String: [String: Bool]] = [:]
    @Published var loadedEvents: [String] = []
    
    func fetchEvents(date: Date, completion: @escaping () -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: date)
        
        let dispatchGroup = DispatchGroup()
        let ref = Database.database().reference().child("Events/\(selectedDate)")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let eventDict = snapshot.value as? [String: [String: Any]] else { return }
            for singleEvent in eventDict {
                if let event = self.createEvent(singleEvent: singleEvent, date: date) {
                    let imageName = event.title! // Replace this with the appropriate value

                    dispatchGroup.enter() // Enter the DispatchGroup
                    
                    self.downloadImage(childName: "event-images",
                                       imageName: imageName,
                                       date: selectedDate) { image in
                        event.image = image
                        dispatchGroup.leave() // Leave the DispatchGroup
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let todaysDate = dateFormatter.string(from: date)

                    self.events.append(event)
                    self.loadedEvents.append(todaysDate)
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
    
    func fetchOrganizer(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        let ref = Database.database().reference().child("Organizer")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let eventDict = snapshot.value as? [String: [String: Any]] else { return }
            
            for dict in eventDict {
                let uuid = dict.key
                
                guard let email = dict.value["email"] as? String else {
                    print("no email available")
                    continue
                }
                
                guard let name = dict.value["Name"] as? String else {
                    print("no name available")
                    continue
                }
                
                guard let beschreibung = dict.value["Beschreibung"] as? String else {
                    print("keine Beschreibung verfügbar")
                    continue
                }
                
                var events: [String] = []
                
                if let event_hashes = dict.value["events"] as? [String] {
                    for hash in event_hashes {
                        events.append(hash)
                    }
                }
                
                let newOrganizer = Organizer(uuid: uuid, name: name, beschreibung: beschreibung, email: email, events: events)
                
                let imageName = name // Replace this with the appropriate value
                
                dispatchGroup.enter() // Enter the DispatchGroup
                
                self.downloadImage(childName: "organizer-images/\(uuid)",
                                   imageName: imageName, date: nil) { image in
                    newOrganizer.image = image
                    dispatchGroup.leave()
                }
                
                self.organizer.append(newOrganizer)
            }
        })
    }
    
    func updateParticipation(userID: String, hash: String, status: Bool, date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: date)
        
        let ref = Database.database().reference()
        ref.child("Users/\(userID)/Participations/\(selectedDate)").updateChildValues([hash:status])
    }
    
    func getAllParticipatedEvents(userID: String) {
        print("get all participations")
        
        let ref = Database.database().reference().child("Users/\(userID)/Participations")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard let eventDict = snapshot.value as? [String: [String: Bool]] else {
                print("could not decode eventdict")
                return
            }
            self.participations = eventDict
        })
    }
    
    func downloadAllParticipatedEvents() {
        
        let dispatchGroup = DispatchGroup()

        for date in self.participations {
            print(date.key)
            let ref = Database.database().reference().child("Events/\(date.key)")
            
            ref.observeSingleEvent(of: .value, with: { snapshot in
                guard let eventDict = snapshot.value as? [String: [String: Any]] else { return }
                
                for (key, data) in eventDict {
                    let contains = self.events.contains { event in
                        return event.hash_value == key
                    }
                    if !contains {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        if let dateDate = dateFormatter.date(from: date.key) {
                            if let event = self.createEvent(singleEvent: (key, data), date: dateDate) {
                                let imageName = event.title! // Replace this with the appropriate value

                                dispatchGroup.enter() // Enter the DispatchGroup
                                
                                self.downloadImage(childName: "event-images",
                                                   imageName: imageName,
                                                   date: date.key) { image in
                                    event.image = image
                                    dispatchGroup.leave() // Leave the DispatchGroup
                                }
                                
                                self.events.append(event)
                                self.loadedEvents.append(date.key)
                            }
                        }
                        else {
                            print("could not format string date to date object: \(date.key)")
                        }

                    }
                }
            })
        }
    }
    
    private func createEvent(singleEvent: (key: String, value: Dictionary<String, Any>), date: Date) -> Event? {
        let eventHash = singleEvent.key
        
        var latitude: Double = 0.0
        var longitude: Double = 0.0
        
        if let coordinates = singleEvent.value["coordinates"] as? NSDictionary {
            latitude = coordinates["lat"] as? Double ?? 0.0
            longitude = coordinates["lng"] as? Double ?? 0.0
        } else {
            print("Error: Could not extract 'coordinates' from the dictionary.")
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        guard let eventName = singleEvent.value["event name"] as? String else {
            print("Error: Could not extract 'event name' from the dictionary.")
            return nil
        }
        
        guard let timeWindow = singleEvent.value["time window"] as? String else {
            print("Error: Could not extract 'time window' from the dictionary.")
            return nil
        }
        
        guard let organizer = singleEvent.value["organizer"] as? String else {
            print("Error: Could not extract 'organizer' from the dictionary.")
            return nil
        }
        
        guard let eventDescription = singleEvent.value["description"] as? String else {
            print("Error: Could not extract 'description' from the dictionary.")
            return nil
        }
        
        guard let location = singleEvent.value["location"] as? String else {
            print("Error: Could not extract 'location' from the dictionary.")
            return nil
        }
        
        guard let locationName = singleEvent.value["location-name"] as? String else {
            print("Error: Could not extract 'locationName' from the dictionary.")
            return nil
        }
        
        guard let entry_str = singleEvent.value["entry"] as? String else {
            print("Error: Could not extract 'entry' from the dictionary.")
            return nil
        }
        
        let entry: Int = Int(entry_str) ?? -1
        
        return Event(title: eventName, coordinate: coordinate, eventDescription: eventDescription, date: date, location: location, locationName: locationName, timeWindow: timeWindow, hash_value: eventHash, organizer: organizer, entry: entry)
    }
    
    private func downloadImage(childName: String, imageName: String, date: String?, completion: @escaping (UIImage?) -> Void) {
        let storage = Storage.storage(url:"gs://event-app-382418.appspot.com")
        let storageRef = storage.reference()
        
        let image_types = [".jpg", ".jpeg", ".png"]
        
        // Function to recursively attempt downloading images with different extensions
        func downloadImageWithNextType(index: Int) {
            guard index < image_types.count else {
                completion(nil) // All types tried, none successful
                return
            }
            
            let imageType = image_types[index]
            var imageRef = storageRef.child("")
            if let date = date {
                imageRef = storageRef.child("images/\(childName)/\(date)/\(imageName)\(imageType)")
            }
            else {
                imageRef = storageRef.child("images/\(childName)/\(imageName)\(imageType)")
            }

            imageRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
                if let _ = error {
//                    print("Error downloading \(imageType) image: \(error.localizedDescription)")
                    // Try the next image type
                    downloadImageWithNextType(index: index + 1)
                } else if let data = data, let image = UIImage(data: data) {
                    completion(image) // Successful download
                } else {
                    // Try the next image type
                    downloadImageWithNextType(index: index + 1)
                }
            }
        }

        // Start with the first image type
        downloadImageWithNextType(index: 0)
    }
}

