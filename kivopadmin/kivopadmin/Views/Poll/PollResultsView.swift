import SwiftUI
import PollServiceDTOs

struct PollResultsView: View {
    let pollId: UUID
    @State private var pollResults: GetPollResultsDTO?
    @State private var pollDetails: GetPollDTO?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedOptionIndex: UInt8?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let poll = pollDetails, let results = pollResults {
                    Text(poll.question)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()

                    if !poll.description.isEmpty {
                        Text(poll.description)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    renderPieChart(for: results)
                    renderResultsList(for: results)
                } else if isLoading {
                    ProgressView("Lade Ergebnisse...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .navigationTitle("Umfrage Ergebnisse")
        .onAppear {
            fetchPollResults()
            fetchPollDetails()
        }
    }

    private func renderPieChart(for results: GetPollResultsDTO) -> some View {
        let optionTextMap = Dictionary(uniqueKeysWithValues: results.results.map { (Int($0.index), $0.text) })
        return PieChartView_Polls(optionTextMap: optionTextMap, votingResults: results)
            .frame(height: 200)
            .padding()
    }

    private func renderResultsList(for results: GetPollResultsDTO) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(results.results, id: \.index) { result in
                VStack {
                    renderResultRow(result: result)

                    if selectedOptionIndex == result.index {
                        renderIdentities(for: result.identities)
                    }
                }
                Divider()
            }
        }
        .padding(.horizontal)
    }

    private func renderResultRow(result: GetPollResultDTO) -> some View {
        Button(action: {
            if selectedOptionIndex == result.index {
                selectedOptionIndex = nil
            } else {
                selectedOptionIndex = result.index
            }
        }) {
            HStack {
                Text(result.text)
                    .font(.headline)
                Spacer()
                Text("\(result.count) Stimmen (\(String(format: "%.1f", result.percentage))%)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Image(systemName: selectedOptionIndex == result.index ? "chevron.down" : "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
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
        if let imageUrl = URL(string: "https://kivop.ipv64.net/users/profile-image/identity/\(identity.id)") {
            return AnyView(
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                } placeholder: {
                    Text(getInitials(from: identity.name))
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
                        Text(getInitials(from: identity.name))
                            .foregroundColor(.white)
                            .font(.caption)
                    )
            )
        }
    }

    private func getInitials(from name: String) -> String {
        let nameParts = name.split(separator: " ")
        
        if nameParts.count == 1 {
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

    private func fetchPollDetails() {
        PollAPI.shared.fetchPollById(pollId: pollId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pollData):
                    pollDetails = pollData
                case .failure(let error):
                    errorMessage = "Fehler beim Laden der Umfrage-Details: \(error.localizedDescription)"
                }
            }
        }
    }
}
