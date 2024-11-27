import SwiftUI

struct VotingDetailView: View {
    let voting: Voting

    var body: some View {
        VStack {
            // Titel der Umfrage
            Text(voting.title)
                .font(.largeTitle)
                .padding()

            // Pie Chart für die Ergebnisse
            PieChartView(
                data: voting.results.map { Double($0) }, // Explizite Umwandlung in Double
                labels: voting.options
            )
            .frame(height: 300)
            .padding()

            // Liste mit Details zu den Ergebnissen
            List {
                ForEach(voting.options.indices, id: \.self) { index in
                    HStack {
                        Text(voting.options[index])
                            .foregroundColor(.primary) // Dynamische Textfarbe
                        Spacer()
                        Text("\(voting.results[index]) Stimmen")
                            .fontWeight(.bold)
                            .foregroundColor(.secondary) // Dynamische Textfarbe
                    }
                    .padding(.vertical, 5) // Abstand für bessere Lesbarkeit
                }
            }
            .scrollContentBackground(.hidden) // Entfernt den Standard-Hintergrund der Liste
            .background(listBackgroundColor) // Einheitlicher Hintergrund (weiß im Lightmode)
            .cornerRadius(10) // Abgerundete Ecken für modernen Look
        }
        .padding()
        .background(viewBackgroundColor.ignoresSafeArea()) // Einheitlicher Seitenhintergrund
        .navigationTitle("Ergebnisse")
    }

    // Dynamische Farben für Light/Dark Mode
    private var listBackgroundColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        })
    }

    private var viewBackgroundColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white })
    }
}


// Vorschau mit Beispiel-Daten
struct VotingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VotingDetailView(
            voting: Voting(
                id: UUID(),
                title: "Lieblingsfarbe",
                options: ["Rot", "Blau", "Grün"],
                results: [3, 6, 1],
                isOpen: false,
                createdAt: Date()
            )
        )
        .preferredColorScheme(.light)

        VotingDetailView(
            voting: Voting(
                id: UUID(),
                title: "Lieblingsfarbe",
                options: ["Rot", "Blau", "Grün"],
                results: [3, 6, 1],
                isOpen: false,
                createdAt: Date()
            )
        )
        .preferredColorScheme(.dark)
    }
}
