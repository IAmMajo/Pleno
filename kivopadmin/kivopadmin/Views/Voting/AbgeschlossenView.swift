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
import MeetingServiceDTOs

struct AbgeschlossenView: View {
    // Die Abstimmung und die zugehörigen Ergebnisse
    let voting: GetVotingDTO
    let votingResults: GetVotingResultsDTO?
    
    // Speichert die aktuell ausgewählte Option für die Anzeige von Teilnehmern
    @State private var selectedOption: UInt8? = nil
    
    // Zwischenspeicher für Profilbilder der Teilnehmer
    @State private var identityImages: [UUID: Data?] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(voting.question)
                    .font(.title2)
                    .padding()

                if let results = votingResults {
                    renderPieChart(for: results)
                    renderResultsList(for: results)
                } else {
                    Text("Keine Abstimmungsergebnisse verfügbar.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
    }

    // Erstellt ein Kuchendiagramm basierend auf den Abstimmungsergebnissen
    private func renderPieChart(for results: GetVotingResultsDTO) -> some View {
        let optionTextMap = Dictionary(uniqueKeysWithValues: voting.options.map { ($0.index, $0.text) })
        return PieChartView(optionTextMap: optionTextMap, votingResults: results)
            .frame(height: 200)
            .padding()
    }

    // Erstellt eine Liste mit den Abstimmungsergebnissen
    private func renderResultsList(for results: GetVotingResultsDTO) -> some View {
        let optionTextMap = Dictionary(uniqueKeysWithValues: voting.options.map { ($0.index, $0.text) })
        return VStack(alignment: .leading, spacing: 16) {
            ForEach(results.results, id: \.index) { result in
                VStack {
                    renderResultRow(result: result, optionTextMap: optionTextMap)

                    // Teilnehmer werden nur angezeigt, wenn die Abstimmung nicht anonym ist und die Option ausgewählt wurde
                    if !voting.anonymous && selectedOption == result.index {
                        renderIdentities(for: result.identities)
                    }
                }
            }
        }
        .padding()
    }

    // Erstellt eine einzelne Zeile für ein Abstimmungsergebnis
    private func renderResultRow(result: GetVotingResultDTO, optionTextMap: [UInt8: String]) -> some View {
        Button(action: {
            if !voting.anonymous {
                if selectedOption == result.index {
                    selectedOption = nil
                } else {
                    selectedOption = result.index
                    loadIdentities(for: result.identities)  // Lade die Identitäten nur, wenn Chevron geklickt wird
                }
            }
        }) {
            HStack {
                Text(optionTextMap[result.index] ?? "Enthaltung")
                    .font(.headline)
                Spacer()
                Text("\(result.count) Stimmen (\(String(format: "%.1f", result.percentage))%)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Chevron zeigt an, ob Teilnehmer für eine Option angezeigt werden können
                if !voting.anonymous {
                    Image(systemName: selectedOption == result.index ? "chevron.down" : "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .disabled(voting.anonymous)  // Button für anonyme Abstimmungen deaktivieren
    }

    // Zeigt die Liste der Teilnehmer an, falls die Abstimmung nicht anonym ist
    private func renderIdentities(for identities: [GetIdentityDTO]?) -> some View {
        guard let identities = identities, !identities.isEmpty else {
            return AnyView(Text("Keine Teilnehmer sichtbar.").foregroundColor(.gray).padding(.leading, 8))
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                ForEach(identities, id: \.id) { identity in
                    HStack(alignment: .center, spacing: 12) {
                        renderProfileImage(for: identity)
                            .frame(width: 40, height: 40, alignment: .center)

                        Text(identity.name)
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.leading, 8)
        )
    }

    // Lädt das Profilbild eines Teilnehmers oder zeigt Initialen an
    private func renderProfileImage(for identity: GetIdentityDTO) -> some View {
        if let imageData = identityImages[identity.id] ?? nil,
           let uiImage = UIImage(data: imageData) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            )
        } else {
            return AnyView(
                Circle()
                    .fill(Color.gray)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(initials(for: identity.name))
                            .foregroundColor(.white)
                            .font(.caption)
                    )
            )
        }
    }

    // Ruft die Teilnehmerbilder ab, falls sie noch nicht geladen sind
    private func loadIdentities(for identities: [GetIdentityDTO]?) {
        guard let identities = identities else { return }

        for identity in identities {
            if identityImages[identity.id] == nil {
                VotingService.shared.fetchProfileImage(forIdentityId: identity.id) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            identityImages[identity.id] = data
                        case .failure(let error):
                            print("Fehler beim Abrufen des Profilbilds: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    // Erstellt Initialen aus einem Namen, falls kein Profilbild vorhanden ist
    private func initials(for name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}
