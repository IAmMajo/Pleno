// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import SwiftUI

struct EventRideDecision: View {
    @ObservedObject var viewModel: EventRideDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Logik für den Button in der EventRideDetailView
        // Als Fahrer - Fahrt löschen
        // Als Mitfahrer - Mitfahrt stornieren
        // sonst - Mitfahren beantragen
        // Wenn bereits irgendwo im Event angenommen - Anfragen nicht möglich
        // Wenn bereits irgendwo Fahrer - Anfragen nicht möglich
        if (viewModel.eventRideDetail.isSelfDriver){
            Button(action: {
                viewModel.showDeleteRideAlert = true
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
            // Fahrer löscht die ganze Fahrgemeinschaft
            .alert(isPresented: $viewModel.showDeleteRideAlert) {
                Alert(
                    title: Text("Bestätigung"),
                    message: Text("Möchten Sie die Fahrt wirklich löschen?"),
                    primaryButton: .destructive(Text("Löschen")) {
                        // Aktion zum Löschen der Fahrt
                        viewModel.deleteRide()
                        viewModel.showDeleteRideAlert = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        } else {
            if (viewModel.rider?.accepted == false){
                // Anfrage löschen
                Button(action: {
                    viewModel.showDeleteRideRequest = true
                }) {
                    Text("Anfrage zurücknehmen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
                // Request löschen
                .alert(isPresented: $viewModel.showDeleteRideRequest) {
                    Alert(
                        title: Text("Bestätigung"),
                        message: Text("Möchten Sie die Anfrage wirklich löschen?"),
                        primaryButton: .destructive(Text("Löschen")) {
                            // Aktion zum Löschen der Fahrt
                            viewModel.deleteRideRequestedSeat(rider: viewModel.rider!)
                            viewModel.showDeleteRideRequest = false
                        },
                        secondaryButton: .cancel()
                    )
                }
            } else if (viewModel.rider?.accepted == true){
                // Mitfahrt löschen
                Button(action: {
                    viewModel.showRiderDeleteRequest = true
                }) {
                    Text("Mitfahrt löschen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
                // Nachdem Mitfahrer angenommen wurde, storniere ich die Mitfahrt
                .alert(isPresented: $viewModel.showRiderDeleteRequest) {
                    Alert(
                        title: Text("Bestätigung"),
                        message: Text("Möchten Sie Ihren Platz wirklich wieder freigeben?"),
                        primaryButton: .destructive(Text("Freigeben")) {
                            // Aktion zum Löschen der Fahrt
                            viewModel.deleteRideRequestedSeat(rider: viewModel.rider!)
                            viewModel.showRiderDeleteRequest = false
                        },
                        secondaryButton: .cancel()
                    )
                }
            } else {
                // Anfrage stellen
                if viewModel.alreadyAccepted == "accepted"{
                    Button(action: {
                        
                    }) {
                        Text("Du wirst schon von jemandem mitgenommen.")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                } else if viewModel.alreadyAccepted == "driver" {
                    Button(action: {
                        
                    }) {
                        Text("Du bietest eine andere Fahrgemeinschaft an. Daher kannst du nicht an einer anderen Fahrt teilnehmen!")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: {
                        viewModel.requestEventRide()
                    }) {
                        Text("Mitfahrt anfragen")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
