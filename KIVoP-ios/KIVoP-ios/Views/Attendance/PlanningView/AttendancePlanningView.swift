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

struct AttendancePlanningView: View {
    @ObservedObject var viewModel: AttendancePlanningViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            // Den gesamten Hintergrund grau hinterlegen (Damit alles so aussieht als wäre es eine Liste)
            ZStack {
                (colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
                            .edgesIgnoringSafeArea(.all)
                // Inhalt
                VStack {
                    // Datum + Uhrzeit
                    Text(viewModel.attendanceManager.formattedDate(viewModel.meeting.start))
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(UIColor.label), lineWidth: 1)
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
                        
                        // Nicht Teilnehmen Schaltfläche
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
                    
                    // Teilnahme Status Icons mit Anzahl der Teilnehmer
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
                            ForEach(viewModel.filteredAttendances, id: \.identity.id) { attendance in
                                HStack {
                                    // Profilbild
                                    ProfilePictureAttendance(profile: attendance.identity)
                                    
                                    // Name (der eigene Name wird fett gedruckt)
                                    Text(attendance.identity.name)
                                        .font(.body)
                                        .fontWeight(attendance.itsame ? .bold : .regular)
                                    
                                    Spacer()
                                    
                                    // Status
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
                // Anwesenheiten werden geladen wenn die Komponente angezeigt wird
                .onAppear {
                   viewModel.fetchAttendances()
                }
                // Wenn die Liste aktualisiert wird, werden die Anwesenheiten neu geholt
                .refreshable {
                    viewModel.fetchAttendances()
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
            // Event zum Kalender hinzufügen (wenn ein Teilnehmer später wieder auf absagen drückt, wird der Termin aus dem Kalender entfernt)
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
