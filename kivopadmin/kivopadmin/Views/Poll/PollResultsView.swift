// This file is licensed under the MIT-0 License.

import SwiftUI
import PollServiceDTOs

/// Ansicht zur Anzeige der Umfrageergebnisse.
/// - Zeigt die Umfragefrage, eine Beschreibung (falls vorhanden) sowie ein Diagramm und eine Ergebnisliste.
/// - Falls die Umfrage anonym ist, werden Teilnehmer nicht angezeigt.
struct PollResultsView: View {
    @StateObject private var viewModel: PollResultsViewModel

    /// Initialisiert die Ansicht mit einer gegebenen Umfrage-ID.
    /// - Parameter pollId: Die eindeutige ID der Umfrage, für die Ergebnisse angezeigt werden sollen.
    init(pollId: UUID) {
        _viewModel = StateObject(wrappedValue: PollResultsViewModel(pollId: pollId))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let poll = viewModel.pollDetails, let results = viewModel.pollResults {
                    // Zeigt die Umfragefrage an
                    Text(poll.question)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()

                    // Falls eine Beschreibung existiert, wird sie angezeigt
                    if !poll.description.isEmpty {
                        Text(poll.description)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Diagramm mit den Ergebnissen
                    renderPieChart(for: results)
                    
                    // Liste mit den Abstimmungsergebnissen
                    renderResultsList(for: results)
                }
                // Falls die Ergebnisse noch geladen werden, wird ein Ladeindikator angezeigt
                else if viewModel.isLoading {
                    ProgressView("Lade Ergebnisse...")
                        .padding()
                }
                // Falls ein Fehler auftritt, wird dieser angezeigt
                else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .navigationTitle("Umfrage Ergebnisse")
    }

    /// Erstellt ein Kreisdiagramm mit den Umfrageergebnissen.
    private func renderPieChart(for results: GetPollResultsDTO) -> some View {
        let optionTextMap = Dictionary(uniqueKeysWithValues: results.results.map { (Int($0.index), $0.text) })
        return PieChartView_Polls(optionTextMap: optionTextMap, votingResults: results)
            .frame(height: 200)
            .padding()
    }

    /// Erstellt eine Liste mit den einzelnen Abstimmungsergebnissen.
    private func renderResultsList(for results: GetPollResultsDTO) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(results.results, id: \.index) { result in
                VStack {
                    renderResultRow(result: result)

                    // Falls eine Option ausgewählt ist, werden die Teilnehmer angezeigt
                    if viewModel.selectedOptionIndex == result.index {
                        renderIdentities(for: result.identities)
                    }
                }
                Divider()
            }
        }
        .padding(.horizontal)
    }

    /// Erstellt eine einzelne Zeile für eine Abstimmungsoption.
    private func renderResultRow(result: GetPollResultDTO) -> some View {
        HStack {
            Text(result.text)
                .font(.headline)
            Spacer()
            Text("\(result.count) Stimmen (\(String(format: "%.1f", result.percentage))%)")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Chevron-Symbol anzeigen, wenn die Umfrage nicht anonym ist
            if viewModel.pollDetails?.anonymous == false {
                Image(systemName: viewModel.selectedOptionIndex == result.index ? "chevron.down" : "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        // Nur klickbar, wenn die Umfrage nicht anonym ist
        .onTapGesture {
            if viewModel.pollDetails?.anonymous == false {
                viewModel.toggleSelectedOption(result.index)
            }
        }
    }

    /// Zeigt die Liste der Teilnehmer an, falls die Umfrage nicht anonym ist.
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

    /// Lädt und zeigt das Profilbild eines Teilnehmers an.
    private func renderProfileImage(for identity: GetIdentityDTO) -> some View {
        if let imageUrl = URL(string: "https://kivop.ipv64.net/users/profile-image/identity/\(identity.id)") {
            return AnyView(
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                } placeholder: {
                    Text(viewModel.getInitials(from: identity.name))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.gray))
                }
            )
        } else {
            return AnyView(
                Circle()
                    .fill(Color.gray)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(viewModel.getInitials(from: identity.name))
                            .foregroundColor(.white)
                            .font(.caption)
                    )
            )
        }
    }
}
