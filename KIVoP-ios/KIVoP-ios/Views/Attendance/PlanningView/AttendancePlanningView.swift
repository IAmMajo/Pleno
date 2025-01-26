import SwiftUI

struct AttendancePlanningView: View {
    @ObservedObject var viewModel: AttendancePlanningViewModel
    
    var body: some View {
        NavigationStack {
            // Den gesamten Hintergrund grau hinterlegen
            ZStack {
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                // Inhalt
                VStack {
                    // Datum + Uhrzeit
                    Text(viewModel.formattedDate(viewModel.meeting.start))
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding(.vertical)
                    // Titel für Teilnahme-Umfrage
                    Text("Kannst du an diesem Termin?")
                        .font(.title2)
                        .padding(.top, 20)
                    
                    // Teilnahme Schaltflächen
                    HStack(spacing: 40) {
                        Button(action: {
                            viewModel.markAttendanceAsAccepted()
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Ja")
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(viewModel.attendance?.status == .accepted ? Color.blue : Color.gray)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        
                        // "Nein"-Button
                        Button(action: {
                            viewModel.markAttendanceAsAbsent()
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Nein")
                            }
                            .padding()
                            .background(viewModel.attendance?.status == .absent ? Color.orange : Color.gray)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
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
                            Text("\(viewModel.acceptedCount)")
                                .font(.largeTitle)
                            Image(systemName: "person.fill.checkmark")
                                .foregroundColor(.blue)
                                .font(.largeTitle)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("\(viewModel.nilCount)")
                                .font(.largeTitle)
                            Image(systemName: "person.fill.questionmark")
                                .foregroundColor(.gray)
                                .font(.largeTitle)
                        }
                        
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
                    
                    // Teilnehmerliste
                    List {
                        Section(header: Text("Mitglieder")) {
                            ForEach(viewModel.attendances, id: \.identity.id) { attendance in
                                HStack {
                                    // Profilbild
                                    ProfilePictureAttendance(profile: attendance.identity)
                                    
                                    // Name (der eigene Name wird fett gedruckt)
                                    Text(attendance.identity.name)
                                        .font(.body)
                                        .fontWeight(attendance.itsame ? .bold : .regular)
                                    
                                    Spacer()
                                    
                                    // Symbole zum anzeigen des Anwesenheitsstatus
                                    Image(systemName:
                                        attendance.status == .absent ? "xmark.circle" :
                                        attendance.status == .accepted ? "checkmark.circle" :
                                        "questionmark.circle"
                                    )
                                    .foregroundColor(
                                        attendance.status == .absent ? .red :
                                        attendance.status == .accepted ? .blue :
                                        .gray
                                    )
                                    .font(.system(size: 18))
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .overlay {
                    if viewModel.isLoading {
                      ProgressView("Lädt...")
                   }
                }
                .onAppear {
                   Task {
                       viewModel.fetchAttendances()
                   }
                }
                .refreshable {
                    Task {
                        viewModel.fetchAttendances()
                    }
                }
            }
            .alert("Hinweis", isPresented: $viewModel.isShowingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .navigationTitle(viewModel.meeting.name)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.addEventToCalendar(eventTitle: viewModel.meeting.name, eventDate: viewModel.meeting.start, duration: viewModel.meeting.duration)
                    }) {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
