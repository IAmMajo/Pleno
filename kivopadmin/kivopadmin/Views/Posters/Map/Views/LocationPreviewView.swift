//
//  LocationPreviewView.swift
//  kivopadmin
//
//  Created by Adrian on 23.01.25.
//

import SwiftUI
import PosterServiceDTOs

struct LocationPreviewView: View {
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    let position: PosterPositionWithAddress
    
    var body: some View {
        ZStack{
            HStack(alignment: .bottom, spacing: 0){
                VStack(alignment: .leading, spacing: 16.0){
                    imageSection
                    titleSection
                }
                buttonsSection
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
            .cornerRadius(10)
            HStack{
                backButton.offset(x: -35, y: -75)
                Spacer()
            }
        }

        

    

    }
}


extension LocationPreviewView {
    private var imageSection: some View {
        ZStack{
            if let imageData = position.position.image, // Unwrap optional Data
               let uiImage = UIImage(data: imageData) { // Erzeuge ein UIImage aus Data
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .frame(maxWidth: 45, maxHeight: 45)
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var titleSection: some View {
        VStack{
            Text(position.address).font(.title2).fontWeight(.bold)
            Text(position.position.status).font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var buttonsSection: some View {
        VStack(spacing: 8){
            Button{
                locationViewModel.sheetPosition = position
            }label:{
                Text("Details").font(.headline).frame(width: 125, height: 35)
            }.buttonStyle(.borderedProminent)
            Button{
                locationViewModel.nextButtonPressed()
            }label:{
                Text("Nächste").font(.headline).frame(width: 125, height: 35)
            }.buttonStyle(.bordered)

        }

    }
    private var backButton: some View {
        Button {
            locationViewModel.selectedPosterPosition = nil
        } label: {
            Image(systemName: "xmark").font(.headline).padding(16).foregroundColor(.primary).background(.thinMaterial).cornerRadius(10).shadow(radius: 4).padding()
        }
    }
}

