//
//  AnwesenheitView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct AttendanceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthController
    @StateObject private var viewModel = AttendanceViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Navbar
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Zurück")
                    }
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)

                // Titel
                Text("Anwesenheit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                
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
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Aktuelle Sitzung
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AKTUELLE SITZUNG")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            if let currentMeeting = viewModel.currentMeeting {
                                NavigationLink(destination: destinationView(for: currentMeeting)) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(currentMeeting.name)
                                                .foregroundColor(.white)
                                            Text(DateTimeFormatter.formatDate(currentMeeting.start))
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.vertical, 4)
                                        Spacer()
                                        // Image comes here: pending or checked?
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 2)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                }
                            } else {
                                Text("Aktuell ist keine Sitzung im Gange.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray.opacity(0.7))
                                    .padding(.leading)
                            }
                        }
                        .padding(.horizontal)
                        
                        // TabView für vergangene und anstehende Termine
                        Picker("Termine", selection: $viewModel.selectedTab) {
                            Text("Vergangene Termine").tag(0)
                            Text("Anstehende Termine").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Gruppierte Liste
                        List {
                            ForEach(viewModel.groupedMeetings, id: \.key) { group in
                                Section(header: Text(group.key)
                                    .padding(.leading, -5)
                                ) {
                                    ForEach(group.value, id: \.id) { meeting in
                                        NavigationLink(destination: destinationView(for: meeting)) {
                                            VStack(alignment: .leading) {
                                                Text(meeting.name)
                                                    .font(.headline)
                                                Text(DateTimeFormatter.formatDate(meeting.start))
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                // Image for took part or not check or X
                                                // On scheduled also pending
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                    .padding(.top)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func destinationView(for meeting: GetMeetingDTO) -> some View {
        switch meeting.status {
        case .inSession:
            return AnyView(AttendanceCurrentView(meeting: meeting))
            
        case .completed:
            let viewModel = AttendanceDetailViewModel(meeting: meeting)
            return AnyView(AttendanceDetailView(viewModel: viewModel))
            
        case .scheduled:
            let viewModel = AttendancePlaninngViewModel(meeting: meeting)
            return AnyView(AttendancePlanningView(viewModel: viewModel))
        }
    }
}

// Vorschau
struct AttendanceView_Previews: PreviewProvider {
    static var previews: some View {
        AttendanceView()
            .environmentObject(AuthController.shared)
    }
}
