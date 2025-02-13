// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

struct CreateVotingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateVotingViewModel

    init(meetingManager: MeetingManager, onCreate: @escaping (GetVotingDTO) -> Void) {
        _viewModel = StateObject(wrappedValue: CreateVotingViewModel(meetingManager: meetingManager, onCreate: onCreate))
    }

    var body: some View {
        NavigationView {
            if viewModel.isLoaded {
                Form {
                    // Sitzungsauswahl
                    Section(header: Text("Sitzung auswählen")) {
                        let activeMeetings = viewModel.meetings.filter { $0.status == .inSession }

                        if !activeMeetings.isEmpty {
                            Menu {
                                ForEach(activeMeetings, id: \.id) { meeting in
                                    Button(action: {
                                        viewModel.selectedMeetingId = meeting.id
                                        print("[DEBUG] Sitzung ausgewählt: \(meeting.name)")
                                    }) {
                                        Text(meeting.name)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(viewModel.selectedMeetingName())
                                        .foregroundColor(viewModel.selectedMeetingId == nil ? .gray : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                            }
                        } else {
                            Text("Keine aktiven Sitzungen verfügbar")
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                    }

                    // Frage
                    Section(header: Text("Frage")) {
                        TextField("Frage eingeben", text: $viewModel.question)
                            .autocapitalization(.sentences)
                    }

                    // Beschreibung
                    Section(header: Text("Beschreibung")) {
                        TextField("Beschreibung eingeben", text: $viewModel.description)
                            .autocapitalization(.sentences)
                            .onChange(of: viewModel.description) { _, newValue in
                                if newValue.count > 300 {
                                    viewModel.description = String(newValue.prefix(300))
                                }
                            }
                    }

                    // Anonyme Abstimmung
                    Section(header: Text("Anonym")) {
                        Toggle("Anonyme Abstimmung", isOn: $viewModel.anonymous)
                    }

                    // Optionen
                    Section(header: Text("Optionen")) {
                        ForEach(viewModel.options.indices, id: \.self) { index in
                            HStack {
                                TextField("Option \(index + 1)", text: $viewModel.options[index])
                                    .onChange(of: viewModel.options[index]) { _, newValue in
                                        viewModel.handleOptionChange(index: index, newValue: newValue)
                                    }

                                if viewModel.options.count > 1 && index != 0 {
                                    Button(action: {
                                        viewModel.removeOption(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }

                    // Fehleranzeige
                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                }
                .navigationTitle("Neue Abstimmung")
                .navigationBarItems(
                    leading: Button("Abbrechen") {
                        dismiss()
                    },
                    trailing: Button("Erstellen") {
                        viewModel.createVoting(dismiss: dismiss)
                    }
                    .disabled(!viewModel.isFormValid())
                )
            } else {
                // Ladeindikator, bis die Sitzungen vollständig geladen sind
                VStack {
                    ProgressView("Sitzungen werden geladen...")
                        .padding()
                }
            }
        }
        .onAppear {
            print("[DEBUG] Sitzungsauswahl-View erscheint, lade Sitzungen...")
            viewModel.fetchMeetings()
        }
    }
}
