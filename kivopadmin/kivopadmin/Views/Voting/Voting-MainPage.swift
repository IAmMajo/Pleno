import SwiftUI

struct Voting_MainPage: View {
    @State private var showCreateVoting = false
    @State private var votings = mockVotings
    @State private var selectedTab: Tab = .current
    @State private var selectedVoting: Voting? // Verlinkung zur Detailansicht

    enum Tab {
        case current
        case past
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    TabButton(title: "Aktuelle Umfragen", isSelected: selectedTab == .current) {
                        selectedTab = .current
                    }
                    TabButton(title: "Vergangene Umfragen", isSelected: selectedTab == .past) {
                        selectedTab = .past
                    }
                    Spacer()
                    Button(action: { showCreateVoting = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color.accentColor)
                    }
                }
                .padding()
                .background(Color("NavigationBarBackground"))

                // Grid Layout for Cards
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
                        spacing: 16
                    ) {
                        ForEach(votings.filter { $0.isOpen == (selectedTab == .current) }) { voting in
                            NavigationLink(destination: VotingDetailView(voting: voting)) {
                                VotingCardView(voting: voting)
                                    .frame(height: 180)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(cardBackgroundColor)
                                            .shadow(color: shadowColor, radius: 4)
                                    )
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                    .padding()
                }
                .sheet(isPresented: $showCreateVoting) {
                    CreateVotingView(votings: $votings)
                        .background(viewBackgroundColor)
                }
            }
            .navigationTitle("Umfragen")
            .background(viewBackgroundColor.ignoresSafeArea()) // Einheitlicher Hintergrund
        }
    }

    // Dynamische Farben für Light/Dark Mode
    private var viewBackgroundColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        })
    }

    private var cardBackgroundColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.darkGray : UIColor.white
        })
    }

    private var shadowColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.gray
        })
    }
}

struct TabButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? Color.accentColor : Color.gray.opacity(0.7))
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                .cornerRadius(8)
        }
    }
}

struct Voting_MainPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Voting_MainPage()
                .preferredColorScheme(.light)

            Voting_MainPage()
                .preferredColorScheme(.dark)
        }
    }
}
