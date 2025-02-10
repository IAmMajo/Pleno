import SwiftUI
import MeetingServiceDTOs

struct ProfilePictureAttendance: View {
    let profile: GetIdentityDTO
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
        // Profilbild wird geladen
        // Wenn kein Profilbild vorhanden ist, wird der shortname ermittelt
        .onAppear {
            self.shortName = MainPageAPI.calculateShortName(from: profile.name)
            fetchIdentityImage()
        }
    }

    private func fetchIdentityImage() {
        Task {
            do {
                let imageData = try await AttendanceManager.shared.fetchIdentityImageAsync(userId: profile.id)
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

