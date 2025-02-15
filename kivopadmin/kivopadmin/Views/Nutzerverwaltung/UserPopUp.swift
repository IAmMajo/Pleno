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

struct UserPopupView: View {
    @ObservedObject var viewModel: UserPopupViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                //Profilbild mit Lösch-Button
                VStack {
                    if let imageData = viewModel.profileImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(
                                Button(action: {
                                    viewModel.profileImageData = nil // Nur lokal entfernen, nicht sofort speichern
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .padding(8)
                                        .background(Circle().fill(Color.white))
                                }
                                .offset(x: 40, y: 40)
                            )
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 110, height: 110)
                            .overlay(
                                Text(MainPageAPI.calculateInitials(from: viewModel.user.name))
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            )
                    }
                }

                //Benutzerdetails
                VStack(spacing: 12) {
                    userInfoRow(title: "Name", value: AnyView(
                        HStack {
                            TextField("Benutzername", text: $viewModel.editedName)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    ))

                    userInfoRow(title: "E-Mail", value: AnyView(
                        Text(viewModel.user.email)
                            .foregroundColor(.gray)
                    ))

                    userInfoRow(title: "Admin", value: AnyView(
                        Toggle("", isOn: $viewModel.tempIsAdmin)
                            .labelsHidden()
                    ))

                    userInfoRow(title: "Erstellt am", value: AnyView(
                        Text(viewModel.formattedCreationDate())
                            .foregroundColor(.gray)
                    ))
                }

                Spacer()

                //Fehlermeldung anzeigen (falls vorhanden)
                if viewModel.showError {
                    Text("Fehler beim Speichern.")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                //Speichern-Button
                Button(action: {
                    viewModel.saveChanges()
                    isPresented = false // Pop-Up erst hier schließen!
                }) {
                    Text("Speichern")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.isLoading)

                // **Konto Löschen-Button**
                Button("Konto löschen") {
                    viewModel.isDeletingAccount = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                .alert("Konto löschen", isPresented: $viewModel.isDeletingAccount) {
                    Button("Abbrechen", role: .cancel) {}
                    Button("Löschen", role: .destructive) {
                        viewModel.deleteAccount()
                        isPresented = false // Pop-Up nach Löschung schließen
                    }
                } message: {
                    Text("Möchtest du dieses Konto wirklich löschen?")
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground)) // Hintergrund wie Pop-Up
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }

    //Hilfsfunktion für gleichmäßiges Layout
    private func userInfoRow(title: String, value: AnyView) -> some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            value
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(Color(UIColor.systemBackground)) // Gleiche Hintergrundfarbe wie das Pop-Up
        .cornerRadius(8)
    }
}
