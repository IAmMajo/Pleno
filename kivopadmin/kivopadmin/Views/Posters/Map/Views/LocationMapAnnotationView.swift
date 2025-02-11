
import SwiftUI
import PosterServiceDTOs

// Das ist auf der Karte zu sehen und repräsentiert den Standort einer Plakatposition
struct LocationMapAnnotationView: View {
    var position: PosterPositionWithAddress
    let accentColor = Color("AccentColor")
    var body: some View {
        VStack{
            // Icon in Abhängigkeit des Status
            PosterHelper.getImageForStatus(position: position.position)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundColor(.white)
                .padding(6)
                .background(PosterHelper.getFilterColor(for: position.position.status))
                .cornerRadius(36)
            
            // Dreieck, damit die View wie ein Marker aussieht
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(PosterHelper.getFilterColor(for: position.position.status))
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -3)
                .padding(.bottom, 40)
        }
        
    }
    


}


