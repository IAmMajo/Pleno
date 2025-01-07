//
//  NewRideViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 06.01.25.
//

import SwiftUI
import RideServiceDTOs

class NewRideViewModel: ObservableObject {
    @Published var showSaveConfirmationDialog = false
    var isSaveConfirmed = false
    
    func confirmSaveAction() {
        showSaveConfirmationDialog = true
    }
    
    func saveRide() {
        isSaveConfirmed = true
        print("Fahrt gespeichert")
        // Weitere Speichern-Logik hier hinzufügen
    }
}
