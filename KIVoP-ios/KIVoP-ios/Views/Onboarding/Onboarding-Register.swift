import SwiftUI
import AuthServiceDTOs

struct Onboarding_Register: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var registrationSuccessful: Bool = false
    @State private var selectedImage: UIImage? = nil // Für das Profilbild

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 40)
                
                // Titel
                ZStack(alignment: .bottom) {
                    Text("Registrieren")
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
                
                // Profilbild
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(Text("Profilbild").foregroundColor(.gray))
                    }
                }
                .padding(.bottom, 10)
                
                NavigationLink(destination: Onboarding_ProfilePicture(selectedImage: $selectedImage)) {
                    Text("Bearbeiten")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                .padding(.bottom, 30)
                
                // Name TextField
                inputField(title: "Name", text: $name)
                
                // Email TextField
                inputField(title: "E-Mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                // Passwort TextField
                VStack(alignment: .leading, spacing: 5) {
                    Text("PASSWORT")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 5)
                        .padding(.top)
                    
                    VStack(spacing: 0) {
                        SecureField("Neues Passwort", text: $password)
                            .padding()
                            .background(Color(UIColor.systemBackground))
                        
                        Divider()
                            .frame(height: 0.5)
                            .background(Color.gray.opacity(0.6))
                            .padding(.horizontal, 10)
                        
                        SecureField("Passwort wiederholen", text: $confirmPassword)
                            .padding()
                            .background(Color(UIColor.systemBackground))
                    }
                    .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                Spacer()
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal, 24)
                }
                
                // Register Button
                Button(action: {
                    registerUser()
                }) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Registrieren")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                
                // Zurück zu Login Button
                NavigationLink(destination: Onboarding_Login()) {
                    Text("Zurück zum Login")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(10)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                Spacer().frame(height: 20)
            }
            .background(Color(UIColor.systemGray6))
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $registrationSuccessful) {
                Onboarding_Wait(email: $email)
            }

        }
    }
    
    private func registerUser() {
        isLoading = true
        errorMessage = nil
        
        guard validatePassword(password) else {
            errorMessage = "Passwort muss mindestens 8 Zeichen, eine Zahl und ein Sonderzeichen enthalten."
            isLoading = false
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwörter stimmen nicht überein."
            isLoading = false
            return
        }
        
        // Bild komprimieren und skalieren
        let profileImageData = selectedImage.flatMap { compressImage($0) }
        
        // DTO erstellen
        let registrationDTO = UserRegistrationDTO(
            name: name,
            email: email,
            password: password,
            profileImage: profileImageData
        )
        
        // JSON Encoding und Payload-Größe messen
        do {
            let jsonData = try JSONEncoder().encode(registrationDTO)
            let sizeInMB = Double(jsonData.count) / (1024 * 1024) // Größe in MB
            print(String(format: "Payload-Größe: %.2f MB", sizeInMB))
        } catch {
            print("Fehler beim Encoding der JSON-Daten: \(error.localizedDescription)")
            errorMessage = "Fehler beim Verarbeiten der Daten."
            isLoading = false
            return
        }
    
        

        
        // Registrierung durchführen
        OnboardingAPI.registerUser(with: registrationDTO) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    saveCredentialsToKeychain()
                    registrationSuccessful = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    
    private func validatePassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$&*]).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return predicate.evaluate(with: password)
    }

    private func saveCredentialsToKeychain() {
        KeychainHelper.save(key: "email", value: email)
        KeychainHelper.save(key: "password", value: password)
    }
    
    private func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 5)
            
            TextField(title, text: text)
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }
    
    private func compressImage(_ image: UIImage) -> Data? {
        let targetSize = CGSize(width: 200, height: 200) // Zielgröße für das Profilbild
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        // Bild auf Zielgröße skalieren
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        // Komprimieren mit dynamischer Qualität
        var compressionQuality: CGFloat = 0.9 // Startqualität
        var compressedData = resizedImage.jpegData(compressionQuality: compressionQuality)
        
        // Schleife zur weiteren Komprimierung, bis die Datei klein genug ist (< 200 KB z. B.)
        while let data = compressedData, data.count > 200 * 1024 && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            compressedData = resizedImage.jpegData(compressionQuality: compressionQuality)
        }
        
        return compressedData
    }

}


struct Onboarding_Register_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_Register()
            .environment(\.colorScheme, .light)
        Onboarding_Register()
            .environment(\.colorScheme, .dark)
    }
}
