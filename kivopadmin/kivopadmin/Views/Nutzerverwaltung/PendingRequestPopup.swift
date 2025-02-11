// This file is licensed under the MIT-0 License.
import SwiftUI
import AuthServiceDTOs

struct PendingRequestPopup: View {
    @ObservedObject var viewModel: PendingRequestsViewModel
    var user: UserProfileDTO

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    profileImageView()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(user.name)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(user.email)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    Spacer()
                }
                .padding(.bottom, 20)

                HStack {
                    Text("Erstellt am")
                    Spacer()
                    Text(DateFormatterHelper.formattedDate(from: user.createdAt))
                        .foregroundColor(Color.secondary)
                }
                Divider()
            }
            .padding()

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()

            VStack(spacing: 10) {
                Button(action: {
                    viewModel.handleUserAction(userId: user.uid.uuidString, activate: true)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Bestätigen")
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)

                Button(action: {
                    viewModel.handleUserAction(userId: user.uid.uuidString, activate: false)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Ablehnen")
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .navigationTitle("Beitrittsanfrage")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func profileImageView() -> some View {
        if let imageData = user.profileImage, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Text(getInitials(from: user.name))
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                )
        }
    }
}

private func getInitials(from fullName: String) -> String {
    let components = fullName.split(separator: " ")
    let firstInitial = components.first?.first?.uppercased() ?? ""
    let lastInitial = components.count > 1 ? components.last?.first?.uppercased() ?? "" : ""
    return firstInitial + lastInitial
}
