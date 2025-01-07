//
//  EventRideViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 04.01.25.
//

import Foundation
import RideServiceDTOs

class EventRideViewModel: ObservableObject {
    var ride: GetRideDetailDTO
    
    init(ride: GetRideDetailDTO){
        self.ride = ride
    }
}
