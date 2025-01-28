
import SwiftUI
import PosterServiceDTOs

struct LocationMapAnnotationView: View {
    var position: PosterPositionWithAddress
    let accentColor = Color("AccentColor")
    var body: some View {
        VStack{
            Image(systemName: "map.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundColor(.white)
                .padding(6)
                .background(getFilterColor(for: position.position.status))
                .cornerRadius(36)
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(getFilterColor(for: position.position.status))
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -3)
                .padding(.bottom, 40)
        }
        
    }
    
    func getFilterColor(for status: PosterPositionStatus) -> Color {
        switch status {
        case .toHang:
            return Color(UIColor.secondaryLabel)
        case .hangs:
            return .blue
        case .overdue:
            return .red
        case .takenDown:
            return .green
        case .damaged:
            return .orange // Farbe für den neuen Status "damaged"
        }
    }

}
