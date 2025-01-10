import SwiftUI

struct RideDecision: View {
    @ObservedObject var viewModel: RideDetailViewModel
    
    var body: some View {
        // Logik für Button
        // Als Fahrer - Fahrt löschen, Als Mitfahrer - Mitfahrt stornieren, sonst - Mitfahren beantragen
        if (viewModel.rideDetail.isSelfDriver){
            Button(action: {
                    print("Fahrt löschen")
            }) {
                Text("Fahrt löschen")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .buttonStyle(PlainButtonStyle())
        } else {
//            if (viewModel.ride.isSelfAccepted == "pending"){
//                // Anfrage löschen
//                Button(action: {
//                        print("Anfrage zurücknehmen")
//                }) {
//                    Text("Anfrage zurücknehmen")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.red)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)
//                .buttonStyle(PlainButtonStyle())
//            } else if (viewModel.ride.isSelfAccepted == "accepted"){
//                // Mitfahrt löschen
//                Button(action: {
//                        print("Mitfahrt löschen")
//                }) {
//                    Text("Mitfahrt löschen")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.red)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)
//                .buttonStyle(PlainButtonStyle())
//            } else {
//                // Anfrage stellen
//                Button(action: {
//                        print("Mitfahrt anfragen")
//                }) {
//                    Text("Mitfahrt anfragen")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)
//                .buttonStyle(PlainButtonStyle())
//            }
        }
    }
}
