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

// View zum erstellen von SpecialRides (Wird in der NewRideView angezeigt)
struct CreateSpecialRideView: View {
    @ObservedObject var viewModel: EditRideViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedOption: String?
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Details der Fahrt")) {
                    TextField("Name der Fahrt", text: $viewModel.rideName)
                    ZStack(alignment: .topLeading) {
                        // Placeholder Text
                        if viewModel.rideDescription.isEmpty {
                            Text("Beschreibung oder weitere Infos zu deiner Fahrt")
                                .foregroundColor(.gray)
                                .padding(.top, 7)
                                .padding(.leading, 4)
                                .opacity(0.7)
                                .frame(height: 50)
                        }
                        
                        TextEditor(text: $viewModel.rideDescription)
                            .foregroundColor(.black)
                            .frame(minHeight: 50, maxHeight: .infinity)
                    }
                    .padding(.leading, -3)
                    DatePicker("Startzeit", selection: $viewModel.starts, displayedComponents: [.date, .hourAndMinute])
                }

                // Die View enthält die Komponenten um die Location und DestinationLocation zu wählen und anzuzeigen
                LocationPickerView(viewModel: viewModel)
                
                // Informationen zum Auto
                Section(header: Text("Auto und Sitzplätze")) {
                    HStack {
                        ZStack(alignment: .topLeading){
                            // Placeholder Text
                            if viewModel.vehicleDescription.isEmpty {
                                Text("Beschreibung Auto")
                                    .foregroundColor(.gray)
                                    .padding(.top, 10)
                                    .padding(.leading, 4)
                                    .opacity(0.7)
                            }
                            
                            TextEditor(text: $viewModel.vehicleDescription)
                                .foregroundColor(.black)
                                .frame(minHeight: 50, maxHeight: .infinity)
                        }
                        
                        HStack {
                            // Picker für die Auswahl der freien Sitze
                            // Auch 0 ist möglich
                            Picker("",selection: $viewModel.emptySeats) {
                                Text("Freie Plätze").tag(nil as Int?).foregroundColor(.gray)
                                ForEach(0..<100) { number in
                                    Text("\(number)").tag(number as Int?)
                                }
                            }
                            .padding(.top, -10)
                            .foregroundColor(.gray)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Neue Fahrt")
        }
    }
}
