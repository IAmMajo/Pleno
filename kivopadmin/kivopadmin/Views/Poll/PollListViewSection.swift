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
import PollServiceDTOs

struct PollListViewSection<Destination: View>: View {
    let polls: [GetPollDTO]
    let deletePoll: (UUID) -> Void
    let destinationBuilder: (GetPollDTO) -> Destination
    let dateFormatter: DateFormatter
    let isCompleted: Bool

    var body: some View {
        List {
            // Falls keine Umfragen vorhanden sind, eine Nachricht anzeigen
            if polls.isEmpty {
                Text("Keine Umfragen verfügbar.")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                // Iteriere durch alle Umfragen und erstelle Listenelemente
                ForEach(polls, id: \.id) { poll in
                    NavigationLink(destination: destinationBuilder(poll)) {
                        VStack(alignment: .leading) {
                            Text(poll.question)
                                .font(.headline)
                            
                            // Je nach Status das passende Datum anzeigen
                            Text(isCompleted ? "Abgeschlossen am: \(poll.closedAt, formatter: dateFormatter)" :
                                 "Endet: \(poll.closedAt, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .swipeActions {
                        // Löschaktion für eine Umfrage mit Bestätigung
                        Button(role: .destructive) {
                            deletePoll(poll.id)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .refreshable {
            await refreshPolls()
        }
        .background(Color(.systemBackground).ignoresSafeArea()) // Hintergrundfarbe anpassen
    }

    // Aktualisiert die Liste der Umfragen asynchron.
    private func refreshPolls() async {
        await withCheckedContinuation { continuation in
            PollAPI.shared.fetchAllPolls { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let polls):
                        print("✅ Erfolgreich \(polls.count) Umfragen geladen.")
                    default:
                        break
                    }
                    continuation.resume()
                }
            }
        }
    }
}
