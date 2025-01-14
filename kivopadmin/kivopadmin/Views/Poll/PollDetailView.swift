import SwiftUI

struct PollDetailView: View {
    var poll: Poll
    var onPollEnd: (Poll) -> Void
    @State private var isEnded = false
    @Environment(\.dismiss) var dismiss // Zugriff auf die Navigationsebene

    var body: some View {
        VStack {
            // Umfragefrage
            Text(poll.question)
                .font(.title)
                .padding()

            // Tortendiagramm
            PollPieChartView(
                optionen: poll.options,
                stimmen: Array(poll.votes.values) // Werte in ein Array umwandeln
            )
            .frame(height: 200)
            .padding()

            // Liste der Optionen und Stimmen
            List(Array(poll.options.enumerated()), id: \.offset) { index, option in
                HStack {
                    Text(option)
                    Spacer()
                    Text("\(poll.votes[option] ?? 0) Stimmen")
                }
            }

            // Umfrage beenden Button
            if poll.isActive {
                Button("Umfrage beenden") {
                    isEnded = true
                    onPollEnd(poll)
                    dismiss() // Ansicht schließen und zurück navigieren
                }
                .buttonStyle(DestructiveButtonStyle()) // Benutzerdefinierter Stil
                .padding()
            }
        }
        .navigationTitle("Umfrage Details")
    }
}
