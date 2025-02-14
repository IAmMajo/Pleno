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

struct MainPage_ProfilView_Password: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = MainPageProfilPasswordViewModel()

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                ProgressView("Lade...")
                    .padding()
            } else {
                // Aktuelles Passwort Abschnitt
                VStack(alignment: .leading, spacing: 5) {
                    Text("AKTUELLES PASSWORT")
                        .font(.caption)
                        .foregroundColor(Color.secondary)

                    SecureField("Aktuelles Passwort", text: $viewModel.currentPassword)
                        .padding(10)
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                        .cornerRadius(10)

                    if let error = viewModel.currentPasswordError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                }

                // Neues Passwort Abschnitt
                VStack(alignment: .leading, spacing: 5) {
                    Text("NEUES PASSWORT")
                        .font(.caption)
                        .foregroundColor(Color.secondary)

                    VStack(spacing: 0) {
                        SecureField("Neues Passwort", text: $viewModel.newPassword)
                            .onChange(of: viewModel.newPassword) { _, _ in
                                viewModel.validateNewPassword()
                            }
                            .textContentType(.newPassword)
                            .padding(10)
                            .background(Color(UIColor.systemBackground).opacity(0.8))

                        Divider()
                            .frame(height: 0.5)
                            .background(Color.gray.opacity(0.6))

                        SecureField("Passwort wiederholen", text: $viewModel.confirmPassword)
                            .onChange(of: viewModel.confirmPassword) { _, _ in
                                viewModel.validateConfirmPassword()
                            }
                            .padding(10)
                            .background(Color(UIColor.systemBackground).opacity(0.8))
                    }
                    .cornerRadius(10)

                    // Fehlermeldungen anzeigen, wenn sie existieren
                    if let error = viewModel.newPasswordError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }

                    // "Passwörter stimmen nicht überein" erscheint erst, wenn etwas eingegeben wurde
                    if let error = viewModel.confirmPasswordError, !viewModel.confirmPassword.isEmpty {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                }

                // Erfolgsmeldung anzeigen
                if let successMessage = viewModel.successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                // Speichern-Button
                Button(action: {
                    viewModel.validateAndSavePassword()
                }) {
                    Text("Speichern")
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .background(viewModel.isLoading ? Color.gray : Color.accentColor)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .disabled(viewModel.isLoading)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Passwort", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Profil")
                    }
                }
            }
        }
        .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// Vorschau für SwiftUI Preview
struct MainPage_ProfilView_Password_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainPage_ProfilView_Password()
        }
    }
}
