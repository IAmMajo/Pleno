// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

struct AbgeschlossenView: View {
    let voting: GetVotingDTO
    let votingResults: GetVotingResultsDTO?
    
    @State private var selectedOption: UInt8? = nil
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

    private func renderPieChart(for results: GetVotingResultsDTO) -> some View {
        let optionTextMap = Dictionary(uniqueKeysWithValues: voting.options.map { ($0.index, $0.text) })
        return PieChartView(optionTextMap: optionTextMap, votingResults: results)
            .frame(height: 200)
            .padding()
    }

    private func renderResultsList(for results: GetVotingResultsDTO) -> some View {
        let optionTextMap = Dictionary(uniqueKeysWithValues: voting.options.map { ($0.index, $0.text) })
        return VStack(alignment: .leading, spacing: 16) {
            ForEach(results.results, id: \.index) { result in
                VStack {
                    renderResultRow(result: result, optionTextMap: optionTextMap)

                    // Teilnehmer nur anzeigen, wenn die Abstimmung nicht anonym ist und das Chevron nach unten zeigt
                    if !voting.anonymous && selectedOption == result.index {
                        renderIdentities(for: result.identities)
                    }
                }
            }
        }
        .padding()
    }

    private func renderResultRow(result: GetVotingResultDTO, optionTextMap: [UInt8: String]) -> some View {
        Button(action: {
            if !voting.anonymous {
                if selectedOption == result.index {
                    selectedOption = nil
                } else {
                    selectedOption = result.index
                    loadIdentities(for: result.identities)  // Lade Teilnehmerliste nur, wenn Chevron geklickt wird
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

                // Nur bei nicht-anonymer Abstimmung Chevron anzeigen
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

    private func initials(for name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}
