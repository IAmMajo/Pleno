// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
