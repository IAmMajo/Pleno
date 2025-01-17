import SwiftUI
import Charts

struct PollPieChartView: View {
    let optionen: [String]
    let stimmen: [Int]

    var body: some View {
        Chart(pieChartDaten()) { data in
            SectorMark(
                angle: .value("Stimmen", data.stimmen),
                angularInset: 4
            )
            .foregroundStyle(by: .value("Option", data.option))
            .cornerRadius(6)
        }
        .chartLegend(alignment: .center, spacing: 16)
    }

    // Helferfunktion, um die Optionen und Stimmen in Chart-Daten umzuwandeln
    private func pieChartDaten() -> [ChartDaten] {
        // Stimmen auffüllen, falls weniger Stimmen als Optionen vorhanden sind
        let gefuellteStimmen = stimmen + Array(repeating: 0, count: max(0, optionen.count - stimmen.count))
        
        return optionen.enumerated().map { index, option in
            ChartDaten(option: option, stimmen: gefuellteStimmen[index])
        }
    }
}

// Datenmodell für das Diagramm
struct ChartDaten: Identifiable {
    let id = UUID()
    let option: String
    let stimmen: Int
}

