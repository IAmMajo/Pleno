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
import AuthServiceDTOs

struct PendingRequestPopup: View {
    @ObservedObject var viewModel: PendingRequestsViewModel
    var user: UserProfileDTO

    @Environment(\.presentationMode) var presentationMode // Ermöglicht das Schließen der Ansicht

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

            // Zeigt eine Fehlermeldung an, falls vorhanden
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()

            // Buttons für Benutzeraktionen (Bestätigen/Ablehnen)
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

    // Zeigt entweder das Profilbild des Nutzers oder einen Platzhalter mit Initialen an
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

// Extrahiert die Initialen aus dem Namen des Nutzers
private func getInitials(from fullName: String) -> String {
    let components = fullName.split(separator: " ")
    let firstInitial = components.first?.first?.uppercased() ?? ""
    let lastInitial = components.count > 1 ? components.last?.first?.uppercased() ?? "" : ""
    return firstInitial + lastInitial
}
