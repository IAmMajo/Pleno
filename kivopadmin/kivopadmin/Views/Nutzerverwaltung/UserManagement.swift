// This file is licensed under the MIT-0 License.
import SwiftUI
import AuthServiceDTOs

struct NutzerverwaltungView: View {
    @StateObject private var viewModel = NutzerverwaltungViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                // BEITRITTSVERWALTUNG
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

                // NUTZERÜBERSICHT
                VStack(alignment: .leading, spacing: 10) {
                    Text("NUTZERÜBERSICHT")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 30)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.users, id: \.uid) { user in
                                VStack {
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
                    ProgressView("Benutzer wird geladen...")
                }
            }
            .onAppear {
                viewModel.fetchAllData()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
