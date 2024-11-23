import SwiftUI
import AuthServiceDTOs


struct Onboarding_Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 40)
                
                // Login title
                ZStack(alignment: .bottom) {
                    Text("Login")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)

                    Rectangle()
                        .frame(width: 103, height: 3)
                        .foregroundColor(.primary)
                        .offset(y: 5)
                }
                .padding(.bottom, 40)
                .padding(.top, 40)
                
                // Email TextField
                VStack(alignment: .leading, spacing: 5) {
                    Text("E-MAIL")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                        .padding(.horizontal, 5)
                    
                    TextField("E-Mail", text: $email)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                // Password TextField
                VStack(alignment: .leading, spacing: 5) {
                    Text("PASSWORT")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                        .padding(.horizontal, 5)
                    
                    SecureField("Passwort", text: $password)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                Spacer()
                
                // Login Button
                Button(action: {
                    loginUser()
                }) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal, 24)
                }
                
                // Register Button
                NavigationLink(destination: Onboarding_Register()) {
                    Text("Registrieren")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color(UIColor.systemGray5))
                        .fontWeight(.bold)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                
                // Back Button
                NavigationLink(destination: Onboarding()) {
                    Text("Zurück")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .underline()
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                Spacer().frame(height: 20)
            }
            .background(Color(UIColor.systemGray6))
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func loginUser() {
        // Set loading state
        isLoading = true
        errorMessage = nil
        
        // Create UserLoginDTO
        let loginDTO = UserLoginDTO(email: email, password: password)
        
        // Define API endpoint
        let url = URL(string: "https://kivop.ipv64.net/auth/login")!
        
        // Create POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode DTO to JSON
        do {
            let jsonData = try JSONEncoder().encode(loginDTO)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Fehler beim Verarbeiten der Daten."
            isLoading = false
            return
        }
        
        // Perform API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Netzwerkfehler: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    errorMessage = "Ungültige Anmeldedaten."
                    return
                }
                
                guard let data = data else {
                    errorMessage = "Keine Daten vom Server."
                    return
                }
                
                // Decode JWT token
                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponseDTO.self, from: data)
                    if let token = tokenResponse.token {
                        // Speichern des Tokens (z. B. im UserDefaults)
                        UserDefaults.standard.set(token, forKey: "jwtToken")
                        // Weiterleitung zur MainPage
                        errorMessage = nil
                    } else {
                        errorMessage = "Ungültige Antwort vom Server."
                    }
                } catch {
                    errorMessage = "Fehler beim Verarbeiten der Serverantwort."
                }
            }
        }.resume()
    }
}


struct Onboarding_Login_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_Login()
            .environment(\.colorScheme, .light) // Preview in Light Mode
        Onboarding_Login()
            .environment(\.colorScheme, .dark) // Preview in Dark Mode
    }
}
