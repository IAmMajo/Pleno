import SwiftUI
import AuthServiceDTOs

struct MainPage_ProfilView_Name: View {
    @State private var name: String = "" // Initial leer, wird über GET gefüllt
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Laden...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Spacer().frame(height: 10)

                // Namensbearbeitung
                HStack {
                    Text("Dein Name: ")
                        .font(.headline)
                        .foregroundColor(Color.primary)

                    TextField("Name eingeben", text: $name)
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

                // Speichern-Button
                Button(action: {
                    updateUserName()
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

                // Fehlermeldung
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }

                // Erfolgsmeldung
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.footnote)
                        .padding(.horizontal)
                }

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
        .onAppear {
            loadUserName()
        }
    }

    private func loadUserName() {
        isLoading = true
        errorMessage = nil

        MainPageAPI.fetchUserProfile { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let profile):
                    self.name = profile.name
                case .failure(let error):
                    self.errorMessage = "Fehler: \(error.localizedDescription)"
                }
            }
        }
    }

    private func updateUserName() {
        guard !name.isEmpty else {
            errorMessage = "Name darf nicht leer sein."
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        MainPageAPI.updateUserName(name: name) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    successMessage = "Name erfolgreich aktualisiert."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                case .failure(let error):
                    if let nsError = error as NSError?, nsError.code == 423 {
                        errorMessage = nsError.localizedDescription
                    } else {
                        errorMessage = "Ein Fehler ist aufgetreten: \(error.localizedDescription)"
                    }

                }
            }
        }
    }
}

struct MainPage_ProfilView_Name_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainPage_ProfilView_Name()
        }
    }
}
