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
                // Ladeanzeige
                ProgressView("Laden...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Spacer()
                    .frame(height: 10)

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
            fetchUserName()
        }
    }

    // MARK: - API-Logik

    private func fetchUserName() {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://kivop.ipv64.net/users/profile") else {
            errorMessage = "Ungültige URL."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Fehler: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    errorMessage = "Profil konnte nicht geladen werden."
                    return
                }

                guard let data = data else {
                    errorMessage = "Keine Daten vom Server."
                    return
                }

                do {
                    let profile = try JSONDecoder().decode(UserProfileDTO.self, from: data)
                    self.name = profile.name ?? ""
                } catch {
                    errorMessage = "Fehler beim Verarbeiten der Daten."
                }
            }
        }.resume()
    }

    private func updateUserName() {
        guard !name.isEmpty else {
            errorMessage = "Name darf nicht leer sein."
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        // URL für die API-Route
        guard let url = URL(string: "https://kivop.ipv64.net/users/identity") else {
            errorMessage = "Ungültige URL."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        // Payload erstellen
        let updateDTO = UserProfileUpdateDTO(name: name)
        do {
            request.httpBody = try JSONEncoder().encode(updateDTO)
        } catch {
            errorMessage = "Fehler beim Erstellen der Anfrage."
            isLoading = false
            return
        }

        // Anfrage senden
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Fehler: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    errorMessage = "Aktualisierung fehlgeschlagen."
                    return
                }

                successMessage = "Name erfolgreich aktualisiert."
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }.resume()
    }
}

struct MainPage_ProfilView_Name_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainPage_ProfilView_Name()
        }
    }
}
