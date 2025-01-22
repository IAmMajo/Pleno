//
//  UserProfileImageView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 21.01.25.
//

import SwiftUI

struct UserProfileImageView: View {
    let userId: UUID
    @State private var profileImage: UIImage?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                  .resizable()
                  .frame(maxWidth: 45, maxHeight: 45)
                  .aspectRatio(1, contentMode: .fit)
                  .foregroundStyle(.gray.opacity(0.5))
                  .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                  .padding(.trailing, 5)
            } else if isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
               Image(systemName: "person.crop.square.fill")
                  .resizable()
                  .frame(maxWidth: 40, maxHeight: 40)
                  .aspectRatio(1, contentMode: .fit)
                  .foregroundStyle(.gray.opacity(0.5))
                  .padding(.trailing, 5)
            }
        }
        .onAppear {
            fetchProfileImage()
        }
    }

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
//    UserProfileImageView()
}
