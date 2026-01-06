# Event App

![iOS](https://img.shields.io/badge/platform-iOS-blue.svg)
![Swift](https://img.shields.io/badge/swift-5.0+-orange.svg)
![Firebase](https://img.shields.io/badge/backend-Firebase-yellow.svg)

A clean, modern, and high-performance event discovery app for iOS. This application allows users to discover local events through an interactive map or a traditional list view, manage their favorites, and provides a dedicated interface for event organizers.

## 🎬 Demo Video

[Watch the demo video](https://github.com/user-attachments/assets/640b6f06-36a2-4d4d-a698-a99d4b21680f)

## ✨ Features

- **Event Discovery**: Explore events in your area through a native map interface (Google Maps integration).
- **Interactive List View**: Switch to a classic list view to search, filter, and browse events by date and category.
- **Real-time Sync**: All event data, images, and organizer information are fetched and updated in real-time using Firebase Firestore and Storage.
- **Favorites & Saved Events**: Easily save events you're interested in and view them in a dedicated favorites tab.
- **Organizer Dashboard**: Specialized view for event organizers to manage their events and profiles.
- **Modern UI/UX**: Built entirely with SwiftUI, featuring custom components like draggable sheets, blur effects, and smooth transitions.
- **Location-Aware**: Integrated CoreLocation for providing localized event recommendations.

## 🚀 Getting Started

### Prerequisites

- **Xcode 14.0+**
- **iOS 15.0+**
- **CocoaPods**

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/benekunzi/event-app.git
   cd event-app
   ```

2. **Install Dependencies:**
   ```bash
   pod install
   ```

3. **Configure Firebase:**
   - Create a project in the [Firebase Console](https://console.firebase.google.com/).
   - Add an iOS app to your Firebase project and download the `GoogleService-Info.plist`.
   - Place `GoogleService-Info.plist` into the `event-app/event-app/` directory.

4. **Configure Google Maps:**
   - Obtain an API key from the [Google Cloud Console](https://console.cloud.google.com/).
   - Initialize the Google Maps SDK in your `AppDelegate` (or appropriate configuration file).

5. **Open the Project:**
   ```bash
   open event-app.xcworkspace
   ```

## 🛠 Tech Stack

- **Framework**: SwiftUI
- **Backend**: Firebase (Firestore, Storage, Authentication)
- **Maps**: Google Maps SDK for iOS, MapKit
- **Dependency Management**: CocoaPods
- **Language**: Swift

## 📂 Project Structure

- `event-app/`: Main application source code.
  - `Tab-House/`: Main event browsing and discovery views.
  - `Tab-Saved/`: Saved events and calendar views.
  - `Tab-Person/`: User preferences and profile.
  - `Tab-Favoriten/`: Favorites and Organizer management.
  - `ViewModels/`: Business logic and data fetching (Firebase integration).
  - `LocationManager/`: CoreLocation handling.
- `Pods/`: Third-party dependencies.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 👤 Maintainers

- **Benedict Kunzmann** - [GitHub Profile](https://github.com/benekunzi)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details (if available).
