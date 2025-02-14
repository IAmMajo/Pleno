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
