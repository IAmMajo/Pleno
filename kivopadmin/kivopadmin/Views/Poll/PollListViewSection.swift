// This file is licensed under the MIT-0 License.

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
            if polls.isEmpty {
                Text("Keine Umfragen verfügbar.")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(polls, id: \.id) { poll in
                    NavigationLink(destination: destinationBuilder(poll)) {
                        VStack(alignment: .leading) {
                            Text(poll.question)
                                .font(.headline)
                            Text(isCompleted ? "Abgeschlossen am: \(poll.closedAt, formatter: dateFormatter)" :
                                 "Endet: \(poll.closedAt, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .swipeActions {
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
        .background(Color(.systemBackground).ignoresSafeArea())
    }

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
