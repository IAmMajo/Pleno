
import SwiftUI
import PosterServiceDTOs

struct LocationPreviewView: View {
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    let position: PosterPositionWithAddress
    
    func getDateStatusText(position: PosterPositionResponseDTO) -> (text: String, color: Color) {
        let status = position.status
        switch status {
        case .hangs:
            if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
                return (text: "morgen überfällig", color: .orange)
            } else {
                return (text: "hängt", color: .blue)
            }
        case .takenDown:
            return (text: "abgehangen", color: .green)
        case .toHang:
            return (text: "hängt noch nicht", color: Color(UIColor.secondaryLabel))
        case .overdue:
            return (text: "überfällig", color: .red)
        case .damaged:
            return (text: "beschädigt", color: .orange)
        default:
            return (text: "", color: Color(UIColor.secondaryLabel))
        }
    }
    
    var body: some View {
        ZStack{
            HStack(){
                imageSection
                VStack(alignment: .leading, spacing: 16.0){
                    titleSection
                }
                buttonsSection
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThickMaterial))
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
        Group {
            if let imageData = position.image, // Unwrap optional Data
               let uiImage = UIImage(data: imageData) { // Erzeuge ein UIImage aus Data
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .frame(maxWidth: 100, maxHeight: 100)
            } else {
                ZStack {} // Leere View, wenn kein Bild verfügbar
            }
        }
    }

    
    private var titleSection: some View {
        VStack(alignment: .leading){
            Text(position.address).font(.title2).fontWeight(.bold)
            Text(getDateStatusText(position: position.position).text)
               .font(.headline)
               .foregroundStyle(getDateStatusText(position: position.position).color)
            if position.position.status != .takenDown {
                Text("Ablaufdatum: \(DateTimeFormatter.formatDate(position.position.expiresAt))")
            }
        }
        .padding(.leading)
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

