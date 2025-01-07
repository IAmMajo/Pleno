//
//  EventRideView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 04.01.25.
//

import SwiftUI

struct EventRideView: View {
    @ObservedObject var viewModel: EventRideViewModel
    
    var body: some View {
        Text("Planned Ride for \(viewModel.ride.name)")
    }
}
