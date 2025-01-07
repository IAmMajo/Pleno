import SwiftUI
import AuthServiceDTOs

struct UserPopupView: View {
    @Binding var user: UserProfileDTO
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    if let imageData = user.profileImage, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 110, height: 110)
                            .overlay(
                                Text(MainPageAPI.calculateInitials(from: user.name))
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            )
                    }
                }

                HStack {
                    Text("Name:")
                    Spacer()
                    Text(user.name ?? "Unbekannt").foregroundColor(.gray)
                }
                Divider()
                HStack {
                    Text("E-Mail:")
                    Spacer()
                    Text(user.email ?? "Keine E-Mail").foregroundColor(.gray)
                }
                Divider()
                HStack {
                    Text("Admin:")
                    Spacer()
                    Text(user.isAdmin == true ? "Ja" : "Nein").foregroundColor(.gray)
                }
                Divider()
                HStack {
                    Text("Aktiv:")
                    Spacer()
                    Text(user.isActive == true ? "Ja" : "Nein").foregroundColor(.gray)
                }

                Spacer()

                Button("Schließen") {
                    isPresented = false
                }
                .foregroundColor(.blue)
            }
            .padding()
        }
    }
}
