//
//  LocationDetailView.swift
//  kivopadmin
//
//  Created by Adrian on 23.01.25.
//

import SwiftUI
import PosterServiceDTOs

struct LocationDetailView: View {
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    let position: PosterPositionWithAddress
    
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
        ScrollView{
            VStack{
                imageSection.shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(alignment: .leading, spacing: 16){
                    titleSection
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .ignoresSafeArea()
        .background(.ultraThinMaterial)
    }
}


extension LocationDetailView {
    private var imageSection: some View {
        Group {
            if let imageData = position.position.image, // Unwrap optional Data
               let uiImage = UIImage(data: imageData) { // Erzeuge ein UIImage aus Data
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .frame(width: .infinity)
            } else {
                EmptyView()
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8){
            Text(position.address).font(.largeTitle).fontWeight(.semibold)
            Text(getDateStatusText(position: position.position).text)
               .font(.caption)
               .foregroundStyle(getDateStatusText(position: position.position).color)
        }
    }
    
    private var backButton: some View {
        Button {
            locationViewModel.sheetPosition = nil
        } label: {
            Image(systemName: "xmark").font(.headline).padding(16).foregroundColor(.primary).background(.thinMaterial).cornerRadius(10).shadow(radius: 4).padding()
        }
    }

}
