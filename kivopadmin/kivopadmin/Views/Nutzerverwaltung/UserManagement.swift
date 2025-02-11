// This file is licensed under the MIT-0 License.

import SwiftUI
import AuthServiceDTOs

struct NutzerverwaltungView: View {
    @StateObject private var viewModel = NutzerverwaltungViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                // Sektion für die Verwaltung von Beitrittsanfragen
                VStack(alignment: .leading, spacing: 10) {
                    Text("BEITRITTSVERWALTUNG")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 30)

                    HStack {
                        Text("Ausstehend")
                            .foregroundColor(.primary)

                        Spacer()

                        Text("\(viewModel.pendingRequestsCount)")
                            .foregroundColor(.orange)

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 30)
                    .onTapGesture {
                        viewModel.isPendingRequestPopupPresented = true
                    }
                    .sheet(isPresented: $viewModel.isPendingRequestPopupPresented) {
                        PendingRequestsNavigationView(
                            isPresented: $viewModel.isPendingRequestPopupPresented,
                            onListUpdate: {
                                viewModel.fetchPendingRequestsCount()
                            }
                        )
                    }
                }

                // Sektion zur Anzeige der aktuellen Nutzer
                VStack(alignment: .leading, spacing: 10) {
                    Text("NUTZERÜBERSICHT")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 30)

                    // Horizontales ScrollView zur Anzeige der Nutzer mit Profilbildern
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.users, id: \.uid) { user in
                                VStack {
                                    // Falls ein Profilbild vorhanden ist, wird es angezeigt
                                    if let imageData = user.profileImage, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .onTapGesture {
                                                viewModel.selectUser(user)
                                            }
                                    } else {
                                        // Falls kein Bild vorhanden ist, wird ein Platzhalter mit den Initialen des Nutzers angezeigt
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Text(MainPageAPI.calculateInitials(from: user.name))
                                                    .foregroundColor(.white)
                                            )
                                            .onTapGesture {
                                                viewModel.selectUser(user)
                                            }
                                    }
                                    Text(user.name)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                }

                Spacer()
            }
            .navigationTitle("Nutzerverwaltung")
            .sheet(isPresented: $viewModel.isUserPopupPresented) {
                if let user = viewModel.selectedUser {
                    // Zeigt eine Detailansicht für einen Benutzer an, wenn einer ausgewählt wurde
                    UserPopupView(
                        viewModel: UserPopupViewModel(
                            user: user,
                            onSave: {
                                viewModel.fetchAllUsers()
                                viewModel.isUserPopupPresented = false // PopUp schließen nach erfolgreichem Speichern
                            },
                            onDelete: {
                                viewModel.fetchAllUsers()
                                viewModel.isUserPopupPresented = false // PopUp schließen nach Löschung
                            }
                        ),
                        isPresented: $viewModel.isUserPopupPresented
                    )
                } else {
                    // Falls noch kein Benutzer geladen wurde, wird ein Ladeindikator angezeigt
                    ProgressView("Benutzer wird geladen...")
                }
            }
            .onAppear {
                viewModel.fetchAllData() // Lädt alle relevanten Daten beim Öffnen der Ansicht
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Stellt sicher, dass das Layout auf allen Geräten gut funktioniert
    }
}
