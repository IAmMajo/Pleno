import SwiftUI

struct PollResultsView: View {
    let frage: String
    let optionen: [String]
    let stimmen: [Int]

    var body: some View {
        VStack {
            // Umfragefrage
            Text(frage)
                .font(.title)
                .padding()

            // Tortendiagramm
            PollPieChartView(optionen: optionen, stimmen: stimmen)
                .frame(height: 250)
                .padding()

            // Liste mit Optionen und Stimmen
            List(validierteOptionenStimmen(), id: \.offset) { data in
                HStack {
                    Text(data.option)
                    Spacer()
                    Text("\(data.stimmen) Stimmen")
                }
            }
        }
        .navigationTitle("Ergebnisse")
    }

    // Helferfunktion: Überprüft und synchronisiert Optionen und Stimmen
    private func validierteOptionenStimmen() -> [(offset: Int, option: String, stimmen: Int)] {
        let minCount = min(optionen.count, stimmen.count)
        return Array(zip(optionen.prefix(minCount), stimmen.prefix(minCount)))
            .enumerated()
            .map { (index, data) in
                (offset: index, option: data.0, stimmen: data.1)
            }
    }
}

// Beispiel-Daten für abgeschlossene Umfragen
struct PollResultsView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PollResultsView(
                frage: "Bevorzugte Programmiersprache?",
                optionen: ["Swift", "Python", "JavaScript"],
                stimmen: [40, 35, 25] // Beispielstimmen
            )
        }
    }
}
