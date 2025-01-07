//
//  RideViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 04.01.25.
//

import Foundation
import SwiftUI
import RideServiceDTOs

class RideViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0
    @Published var isLoading: Bool = false
    // Beispieldaten:
    @Published var rides: [GetRideOverviewDTO] = [
        GetRideOverviewDTO(
            id: UUID(),
            name: "Stadtbesichtigung Berlin",
            description: "Eine entspannte Fahrt durch die Hauptstadt, vorbei an den bekanntesten Sehenswürdigkeiten.",
            starts: Calendar.current.date(byAdding: .hour, value: 2, to: Date())!,
            latitude: 52.5200,
            longitude: 13.4050
        ),
        
        GetRideOverviewDTO(
            id: UUID(),
            name: "Alpenpanorama-Tour",
            description: "Fahrt durch die atemberaubenden Alpen mit spektakulären Ausblicken auf die Berge.",
            starts: Calendar.current.date(byAdding: .hour, value: 3, to: Date())!,
            latitude: 47.3769,
            longitude: 8.5417
        ),
        
        GetRideOverviewDTO(
            id: UUID(),
            name: "Woche in den Vogesen",
            description: "Erkunden Sie die malerischen Vogesen mit einer Mischung aus Natur und Geschichte.",
            starts: Calendar.current.date(byAdding: .hour, value: 6, to: Date())!,
            latitude: 48.7072,
            longitude: 7.3513
        ),
        
        GetRideOverviewDTO(
            id: UUID(),
            name: "Nordseeküste Erleben",
            description: "Eine Fahrt entlang der Nordseeküste, mit Halt in historischen Küstenstädten.",
            starts: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
            latitude: 53.5511,
            longitude: 9.9937
        ),
        
        GetRideOverviewDTO(
            id: UUID(),
            name: "Weinregion Rhein-Mosel",
            description: "Genießen Sie eine Fahrt durch die Weinberge und kleinen Dörfer der Rhein-Mosel-Region.",
            starts: Calendar.current.date(byAdding: .hour, value: 5, to: Date())!,
            latitude: 50.0946,
            longitude: 7.2730
        )
    ]
    
    init() {
        // Konfigurieren der Navbar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // Wechsel zwischen den destinations je nach ride option
    func destinationView(for ride: GetRideDetailDTO, selectedTab: Int) -> some View {
        if selectedTab == 0 {
            let viewModel = EventRideViewModel(ride: ride)
            return AnyView(EventRideView(viewModel: viewModel))
        } else {
            let viewModel = SpecialRideViewModel(ride: ride)
            return AnyView(SpecialRideView(viewModel: viewModel))
        }
    }
}
