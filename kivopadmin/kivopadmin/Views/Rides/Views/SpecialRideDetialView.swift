import SwiftUI
import RideServiceDTOs

struct SpecialRideDetailView: View {
    @EnvironmentObject private var rideViewModel : RideViewModel
    var rideId: UUID
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(rideViewModel.specialRides, id: \.id){ specialRide in
                    Text(specialRide.name)
                }
            }
        }
    }
}

