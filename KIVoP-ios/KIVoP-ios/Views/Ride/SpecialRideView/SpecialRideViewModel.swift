//
//  SpecialRideViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 04.01.25.
//

import Foundation
import RideServiceDTOs

class SpecialRideViewModel: ObservableObject {
    var ride: GetRideDetailDTO
    
    init(ride: GetRideDetailDTO){
        self.ride = ride
    }
}
