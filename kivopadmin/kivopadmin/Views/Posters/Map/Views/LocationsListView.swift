//
//  LocationsListView.swift
//  kivopadmin
//
//  Created by Adrian on 22.01.25.
//

import SwiftUI
import PosterServiceDTOs

struct LocationsListView: View {
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    func getDateStatusText(position: PosterPositionResponseDTO) -> (text: String, color: Color) {
       let status = position.status
       switch status {
       case "hangs":
          if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
             return (text: "morgen überfällig", color: .orange)
          } else {
             return (text: "hängt", color: .blue)
          }
       case "takenDown":
          return (text: "abgehängt", color: .green)
       case "toHang":
          return (text: "hängt noch nicht", color: Color(UIColor.secondaryLabel))
       case "overdue":
          return (text: "überfällig", color: .red)
       default:
          return (text: "", color: Color(UIColor.secondaryLabel))
       }
    }

    
    var body: some View {
        List {
            ForEach(locationViewModel.filteredPositions.sorted { lhs, rhs in
                let statusOrder = ["toHang", "hangs", "overdue", "takenDown"]
                let lhsIndex = statusOrder.firstIndex(of: lhs.position.status.lowercased()) ?? Int.max
                let rhsIndex = statusOrder.firstIndex(of: rhs.position.status.lowercased()) ?? Int.max
                return lhsIndex < rhsIndex
            }, id: \.position.id) { position in
                Button {
                    locationViewModel.showNextLocation(location: position)
                } label: {
                    listRowView(position: position)
                }
                .padding(.vertical, 5)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())

    }
}

extension LocationsListView {
    
    private func listRowView(position: PosterPositionWithAddress) -> some View {
        HStack {
            Group {
                if let imageData = position.position.image, // Unwrap optional Data
                   let uiImage = UIImage(data: imageData) { // Erzeuge ein UIImage aus Data
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                } else {
                    Color.clear // Platzhalter für leere Bilder
                }
            }
            .frame(width: 45, height: 45) // Feste Breite und Höhe für das Bild

            Text(position.address)
            Spacer()
            Text(getDateStatusText(position: position.position).text)
               .font(.caption)
               .foregroundStyle(getDateStatusText(position: position.position).color)
        }
    }

    

}
