import SwiftUI
import MeetingServiceDTOs

struct VotingDetailView: View {
    let voting: GetVotingDTO
    let onBack: () -> Void
    let onDelete: () -> Void
    let onClose: () -> Void
    @State private var votingResults: GetVotingResultsDTO?
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var showConfirmationDialog: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var optionTextMap: [UInt8: String] {
        var map = [UInt8: String]()
        for (index, option) in voting.options.enumerated() {
            map[UInt8(index)] = option.text
        }
        return map
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Laden...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if let votingResults = votingResults {
                resultsView(votingResults: votingResults)
            } else if voting.isOpen {
                activeVotingView
            } else if let errorMessage = errorMessage {
                errorView(errorMessage: errorMessage)
            }
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Umfrage Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { onBack() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    if voting.isOpen {
                        Button(action: { handleClose() }) {
                            Image(systemName: "lock")
                        }
                    }
                    if voting.startedAt == nil {
                        Button(action: { showConfirmationDialog = true }) {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
        .confirmationDialog(
            "Möchten Sie diese Umfrage wirklich löschen?",
            isPresented: $showConfirmationDialog
        ) {
            Button("Löschen", role: .destructive) { handleDelete() }
            Button("Abbrechen", role: .cancel) {}
        }
        .alert("Fehler", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .onAppear(perform: loadVotingResults)
    }

    private func loadVotingResults() {
        isLoading = true
        VotingService.shared.fetchVotingResults(votingId: voting.id) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let results):
                    votingResults = results
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func handleDelete() {
        isLoading = true
        onDelete()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
        }
    }

    private func handleClose() {
        isLoading = true
        onClose()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
        }
    }

    private func resultsView(votingResults: GetVotingResultsDTO) -> some View {
        VStack(spacing: 16) {
            Text("Ergebnisse")
                .font(.headline)

            // PieChart-Ansicht
            PieChartView(optionTextMap: optionTextMap, votingResults: votingResults)
                .frame(height: 300) // Diagramm-Höhe festlegen
                .padding()
                .background(Color.white)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(votingResults.results, id: \.index) { result in
                    HStack {
                        Text(optionTextMap[result.index] ?? "Unbekannt")
                            .font(.body)
                        Spacer()
                        Text("\(result.total) Stimmen (\(String(format: "%.1f", result.percentage))%)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }


    private var activeVotingView: some View {
        VStack(spacing: 16) {
            Text("Diese Umfrage ist aktiv")
                .font(.headline)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(voting.options, id: \.index) { option in
                    Text(option.text)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
    }

    private func errorView(errorMessage: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "xmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.red)
            Text("Ein Fehler ist aufgetreten")
                .font(.headline)
                .foregroundColor(.red)
            Text(errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}


// MARK: - Preview

struct VotingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VotingDetailView(
            voting: GetVotingDTO(
                id: UUID(),
                meetingId: UUID(), // Muss vor 'question' stehen
                question: "Wie soll unser Maskottchen heißen?",
                description: "Wählen Sie einen Namen für unser neues Maskottchen.",
                isOpen: true,
                anonymous: false, // Beispielwert für anonym
                options: [
                    GetVotingOptionDTO(index: 0, text: "Momo"),
                    GetVotingOptionDTO(index: 1, text: "Yumi"),
                    GetVotingOptionDTO(index: 2, text: "Taro"),
                    GetVotingOptionDTO(index: 3, text: "Nashira")
                ]
            ),
            onBack: {}, // Dummy-Aktion für "Zurück"
            onDelete: {}, // Dummy-Aktion für "Löschen"
            onClose: {} // Dummy-Aktion für "Abschließen"
        )
    }
}
