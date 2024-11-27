import SwiftUI

struct VotingCardView: View {
    let voting: Voting

    var body: some View {
        VStack(alignment: .leading) {
            Text(voting.title)
                .font(.headline)
                .padding([.top, .horizontal])
            Text(voting.isOpen ? "Offen" : "Geschlossen")
                .font(.subheadline)
                .foregroundColor(voting.isOpen ? .green : .red)
                .padding(.horizontal)
            Spacer()
            HStack {
                Text("\(voting.options.count) Optionen")
                    .font(.caption)
                    .padding(.horizontal)
                Spacer()
                Text("\(voting.createdAt, formatter: dateFormatter)")
                    .font(.caption)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
