import SwiftUI
import MapKit

struct EventInfoSheetView: View {
    @Binding var selectedRegion: MKCoordinateRegion
    @Binding var overlayContentBottomHeight: CGFloat
    @Binding var event: Event
    let onRouteButtonPressed: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var loginModel: LoginModel
    
    @State var eventLiked: Bool = false
    @State var participationStatus: Bool = false
    @State var overlayContentTopHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            Image(uiImage: event.image ?? UIImage(named: "EventImage")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .readHeight {
                    self.overlayContentTopHeight = $0
                }
            
            EventInfoScrollViewContent(
                overlayContentTopHeight: self.$overlayContentTopHeight,
                overlayContentBottomHeight: self.$overlayContentBottomHeight,
                selectedRegion: self.$selectedRegion,
                event: self.$event,
                eventLiked: self.$eventLiked,
                participationStatus: self.$participationStatus)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            if self.loginModel.authenticationState != .skipped {
                self.participationStatus = self.eventViewModel.participations[transformDate(date: self.event.startDate)]?[event.hash_value] == true
                self.eventLiked = self.eventViewModel.participations[transformDate(date: self.event.startDate)]?[event.hash_value] == true
            }
        }
        .onChange(of: self.eventViewModel.participations) { newValue in
            self.participationStatus = self.eventViewModel.participations[transformDate(date: self.event.startDate)]?[event.hash_value] == true
            self.eventLiked = self.eventViewModel.participations[transformDate(date: self.event.startDate)]?[event.hash_value] == true
        }
    }
}
