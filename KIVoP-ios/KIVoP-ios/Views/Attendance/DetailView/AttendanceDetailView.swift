import SwiftUI

struct AttendanceDetailView: View {
    @ObservedObject var viewModel: AttendanceDetailViewModel
    
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
                            Text("\(viewModel.absentCount)")
                                .font(.largeTitle)
                            Image(systemName: "person.fill.xmark")
                                .foregroundColor(.orange)
                                .font(.largeTitle)
                        }
                        Spacer()
                    }
                    .padding(.top)
                    
                    // Teilnehmerliste
                    List {
                        Section(header: Text("Mitglieder")) {
                            ForEach(viewModel.attendances, id: \.identity.id) { attendance in
                                HStack {
                                    // Profilbild - View in Posters - Components - UserProfileImageView
                                    ProfilePicture(profile: attendance.identity)
                                    
                                    // Name (der eigene Name wird fett gedruckt)
                                    VStack(alignment: .leading) {
                                        Text(attendance.identity.name)
                                            .font(.body)
                                            .fontWeight(attendance.itsame ? .bold : .regular)
                                    }
                                    
                                    Spacer()
                                    
                                    // Inline-Statusbehandlung und Anzeige von Symbolen
                                    Image(systemName:
                                        attendance.status == .present ? "checkmark.circle" :
                                        "xmark.circle"
                                    )
                                    .foregroundColor(
                                        attendance.status == .present ? .blue :
                                        .red
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
            .navigationTitle(viewModel.meeting.name)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
}

