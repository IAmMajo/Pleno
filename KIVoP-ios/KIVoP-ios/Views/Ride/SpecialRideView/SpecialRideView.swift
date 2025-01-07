//
//  SpecialRideView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 04.01.25.
//

import SwiftUI

struct SpecialRideView: View {
    @ObservedObject var viewModel: SpecialRideViewModel
    
    var body: some View {
        Text("Planned Ride for \(viewModel.ride.name)")
    }
}
