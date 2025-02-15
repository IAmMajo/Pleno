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

struct PollResultsView: View {
    let pollId: UUID
    @State private var pollResults: GetPollResultsDTO?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedOptionIndex: UInt8?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Lade Ergebnisse...")
                    .padding()
            } else if let results = pollResults {
                renderPollResults(results: results)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Umfrage Ergebnisse")
        .onAppear {
            fetchPollResults()
        }
    }

    private func renderPollResults(results: GetPollResultsDTO) -> some View {
        VStack(spacing: 16) {
            PieChartView_Polls(
                optionTextMap: Dictionary(uniqueKeysWithValues: results.results.map { (Int($0.index), $0.text) }),
                votingResults: results
            )
            .frame(height: 200)
            .padding()

            ForEach(results.results, id: \.index) { result in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text((result.text))
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(result.count) Stimmen (\(String(format: "%.1f", result.percentage))%)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedOptionIndex = (selectedOptionIndex == result.index) ? nil : result.index
                        }
                    }

                    if selectedOptionIndex == result.index {
                        renderIdentities(for: result.identities)
                    }
                }
                Divider()
            }
        }
        .padding(.horizontal)
    }

    private func renderIdentities(for identities: [GetIdentityDTO]?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let identities = identities, !identities.isEmpty {
                ForEach(identities, id: \.id) { identity in
                    HStack(spacing: 12) {
                        if let imageUrl = URL(string: "https://kivop.ipv64.net/users/profile-image/identity/\(identity.id)") {
                            AsyncImage(url: imageUrl) { image in
                                image.resizable()
                            } placeholder: {
                                Text(getInitials(from: identity.name))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color.gray))
                            }
                        } else {
                            Text(getInitials(from: identity.name))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color.gray))
                        }

                        Text(identity.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                Text("Keine Teilnehmer sichtbar.")
                    .foregroundColor(.gray)
            }
        }
        .padding(.leading, 8)
    }

    // Funktion zum Generieren von Initialen aus einem Namen
    private func getInitials(from name: String) -> String {
        let nameParts = name.split(separator: " ")
        
        if nameParts.count == 1 {
            // Falls nur ein Name vorhanden ist, verwende die ersten zwei Buchstaben
            return String(nameParts.first!.prefix(2)).uppercased()
        }

        guard let firstInitial = nameParts.first?.prefix(1),
              let lastInitial = nameParts.last?.prefix(1) else {
            return "??"
        }
        
        return "\(firstInitial)\(lastInitial)".uppercased()
    }


    private func fetchPollResults() {
        PollAPI.shared.fetchPollResultsById(pollId: pollId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let resultsData):
                    pollResults = resultsData
                case .failure(let error):
                    errorMessage = "Fehler beim Laden der Ergebnisse: \(error.localizedDescription)"
                }
            }
        }
    }
}
