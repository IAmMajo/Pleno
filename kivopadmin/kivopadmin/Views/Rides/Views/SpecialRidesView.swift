// This file is licensed under the MIT-0 License.

import SwiftUI
import RideServiceDTOs

struct SpecialRidesView: View {
    // ViewModel als EnvironmentObject
    @EnvironmentObject private var rideViewModel : RideViewModel
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(rideViewModel.specialRides, id: \.id){ specialRide in
                    // Link zur Detailansicht; ViewModel wird als EnvironmentObject mitgegeben
                    NavigationLink(destination: SpecialRideDetailView(rideId: specialRide.id).environmentObject(rideViewModel)){
                        Text(specialRide.name)
                    }
                }
            }
        }
    }
}

