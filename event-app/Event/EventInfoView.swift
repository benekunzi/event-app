import SwiftUI

struct EventInfoView: View {
    let event: Event
    let onRouteButtonPressed: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var locationManager = LocationManager()
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                if let image = event.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.75)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                        .clipped()
                }
                Text(event.title ?? "No title found")
                    .font(.system(size: 25))
                    .bold()
                    .padding(.leading)
                Divider()
                    .padding(.horizontal)
                HStack{
                    Text(event.location)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Divider()
                    Text(event.date, style: .date)
                }
                .padding(.horizontal)
                Divider()
                    .padding(.horizontal)
                TimeWindowView(timeWindow: self.event.timeWindow)
                Divider()
                    .padding(.horizontal)
                Text(event.eventDescription)
                    .padding(.horizontal)
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        onRouteButtonPressed()
                    }) {
                        HStack {
                            Image(systemName: "tram.fill")
                                .foregroundColor(.white)
                            Text("Route")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    Spacer()
                }
            }
        }
    }
}

struct TimeWindowView: View {
    
    var timeWindow: String
    
    var body: some View {
        
        let (startTime, endTime) = extractStartAndEndTime(timeWindow: timeWindow)
        
        HStack(spacing: 20) {
            Text(startTime)
                .padding(5)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(5)
                .foregroundColor(.black)


            Text(endTime)
                .padding(5)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(5)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(.leading)
    }
}

func extractStartAndEndTime(timeWindow: String) -> (String, String) {
    let timeComponents = timeWindow.components(separatedBy: " - ")
    guard timeComponents.count == 2 else {
        return ("Invalid time format", "Invalid time format")
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    let startDate = dateFormatter.date(from: timeComponents[0])
    let endDate = dateFormatter.date(from: timeComponents[1])

    dateFormatter.dateFormat = "HH:mm"

    let startTime = startDate.map { dateFormatter.string(from: $0) } ?? "Invalid time format"
    let endTime = endDate.map { dateFormatter.string(from: $0) } ?? "Invalid time format"

    return (startTime, endTime)
}
