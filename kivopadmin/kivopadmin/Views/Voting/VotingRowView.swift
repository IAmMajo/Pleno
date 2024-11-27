import SwiftUI

struct VotingRowView: View {
    let voting: Voting

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(voting.title)
                    .font(.headline)
                Text(voting.isOpen ? "Offen" : "Geschlossen")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("\(voting.createdAt, formatter: dateFormatter)")
                .font(.caption)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()
