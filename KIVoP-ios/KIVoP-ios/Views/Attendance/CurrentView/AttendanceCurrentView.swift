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

struct AttendanceCurrentView: View {
    @State private var isShowingScanner = false
    @StateObject var viewModel: AttendanceCurrentViewModel
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
                    
                    // Funktionalität um an Meeting teilzunehmen wird ausgeblendet wenn man bereits teilnimmt
                    if !(viewModel.attendance?.status == .present) {
                        Text("Teilnahme bestätigen")
                            .padding(.top)
                            .padding(.horizontal)

                        // QR Code Button
                        Button(action: {
                            isShowingScanner = true
                        }) {
                            HStack {
                                Image(systemName: "qrcode")
                                Text("Code scannen")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .sheet(isPresented: $isShowingScanner) {
                            QRCodeScannerView { code in
                                self.viewModel.participationCode = code
                                self.viewModel.joinMeeting() // Meeting beitreten
                                self.isShowingScanner = false
                            }
                        }
                        .padding(.horizontal)

                        Text("oder")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                            .padding(.horizontal)

                        // Textfeld für Teilnahmecode
                        TextField("Teilnahmecode", text: $viewModel.participationCode)
                            .multilineTextAlignment(.center)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(UIColor.label), lineWidth: 2)
                            )
                            .frame(width: 200)
                            .onSubmit {
                                viewModel.joinMeeting() // Meeting beitreten
                            }
                    }

                    // Antwort ob Beitritt zum Meeting erfolgreich ist.
                    if let message = viewModel.statusMessage {
                        Text(message)
                            .foregroundColor(message == "Erfolgreich der Sitzung beigetreten." ? .green : .red)
                            .padding()
                    }

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
                        
                        VStack {
                            Text("\(viewModel.acceptedCount)")
                                .font(.largeTitle)
                            Image(systemName: "person.fill.questionmark")
                                .foregroundColor(.orange)
                                .font(.largeTitle)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                    Spacer()
                    
                    // Teilnehmerliste
                    List {
                        Section(header: Text("Mitglieder")) {
                            ForEach(viewModel.filteredAttendances, id: \.identity.id) { attendance in
                                HStack {
                                    // Profilbild
                                    ProfilePictureAttendance(profile: attendance.identity)
                                    
                                    // Name (der eigene Name wird fett gedruckt)
                                    VStack(alignment: .leading) {
                                        Text(attendance.identity.name)
                                            .font(.body)
                                            .fontWeight(attendance.itsame ? .bold : .regular)
                                    }
                                    
                                    Spacer()
                                    
                                    // Status
                                    Image(systemName:
                                        attendance.status == .present ? "checkmark.circle" :
                                        "checkmark.circle.badge.questionmark"
                                    )
                                    .foregroundColor(
                                        attendance.status == .present ? .blue :
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
                   Task {
                       viewModel.fetchAttendances()
                   }
                }
                // Wenn die Liste aktualisiert wird, werden die Anwesenheiten neu geholt
                .refreshable {
                    Task {
                        viewModel.fetchAttendances()
                    }
                }
            }
            .navigationTitle(viewModel.meeting.name)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
}
