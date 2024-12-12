//
//  MapView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import MapKit


struct MapView: View {
    var body: some View {
       Map(initialPosition: .region(region))
    }

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446),
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        )
    }
}

#Preview {
    MapView()
}
