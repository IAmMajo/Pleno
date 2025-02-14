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

