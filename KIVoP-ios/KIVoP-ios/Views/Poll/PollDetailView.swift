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
                .bold()
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
                Button(action: submitVote) {
                    Text("Abstimmen")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedOptions.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(selectedOptions.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        )
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
