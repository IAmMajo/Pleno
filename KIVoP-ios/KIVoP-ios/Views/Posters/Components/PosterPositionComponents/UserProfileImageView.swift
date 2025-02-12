// This file is licensed under the MIT-0 License.
//
//  UserProfileImageView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 21.01.25.
//

import SwiftUI

// A view that displays a user's profile image.
// If the profile image is unavailable, it displays a default placeholder.
// Fetches the image asynchronously from the `PosterService`.
struct UserProfileImageView: View {
    let userId: UUID
    @State private var profileImage: UIImage?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
           // Profile Image Display
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                  .resizable()
                  .frame(maxWidth: 45, maxHeight: 45)
                  .aspectRatio(1, contentMode: .fit)
                  .foregroundStyle(.gray.opacity(0.5))
                  .clipShape(Circle())
                  .padding(.trailing, 5)
            } else if isLoading {
                ProgressView("Loading...")
                  .frame(maxWidth: 45, maxHeight: 45)
               // Default Placeholder
            } else {
               Image(systemName: "person.crop.circle.fill")
                  .resizable()
                  .frame(maxWidth: 45, maxHeight: 45)
                  .aspectRatio(1, contentMode: .fit)
                  .foregroundStyle(.gray.opacity(0.5))
                  .padding(.trailing, 5)
            }
        }
        .onAppear {
            fetchProfileImage()
        }
    }
   
   // Fetches the user's profile image asynchronously.
    private func fetchProfileImage() {
        Task {
            do {
                let imageData = try await PosterService.shared.fetchProfileImageAsync(userId: userId)
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

#Preview {
}
