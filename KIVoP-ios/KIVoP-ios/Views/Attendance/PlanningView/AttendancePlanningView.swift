import SwiftUI
import MeetingServiceDTOs

struct AttendancePlanningView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: AttendancePlaninngViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 16) {
                // Navbar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Zurück")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // Datum des aktuellen Termins
                    Text(viewModel.meeting.start, style: .date)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Suchfeld
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                    HStack {
                        TextField("Suchen", text: $viewModel.searchText)
                            .padding(8)
                    }
                    .padding(.horizontal, 8)
                }
                .frame(height: 40)
                .padding(.horizontal)
                
                // Inhalt
                ZStack {
                    Color.gray.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        // Titel für Teilnahme-Umfrage
                        Text("Kannst du an diesem Termin?")
                            .font(.title2)
                            .padding(.top, 20)
                        
                        // Teilnahme Schaltflächen
                        HStack(spacing: 40) {
                            // "Ja"-Button
                            Button(action: {
                                // Action für Ja
                            }) {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("Ja")
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            // "Nein"-Button
                            Button(action: {
                                // Action für Nein
                            }) {
                                HStack {
                                    Image(systemName: "xmark")
                                    Text("Nein")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Fußzeile mit Hinweis
                        Text("Dies ist nur eine vorläufige Umfrage, um festzustellen, wie viele Mitglieder kommen.")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                        
                        // Teilnahme Status Icons
                        HStack {
                            Spacer()
                            VStack {
                                Text("\(viewModel.presentCount)")
                                    .font(.largeTitle)
                                Image(systemName: "person.fill.checkmark")
                                    .foregroundColor(.blue)
                                    .font(.largeTitle)
                            }
                            
                            Spacer()
                            Spacer()
                            
                            VStack {
                                Text("\(viewModel.acceptedCount)")
                                    .font(.largeTitle)
                                Image(systemName: "person.fill.questionmark")
                                    .foregroundColor(.gray)
                                    .font(.largeTitle)
                            }
                            
                            Spacer()
                            Spacer()
                            
                            VStack {
                                Text("\(viewModel.absentCount)")
                                    .font(.largeTitle)
                                Image(systemName: "person.fill.xmark")
                                    .foregroundColor(.orange)
                                    .font(.largeTitle)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Teilnehmerliste
                        List {
                            Section(header: Text("Mitglieder")) {
                                ForEach(viewModel.filteredAttendances, id: \.identity.id) { attendance in
                                    HStack {
                                        // Profilbild (Platzhalter)
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 40, height: 40)
                                        
                                        // Name und ID
                                        VStack(alignment: .leading) {
                                            Text(attendance.identity.name)
                                                .font(.body)
                                            Text(attendance.identity.id.uuidString)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        // Inline-Statusbehandlung und Farbzuweisung
                                        Text(attendance.status.rawValue.capitalized)
                                            .foregroundColor(
                                                attendance.status == .present ? .green :
                                                attendance.status == .absent ? .red :
                                                attendance.status == .accepted ? .blue : .gray
                                            )
                                            .font(.system(size: 18))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
