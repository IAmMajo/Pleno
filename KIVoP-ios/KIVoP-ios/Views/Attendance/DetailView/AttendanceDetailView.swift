import SwiftUI
import MeetingServiceDTOs

struct AttendanceDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AttendanceDetailViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
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
                    Spacer()
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
                        Spacer()
                        Spacer()
                        
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

