// This file is licensed under the MIT-0 License.
import SwiftUI
import MapKit

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

                LocationPickerView(viewModel: viewModel)
                
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
