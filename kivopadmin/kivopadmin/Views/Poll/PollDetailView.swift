import SwiftUI
import PollServiceDTOs

struct PollDetailView: View {
    let poll: GetPollDTO
    @State private var selectedOptions: [UInt8] = []
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            if poll.iVoted {
                // Sofortige Weiterleitung zu den Ergebnissen
                PollResultsView(pollId: poll.id)
            } else {
                renderPollDetails(poll: poll)
            }
        }
        .navigationTitle("Umfrage Details")
        .onAppear {
            if poll.iVoted {
                DispatchQueue.main.async {
                    navigateToResults()
                }
            }
        }
    }

    private func renderPollDetails(poll: GetPollDTO) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(poll.question)
                .font(.title)
                .padding(.horizontal)

            if !poll.description.isEmpty {
                Text(poll.description)
                    .font(.body)
                    .padding(.horizontal)
            }

            List(poll.options, id: \.index) { option in
                HStack {
                    Text(option.text)
                    Spacer()
                    if poll.multiSelect {
                        Toggle("", isOn: Binding(
                            get: { selectedOptions.contains(option.index) },
                            set: { newValue in
                                if newValue {
                                    selectedOptions.append(option.index)
                                } else {
                                    selectedOptions.removeAll { $0 == option.index }
                                }
                            }
                        ))
                        .toggleStyle(SwitchToggleStyle())
                    } else {
                        RadioButton(selectedIndex: $selectedOptions, optionIndex: option.index)
                    }
                }
            }
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        Button("Abstimmen") {
                            submitVote()
                        }
                        .disabled(selectedOptions.isEmpty)
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
            }
        )
        .padding(.bottom, 20)
    }

    private func submitVote() {
        PollAPI.shared.voteInPoll(pollId: poll.id, optionIndex: selectedOptions) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    navigateToResults()
                case .failure(let error):
                    self.errorMessage = "Fehler bei der Abstimmung: \(error.localizedDescription)"
                }
            }
        }
    }

    private func navigateToResults() {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.rootViewController?.present(UIHostingController(rootView: PollResultsView(pollId: poll.id)), animated: true)
            }
        }
    }

}

// Hilfsansicht für Radiobuttons
struct RadioButton: View {
    @Binding var selectedIndex: [UInt8]
    var optionIndex: UInt8

    var body: some View {
        Button(action: {
            selectedIndex = [optionIndex]
        }) {
            Image(systemName: selectedIndex.contains(optionIndex) ? "largecircle.fill.circle" : "circle")
                .foregroundColor(.blue)
        }
    }
}
