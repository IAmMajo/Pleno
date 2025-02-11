import SwiftUI
import MeetingServiceDTOs

// Diese Komponente dient dazu die Profilbilder in den Fahrgemeinschaften anzuzeigen
struct ProfilePictureRide: View {
    let name: String
    let id: UUID
    @State private var shortName: String = "??"
    @State private var profileImage: UIImage?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            // Wenn Profilbild vorhanden ist wirdd as angezeigt
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            // Lageanzeige
            } else if isLoading {
                ProgressView("Loading...")
                  .frame(maxWidth: 45, maxHeight: 45)
            // Wenn kein Profilbild vorhanden ist, wird der shortName angezeigt
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(shortName)
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            }
        }
        .onAppear {
            fetchUserImage()
            self.shortName = MainPageAPI.calculateShortName(from: name)
        }
    }

    // Über den RideManager wird der API-Aufruf durchgeführt
    private func fetchUserImage() {
        Task {
            do {
                let imageData = try await RideManager.shared.fetchUserImageAsync(userId: id)
                if let image = UIImage(data: imageData) {
                    self.profileImage = image
                } else {
                    self.errorMessage = "Invalid image data"
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
