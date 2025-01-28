import SwiftUI
import MeetingServiceDTOs

struct ProfilePictureRide: View {
    let name: String
    let id: UUID
    @State private var shortName: String = "??"
    @State private var profileImage: UIImage?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else if isLoading {
                ProgressView("Loading...")
                  .frame(maxWidth: 45, maxHeight: 45)
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
