import SwiftUI
import RideServiceDTOs

struct SpecialRidesView: View {
    @EnvironmentObject private var rideViewModel : RideViewModel
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(rideViewModel.specialRides, id: \.id){ specialRide in
                    NavigationLink(destination: SpecialRideDetailView(rideId: specialRide.id).environmentObject(rideViewModel)){
                        Text(specialRide.name)
                    }
                }
            }
        }
    }
}

