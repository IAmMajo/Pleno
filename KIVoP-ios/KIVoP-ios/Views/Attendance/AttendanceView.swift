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

struct AttendanceView: View {
    @StateObject private var viewModel = AttendanceViewModel()
    
    var body: some View {
        NavigationStack {
            // Inhalt
            VStack {
                //Aktuelle Meetings
                List {
                    if !viewModel.currentMeetings.isEmpty {
                        Section(header:
                                    Text("AKTUELLE SITZUNG")
                            .padding(.leading, -5)){
                                // Alle Meetings die in der variable currentMeetings sind werden angezeigt
                                ForEach(viewModel.currentMeetings, id: \.id) { currentMeeting in
                                    NavigationLink(destination: viewModel.destinationView(for: currentMeeting)) {
                                        HStack {
                                            // Icon für Meeting im Gange
                                            Image(systemName: "play.circle")
                                                // Farbe je nach Teilnahme Status
                                                .foregroundColor(
                                                    currentMeeting.myAttendanceStatus == .present ? .blue :
                                                            .orange
                                                )
                                            VStack(alignment: .leading) {
                                                // Meeting Name
                                                Text(currentMeeting.name)
                                                    .font(.headline)
                                                // Meeting Datum
                                                Text(DateTimeFormatter.formatDate(currentMeeting.start))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Image(systemName:
                                                    currentMeeting.myAttendanceStatus == .present ? "checkmark.circle" :
                                                    "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90"
                                            )
                                            .foregroundColor(
                                                currentMeeting.myAttendanceStatus == .present ? .blue :
                                                        .orange
                                            )
                                            .font(.system(size: 18))
                                        }
                                    }
                                }
                            }
                    } else {
                        Text("Aktuell sind keine Sitzungen im Gange.")
                            .foregroundColor(.gray)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    
                    // TabView für vergangene und anstehende Termine
                    // Je nach ausgewähltem Picker wird entschieden in welche View weitergeleitet werden soll (Detail oder Planning)
                    Picker("Termine", selection: $viewModel.selectedTab) {
                        Text("Vergangene Termine").tag(0)
                        Text("Anstehende Termine").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .padding(-20)
                    
                    // Liste für vergangene und anstehende Termine
                    // In der Schleife wird je nach ausgewähltem Picker eine Liste erstellt mit den jeweiligen Meetings
                    ForEach(viewModel.groupedMeetings, id: \.key) { group in
                        Section(header: Text(group.key)
                            .padding(.leading, -5)
                        ) {
                            ForEach(group.value, id: \.id) { meeting in
                                NavigationLink(destination: viewModel.destinationView(for: meeting)) {
                                    HStack{
                                        VStack(alignment: .leading) {
                                            Text(meeting.name)
                                                .font(.headline)
                                            Text(DateTimeFormatter.formatDate(meeting.start))
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        
                                        // Statusanzeige (Farbe + Symbol)
                                        Image(systemName: {
                                            switch meeting.myAttendanceStatus {
                                            case .accepted, .present:
                                                return "checkmark.circle"
                                            case .absent:
                                                return "xmark.circle"
                                            default:
                                                return viewModel.selectedTab == 0 ? "xmark.circle" : "calendar"
                                            }
                                        }())
                                        .foregroundColor({
                                            switch meeting.myAttendanceStatus {
                                            case .accepted, .present:
                                                return .blue
                                            case .absent:
                                                return .red
                                            default:
                                                return viewModel.selectedTab == 0 ? .red : .orange
                                            }
                                        }())
                                        .font(.system(size: 18))
                                    }
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
                   viewModel.fetchMeetings()
                }
                .refreshable {
                    viewModel.fetchMeetings()
                }
            }
            .navigationTitle("Anwesenheit")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
}
