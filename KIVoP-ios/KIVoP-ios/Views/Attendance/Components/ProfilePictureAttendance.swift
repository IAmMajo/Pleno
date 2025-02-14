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

