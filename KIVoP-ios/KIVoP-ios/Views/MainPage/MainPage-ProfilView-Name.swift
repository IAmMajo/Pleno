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

struct MainPage_ProfilView_Name: View {
    @StateObject private var viewModel = MainPageProfilNameViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading {
                ProgressView("Laden...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Spacer().frame(height: 10)

                nameInputField // Eingabefeld für den Namen
                saveButton // Speichern-Button
                errorMessageView // Fehleranzeige
                successMessageView // Erfolgsmeldung

                Spacer()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Name", displayMode: .inline)
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
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    // MARK: - Eingabefeld für den Namen
    private var nameInputField: some View {
        HStack {
            Text("Dein Name: ")
                .font(.headline)
                .foregroundColor(Color.primary)

            TextField("Name eingeben", text: $viewModel.name)
                .font(.headline)
                .foregroundColor(Color.primary)
                .padding(5)
                .background(Color(UIColor.systemBackground).opacity(0.8))
                .cornerRadius(5)

            Spacer()
        }
        .padding(10)
        .background(Color(UIColor.systemBackground).opacity(0.8))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    // MARK: - Speichern-Button
    private var saveButton: some View {
        Button(action: {
            viewModel.updateUserName()
        }) {
            Text("Speichern")
                .font(.headline)
                .foregroundColor(.accentColor)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground).opacity(0.8))
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    // MARK: - Fehlermeldung anzeigen
    private var errorMessageView: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal)
            }
        }
    }

    // MARK: - Erfolgsmeldung anzeigen
    private var successMessageView: some View {
        Group {
            if let successMessage = viewModel.successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .font(.footnote)
                    .padding(.horizontal)
            }
        }
    }
}
