import SwiftUI

struct Onboarding_Register: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 40)
                
                // Register title
                ZStack(alignment: .bottom) {
                    Text("Registrieren")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)

                    Rectangle()
                        .frame(width: 103, height: 3)
                        .foregroundColor(.primary)
                        .offset(y: 5) // Abstand nach unten
                }
                .padding(.bottom, 40)
                .padding(.top, 40)
                
                // Profile picture placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(Text("Profilbild").foregroundColor(.gray))
                

                NavigationLink(destination: MainPage_ProfilView_ProfilPicture()) {
                    Text("Bearbeiten")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                .padding(.bottom, 30)
                
                // Name TextField
                VStack(alignment: .leading, spacing: 5) {
                    Text("NAME")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 5)
                    
                    TextField("Name", text: $name)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                // Email TextField
                VStack(alignment: .leading, spacing: 5) {
                    Text("E-MAIL")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 5)
                    
                    TextField("E-Mail", text: $email)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                // Password TextField
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
                
                // Register Button
                NavigationLink(destination: Onboarding_Wait()) {
                    Text("Registrieren")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                // Back to Login Button
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
        }
    }
}

struct Onboarding_Register_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_Register()
            .environment(\.colorScheme, .light) // Preview in Light Mode
        Onboarding_Register()
            .environment(\.colorScheme, .dark) // Preview in Dark Mode
    }
}
