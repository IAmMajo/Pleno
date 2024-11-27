import SwiftUI
import MeetingServiceDTOs

struct VotingResultsView: View {
    let votingResults: GetVotingResultsDTO
    let options: [GetVotingOptionDTO]
    @Binding var isShowingResults: Bool // Kontrolliert die Navigation zur MainPage

    var body: some View {
        VStack {
            // PieChart mit echten Daten
            PieChartView(
                data: votingResults.results.map { Double($0.total) },
                labels: votingResults.results.map { optionText(for: $0.index) }
            )
            .padding()
            .frame(height: 300)

            Spacer()

            Button(action: {
                isShowingResults = false // Navigation zurück zur MainPage
            }) {
                Text("Zurück zur Übersicht")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Ergebnisse")
        .navigationBarBackButtonHidden(true)
    }

    private func optionText(for index: UInt8) -> String {
        if let option = options.first(where: { $0.index == index }) {
            return option.text
        }
        return "Unbekannt"
    }
}
