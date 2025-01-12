//
//  EventViewModel.swift
//  event-app
//
//  Created by Benedict Kunzmann on 04.04.23.
//

import Foundation
import CoreLocation
import FirebaseStorage
import UIKit
import FirebaseFirestore
import MapKit

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var organizer: [Organizer] = []
    @Published var participations: [String: [String: Bool]] = [:]
    @Published var loadedEvents: [String] = []
    @Published var showEventSheet: Bool = false
    
    private var db = Firestore.firestore()
    private let storageRef = Storage.storage(url: firebase_bucket_url).reference()
    
    func fetchEvents(date: Date, completion: @escaping () -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: date)
        
        let dispatchGroup = DispatchGroup()
        let ref = self.db.collection("Events").document(selectedDate).collection("hashes")
        
        ref.getDocuments() { (documentSnapshot, error) in
            guard error == nil else {
                print("Error fetching events: \(error!.localizedDescription)")
                return
            }
            
            guard let documents = documentSnapshot else {
                print("no document found in database")
                return
            }
            
            for d in documents.documents {
                if let event = self.createEvent(singleEvent: (d.documentID, d.data()), date: date) {
                    let imageName = event.name + "-0"
                    dispatchGroup.enter()
                    self.downloadImage(childName: "event-images",
                                       imageName: imageName,
                                       date: selectedDate) { image in
                        event.image = image
                        dispatchGroup.leave() // Leave DispatchGroup after download
                    }
                    self.events.append(event)
                    self.loadedEvents.append(selectedDate)
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // This block will execute when all images have been loaded
                // Update the annotations on the map
                completion()
                print("completed")
            }
        }
    }

    func fetchOrganizer(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        let ref = self.db.collection("Organizer")
        
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print("Error fetching organizers: \(error!.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No organizer documents found.")
                return
            }
            
            for document in documents {
                let data = document.data()
                let uuid = document.documentID
                
                guard let name = data["name"] as? String else {
                    print("No name available")
                    continue
                }
                
                guard let beschreibung = data["description"] as? String else {
                    print("Keine Beschreibung verfügbar")
                    continue
                }
                
                let city = data["city"] as? String ?? "Magdeburg"
                
                let newOrganizer = Organizer(uuid: uuid,
                                             name: name,
                                             beschreibung: beschreibung,
                                             city: city,
                                             loadedEvents: [])
                
                if let events = data["events"] as? [String: Any] {
                    newOrganizer.events = events as NSDictionary
                    print(name)
                    print("has events")
                }
                
                let imageName = name // Replace this with the appropriate value
                
                dispatchGroup.enter() // Enter the DispatchGroup
                
                self.downloadImage(childName: "organizer-images/\(uuid)",
                                   imageName: imageName, date: nil) { image in
                    newOrganizer.image = image
                    dispatchGroup.leave()
                }
                
                self.organizer.append(newOrganizer)
            }
            
            dispatchGroup.notify(queue: .main) {
                // Completion handler for when all images are downloaded
                completion()
                print("Organizer fetching completed")
            }
        }
    }
    
    func loadOrganizerEvent(organizerEvents: NSDictionary, hash_value: String) {
        let dispatchGroup = DispatchGroup()
        print("loading organizer events")
        
        // Check if organizer already exists and has loaded events
        guard let selectedOrganizer = self.organizer.first(where: { $0.uuid == hash_value }) else {
            print("Organizer with hash value \(hash_value) not found.")
            return
        }
        
        if !selectedOrganizer.loadedEvents.isEmpty {
            print("Already loaded organizer's events")
            return
        } else {
            print("Loading organizer's events")
        }
        
        print(organizerEvents)
        
        // Iterate over the organizer's events dictionary
        for (key, value) in organizerEvents {
            guard let date = key as? String else {
                print("Invalid key format. Expected String, got: \(key)")
                continue
            }
            
            guard let eventHashes = value as? [String] else {
                print("Invalid value format for \(key). Expected [String], got: \(value)")
                continue
            }
    
            let ref = self.db.collection("Events").document(date)
            
            dispatchGroup.enter() // Enter the DispatchGroup for the Firestore fetch
            
            ref.getDocument { documentSnapshot, error in
                guard error == nil else {
                    print("Error fetching events for date \(date): \(error!.localizedDescription)")
                    dispatchGroup.leave()
                    return
                }
                
                guard let document = documentSnapshot, document.exists,
                      let eventsDict = document.data() as? [String: [String: Any]] else {
                    print("No events found for date \(date)")
                    dispatchGroup.leave()
                    return
                }
                
                for (eventID, eventData) in eventsDict {
                    if eventHashes.contains(eventID) {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        guard let eventDate = dateFormatter.date(from: date) else {
                            print("Invalid date format: \(date)")
                            continue
                        }
                        
                        if let event = self.createEvent(singleEvent: (eventID, eventData), date: eventDate) {
                            let imageName = event.name
                            
                            dispatchGroup.enter() // Enter the DispatchGroup for image download
                            
                            self.downloadImage(childName: "event-images",
                                               imageName: imageName,
                                               date: date) { image in
                                event.image = image
                                dispatchGroup.leave()
                            }
                            
                            // Update organizer's loaded events
                            if !selectedOrganizer.loadedEvents.isEmpty {
                                selectedOrganizer.loadedEvents.append(event)
                            } else {
                                selectedOrganizer.loadedEvents = [event]
                            }
                        } else {
                            print("Could not create event from data: \(eventData)")
                        }
                    }
                }
                
                dispatchGroup.leave() // Leave the DispatchGroup for the Firestore fetch
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Organizer's events loading completed")
        }
    }
    
    func updateParticipation(userID: String, hash: String, status: Bool, date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: date)
    
        let ref = self.db.collection("Users").document(userID).collection("Participations").document("\(selectedDate)")
        
        ref.setData([
            "\(hash)": status
        ], merge: true) { error in
            if let error = error {
                print("Error updating participation: \(error.localizedDescription)")
            } else {
                print("Participation updated successfully")
            }
        }
    }
    
    func getAllParticipatedEvents(userID: String) {
        print("Fetching all participations")
        
        let ref = self.db.collection("Users").document(userID).collection("Participations")
        
        ref.getDocuments() { documentSnapshot, error in
            guard error == nil else {
                print("Error fetching participations: \(error!.localizedDescription)")
                return
            }
            
            guard let documents = documentSnapshot else {
                print("no document found in database")
                return
            }
            
            var fetchedParticipations: [String: [String: Bool]] = [:]
            
            for document in documents.documents {
                let documentID = document.documentID // The ID of the document
                let data = document.data() // The data of the document
                
                // Ensure the data matches the expected format [String: Bool]
                if let participationData = data as? [String: Bool] {
                    fetchedParticipations[documentID] = participationData
                } else {
                    print("Document \(documentID) does not have the expected format")
                }
            }
            
            DispatchQueue.main.async {
                self.participations = fetchedParticipations
            }
            
            print("Participations successfully fetched")
        }
    }

    
    func downloadAllParticipatedEvents() {
        let dispatchGroup = DispatchGroup()

        for (dateKey, participations) in self.participations {
            guard let eventHashes = participations as? [String: Bool] else {
                print("Invalid participation format for date: \(dateKey)")
                continue
            }
        
            for (key, value) in participations {
                
                let foundEvent = self.events.first(where: { $0.hash_value == key })
                
                if (value && foundEvent == nil) {
                    let ref = self.db.collection("Events").document(dateKey).collection("hashes").document("\(key)")
                    dispatchGroup.enter() // Enter DispatchGroup for Firestore fetch
                    
                    ref.getDocument { documentSnapshot, error in
                        guard error == nil else {
                            print("Error fetching events for date \(dateKey): \(error!.localizedDescription)")
                            dispatchGroup.leave()
                            return
                        }
                        
                        guard let document = documentSnapshot, document.exists else {
                            print("No events found for date \(dateKey)")
                            dispatchGroup.leave()
                            return
                        }
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"

                        guard let eventDate = dateFormatter.date(from: dateKey) else {
                            print("Invalid date format: \(dateKey)")
                            return
                        }
                        
                        let data = document.data()
                        
                        if let event = self.createEvent(singleEvent: (document.documentID, data!), date: eventDate) {
                            print(event)
                            let imageName = event.name
                            dispatchGroup.enter()
                            self.downloadImage(childName: "event-images",
                                               imageName: imageName,
                                               date: dateKey) { image in
                                event.image = image
                                dispatchGroup.leave() // Leave DispatchGroup after download
                            }
                            self.events.append(event)
                        }
                    }
                    
                    dispatchGroup.leave() // Leave DispatchGroup after Firestore fetch
                }
            }

            dispatchGroup.notify(queue: .main) {
                print("All participated events downloaded")
            }
        }
    }

    
    private func createEvent(singleEvent: (key: String, value: [String: Any]), date: Date) -> Event? {
        let eventHash = singleEvent.key
        
        var latitude: Double = 0.0
        var longitude: Double = 0.0
        
        guard let eventName = singleEvent.value["eventName"] as? String else {
            print("Error: Could not extract 'event name' from the dictionary.")
            return nil
        }
        
        guard let eventDescription = singleEvent.value["description"] as? String else {
            print("Error: Could not extract 'description' from the dictionary.")
            return nil
        }
        
        guard let city = singleEvent.value["city"] as? String else {
            print("Error: Could not extract 'city' from the dictionary.")
            return nil
        }
        
        guard let zip = singleEvent.value["zip"] as? String else {
            print("Error: Could not extract 'zip' from the dictionary.")
            return nil
        }
        
        guard let street = singleEvent.value["street"] as? String else {
            print("Error: Could not extract 'street' from the dictionary.")
            return nil
        }
        
        guard let houseNumber = singleEvent.value["houseNumber"] as? String else {
            print("Error: Could not extract 'houseNumber' from the dictionary.")
            return nil
        }
        
        if let coordinates = singleEvent.value["coordinates"] as? NSDictionary {
            latitude = coordinates["lat"] as? Double ?? 0.0
            longitude = coordinates["lng"] as? Double ?? 0.0
        } else {
            print("Error: Could not extract 'coordinates' from the dictionary.")
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        guard let locationName = singleEvent.value["locationName"] as? String? else {
            print("Error: Could not extract 'locationName' from the dictionary.")
            return nil
        }
        
        guard let startTimeStr = singleEvent.value["startTime"] as? String else {
            print("Error: Could not extract 'startTime' from the dictionary.")
            return nil
        }
        
        guard let endTimeStr = singleEvent.value["endTime"] as? String else {
            print("Error: Could not extract 'endTime' from the dictionary.")
            return nil
        }
        
        guard let startDateStr = singleEvent.value["startDate"] as? String else {
            print("Error: Could not extract 'startDate' from the dictionary.")
            return nil
        }
        
        guard let endDateStr = singleEvent.value["endDate"] as? String else {
            print("Error: Could not extract 'endDate' from the dictionary.")
            return nil
        }
        
        let startDateTimeStr = "\(startDateStr) \(startTimeStr)"
        let endDateTimeStr = "\(endDateStr) \(endTimeStr)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjust format to match your strings
        dateFormatter.locale = Locale(identifier: "de_DE") // Ensure consistent parsing
        
        guard let startDateTime = dateFormatter.date(from: startDateTimeStr),
              let endDateTime = dateFormatter.date(from: endDateTimeStr) else {
            print("Error: Could not parse date and time strings.")
            return nil
        }
    
        guard let organizerName = singleEvent.value["organizerName"] as? String else {
            print("Error: Could not extract 'organizer' from the dictionary.")
            return nil
        }
        
        guard let entry_str = singleEvent.value["entry"] as? String else {
            print("Error: Could not extract 'entry' from the dictionary.")
            return nil
        }
        
        let entry: Int = Int(entry_str) ?? -1
        
        guard let categories = singleEvent.value["categories"] as? [String] else {
            print("Error: Could not extract 'categories' from the dictionary.")
            return nil
        }
        
        guard let languages = singleEvent.value["languages"] as? [String] else {
            print("Error: Could not extract 'languages' from the dictionary.")
            return nil
        }
        
        let specials = singleEvent.value["specials"] as? [String] ?? []
        
        var socials: [Social] = []
        
        if let socialDict = singleEvent.value["socials"] as? NSDictionary {
            for (key, value) in socialDict {
                if let v = value as? String {
                    if let k = key as? String {
                        if v != "" {
                            socials.append(Social(name: k, image: k + ".png", link: v))
                        }
                    } else {
                        print("Error: Dictionary key is not a String")
                    }
                } else {
                    print("Error: Dictionary value is not a String")
                }
            }
        } else {
            print("Error: Could not extract 'socials' from the dictionary.")
        }
        
        guard let privateEvent = singleEvent.value["private"] as? Bool else {
            print("Error: Could not extract 'private' from the dictionary.")
            return nil
        }
        
        var maxViewers: Int?
        
        if let maxViewersStr = singleEvent.value["maxViewers"] as? String {
            maxViewers = Int(maxViewersStr)
        } else {
            print("Error: Could not extract 'maxViewers' from the dictionary.")
        }
        
        guard let canceled = singleEvent.value["canceled"] as? Bool else {
            print("Error: Could not extract 'canceled' from the dictionary.")
            return nil
        }
        
        var cancelDescription: String?
        
        if let cancelDescriptionStr = singleEvent.value["cancelDescription"] as? String {
            cancelDescription = cancelDescriptionStr
        } else {
            print("Error: Could not extract 'cancelDescription' from the dictionary.")
        }
        
        return Event(name: eventName, eventDescription: eventDescription, city: city, street: street, zip: zip, houseNumber: houseNumber, coordinate: coordinate, locationName: locationName, startDate: startDateTime, endDate: endDateTime, organizer: organizerName, entry: entry, privateEvent: privateEvent, maxViewers: maxViewers, canceled: canceled, cancelDescription: cancelDescription, hash_value: eventHash, socials: socials, categories: categories, languages: languages, specials: specials)
    }
    
    private func downloadImage(childName: String, imageName: String, date: String?, completion: @escaping (UIImage?) -> Void) {
        let image_types = [".jpg", ".jpeg", ".png", ".svg"]
        
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
                if let error = error {
                    print("Error downloading \(imageType) image: \(error.localizedDescription)")
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

