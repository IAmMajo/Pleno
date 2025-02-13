// This file is licensed under the MIT-0 License.
import SwiftUI
import AuthServiceDTOs

struct Onboarding_Register: View {
    // Zustandsvariablen für Benutzereingaben
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    // Zustandsvariablen für Validierungsnachrichten
    @State private var passwordValidationMessage: String = ""
    @State private var confirmPasswordMessage: String = ""

    // Weitere UI-Steuerungsvariablen
    @State private var isLoading: Bool = false
    @State private var showPrivacyPolicy: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var navigateToWaitingView: Bool = false

    // Verweist auf den Anmeldestatus der App
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 40)

                // Titel für die Registrierungsseite
                Text("Registrieren")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                    .padding(.top, 40)

                // Sektion zur Anzeige und Auswahl eines Profilbilds
                profileImageSection()

                // Eingabefelder für Name, E-Mail und Passwörter
                inputField(title: "Name", text: $name)
                inputField(title: "E-Mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                passwordField()
                confirmPasswordField()

                Spacer()

                // Button zur Registrierung, öffnet zunächst die Datenschutzerklärung
                Button(action: {
                    showPrivacyPolicy.toggle()
                }) {
                    if isLoading {
                        ProgressView()
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Registrieren")
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || !passwordValidationMessage.isEmpty || !confirmPasswordMessage.isEmpty)

                // Navigationslink zum Login-Bildschirm
                NavigationLink(destination: Onboarding_Login(isLoggedIn: $isLoggedIn)) {
                    Text("Zurück zum Login")
                        .foregroundColor(.blue)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(10)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGray6))
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)

            // Sheet zur Anzeige der Datenschutzerklärung
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView(
                    onAccept: {
                        registerUser()
                        showPrivacyPolicy = false
                    },
                    onCancel: {
                        showPrivacyPolicy = false
                    }
                )
            }

            // Falls Registrierung erfolgreich, zur Warteansicht navigieren
            .navigationDestination(isPresented: $navigateToWaitingView) {
                Onboarding_Wait(email: $email)
            }
        }
    }

    // MARK: - Passwortfeld mit Validierung
    private func passwordField() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("PASSWORT")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 5)

            SecureField("Neues Passwort", text: $password)
                .onChange(of: password) {
                    validatePassword()
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(password.isEmpty ? Color.clear : (passwordValidationMessage.isEmpty ? Color.green : Color.red), lineWidth: 2)
                )

            if !password.isEmpty && !passwordValidationMessage.isEmpty {
                Text(passwordValidationMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 5)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }

    // MARK: - Bestätigungspasswortfeld mit Validierung
    private func confirmPasswordField() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("PASSWORT WIEDERHOLEN")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 5)

            SecureField("Passwort wiederholen", text: $confirmPassword)
                .onChange(of: confirmPassword) {
                    validateConfirmPassword()
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(confirmPassword.isEmpty ? Color.clear : (confirmPasswordMessage.isEmpty ? Color.green : Color.red), lineWidth: 2)
                )

            if !confirmPassword.isEmpty && !confirmPasswordMessage.isEmpty {
                Text(confirmPasswordMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 5)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }

    // MARK: - Validierung des Passworts
    private func validatePassword() {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)

        if predicate.evaluate(with: password) {
            passwordValidationMessage = ""
        } else {
            passwordValidationMessage = "Mind. 8 Zeichen, 1 Zahl, 1 Sonderzeichen."
        }
    }

    // MARK: - Überprüfung, ob die Passwörter übereinstimmen
    private func validateConfirmPassword() {
        if confirmPassword == password {
            confirmPasswordMessage = ""
        } else {
            confirmPasswordMessage = "Passwörter stimmen nicht überein."
        }
    }

    // MARK: - Registrierungsprozess starten
    private func registerUser() {
        isLoading = true

        let registrationDTO = UserRegistrationDTO(
            name: name,
            email: email,
            password: password,
            profileImage: selectedImage.flatMap { compressImage($0) }
        )

        OnboardingAPI.registerUser(with: registrationDTO) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    saveCredentialsToKeychain(email: email, password: password)
                    navigateToWaitingView = true
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Eingabefeld-Komponente für wiederverwendbare Texteingaben
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

    // MARK: - Profilbild-Sektion mit "Bearbeiten"-Link
    private func profileImageSection() -> some View {
        VStack {
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
            .padding(.bottom, 5)

            NavigationLink(destination: Onboarding_ProfilePicture(selectedImage: $selectedImage)) {
                Text("Bearbeiten")
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .underline()
            }
        }
        .padding(.vertical, 10)
    }
}

    
    private func compressImage(_ image: UIImage) -> Data? {
        let targetSize = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        var compressionQuality: CGFloat = 0.8
        var compressedData = resizedImage.jpegData(compressionQuality: compressionQuality)

        while let data = compressedData, data.count > 200 * 1024 && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            compressedData = resizedImage.jpegData(compressionQuality: compressionQuality)
        }

        return compressedData
    }
    
    
    private func saveCredentialsToKeychain(email: String, password: String) {
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

struct PrivacyPolicyView: View {
    let onAccept: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                Text("Datenschutzerklärung")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("1. Datenschutz auf einen Blick")
                            .font(.headline)
                            .bold()
                            .padding(.vertical, 8)

                        Text("""
                        **Allgemeine Hinweise**
                        Die folgenden Hinweise geben einen einfachen Überblick darüber, was mit Ihren personenbezogenen Daten passiert, wenn Sie die App ,,Pleno” nutzen. Personenbezogene Daten sind alle Daten, mit denen Sie persönlich identifiziert werden können. Ausführliche Informationen zum Thema Datenschutz entnehmen Sie unserer unter diesem Text aufgeführten Datenschutzerklärung.

                        **Datenerfassung in dieser App**

                        **Wer ist verantwortlich für die Datenerfassung auf dieser Website?**
                        Die Datenverarbeitung in der App erfolgt durch uns als Betreiber. Unsere Kontaktdaten finden Sie im Abschnitt, Hinweis zur Verantwortlichen Stell’ dieser Datenschutzerklärung. 

                        **Wie erfassen wir Ihre Daten?**

                        Ihre Daten werden zum einen dadurch erhoben, dass Sie uns diese mitteilen, z. B. durch die Eingabe in das Nutzerprofil. Andere Daten werden automatisch oder nach Ihrer Einwilligung bei der Nutzung der App durch IT-Systeme erfasst. Das sind vor allem technische Daten (z. B. Gerätetyp, Betriebssystem oder Uhrzeit des Zugriffs).

                        **Wofür nutzen wir Ihre Daten?**
                        Ein Teil der Daten wird erhoben, um eine fehlerfreie Bereitstellung der App zu gewährleisten. Andere Daten werden erfasst, um die organisatorischen Funktionen der App zu ermöglichen. Dies umfasst:

                        - **Den Namen des Vereins und dessen Logo:** Diese Informationen dienen der Identifikation und Zuordnung innerhalb der App.
                        - **Ort und Zeit von Veranstaltungen oder Treffen:** Diese Daten sind notwendig, um die Terminplanung und das bilden von Fahrgemeinschaften zwischen Vereinsmitgliedern zu gewährleisten.
                        - **Rollen und Aufgaben der Mitglieder:** Diese werden erfasst, um die Strukturierung und Aufgabenverteilung innerhalb des Vereins zu unterstützen.
                        - **Hochgeladene Inhalte wie Protokolle oder Dokumente:** Diese Informationen dienen der Archivierung und Verfügbarkeit von Sitzungsunterlagen.

                        Diese Daten sind erforderlich, um die Funktionen der App bereitzustellen und eine effiziente Nutzung der Plattform zu ermöglichen.

                        **Welche Rechte haben Sie bezüglich Ihrer Daten?**
                        Sie haben jederzeit das Recht, unentgeltlich Auskunft über Herkunft, Empfänger und Zweck Ihrer gespeicherten personenbezogenen Daten zu erhalten. Sie haben außerdem ein Recht, die Berichtigung oder Löschung dieser Daten zu verlangen. Wenn Sie eine Einwilligung zur Datenverarbeitung erteilt haben, können Sie diese Einwilligung jederzeit für die Zukunft widerrufen. Außerdem haben Sie das Recht, unter bestimmten Umständen die Einschränkung der Verarbeitung Ihrer personenbezogenen Daten zu verlangen. Des Weiteren steht Ihnen ein Beschwerderecht bei der zuständigen Aufsichtsbehörde zu. Hierzu sowie zu weiteren Fragen zum Thema Datenschutz können Sie sich jederzeit an uns wenden.
                        """)

                        Text("2. Hosting")
                            .font(.headline)
                            .bold()
                            .padding(.vertical, 8)

                        Text("""
                        Wir hosten die Inhalte unserer Website bei folgendem Anbieter:

                        **Hetzner**

                        Anbieter ist die Hetzner Online GmbH, Industriestr. 25, 91710 Gunzenhausen (nachfolgend Hetzner).

                        Details entnehmen Sie der Datenschutzerklärung von Hetzner:
                        https://www.hetzner.com/de/legal/privacy-policy/.

                        Die Verwendung von Hetzner erfolgt auf Grundlage von Art. 6 Abs. 1 lit. f DSGVO. Wir haben ein berechtigtes Interesse an einer möglichst zuverlässigen Darstellung unserer Website. Sofern eine entsprechende Einwilligung abgefragt wurde, erfolgt die Verarbeitung ausschließlich auf Grundlage von Art.6 Abs. 1 lit. a DSGVO und § 25 Abs. 1 TDDDG, soweit die Einwilligung die Speicherung von Cookies oder den Zugriff auf Informationen im Endgerät des Nutzers (z. B. Device-Fingerprinting) im Sinne des TDDDG umfasst. Die Einwilligung ist jederzeit widerrufbar.

                        **Auftragsverarbeitung**
                        Wir haben einen Vertrag über Auftragsverarbeitung (AVV) zur Nutzung des oben genannten Dienstes geschlossen. Hierbei handelt es sich um einen datenschutzrechtlich vorgeschriebenen Vertrag, der gewährleistet, dass dieser die personenbezogenen Daten unserer Websitebesucher nur nach unseren Weisungen und unter Einhaltung der DSGVO verarbeitet.
                        """)

                        Text("3. Allgemeine Hinweise und Pflichtinformationen")
                            .font(.headline)
                            .bold()
                            .padding(.vertical, 8)

                        Text("""
                        **Datenschutz**

                        Die Betreiber dieser App nehmen den Schutz Ihrer persönlichen Daten sehr ernst. Wir behandeln Ihre personenbezogenen Daten vertraulich und entsprechend den gesetzlichen Datenschutzvorschriften sowie dieser Datenschutzerklärung.

                        Wenn Sie diese App benutzen, werden verschiedene personenbezogene Daten erhoben. Personenbezogene Daten sind Daten, mit denen Sie persönlich identifiziert werden können. Die vorliegende Datenschutzerklärung erläutert, welche Daten wir erheben und wofür wir sie nutzen. Sie erläutert auch, wie und zu welchem Zweck das geschieht.

                        Wir weisen darauf hin, dass die Datenübertragung im Internet (z. B. bei der Kommunikation per E-Mail) Sicherheitslücken aufweisen kann. Ein lückenloser Schutz der Daten vor dem Zugriff durch Dritte ist nicht möglich.
                        
                        **Hinweis zur verantwortlichen Stelle**

                        Die verantwortliche Stelle für die Datenverarbeitung auf dieser App ist:

                        Esther Lukeba
                        Blumenmann Straße 17
                        53842 Troisdorf
                        Telefon: 022418667509
                        E-Mail: Esther.lukeba[@hsrw.org](mailto:lennart-luis.guggenberger@hsrw.org)

                        Verantwortliche Stelle ist die natürliche oder juristische Person, die allein oder gemeinsam mit anderen über die Zwecke und Mittel der Verarbeitung von personenbezogenen Daten (z. B. Namen, E-Mail-Adressen o. Ä.) entscheidet.

                        **Speicherdauer**

                        Soweit innerhalb dieser Datenschutzerklärung keine speziellere Speicherdauer genannt wurde, verbleiben Ihre personenbezogenen Daten bei uns, bis der Zweck für die Datenverarbeitung entfällt. Wenn Sie ein berechtigtes Löschersuchen geltend machen oder eine Einwilligung zur Datenverarbeitung widerrufen, werden Ihre personenbezogenen Daten, wie beispielsweise E-Mail-Adresse, Telefonnummer und Profilbild, gelöscht.

                        Um jedoch die Vollständigkeit und Nachvollziehbarkeit der Meeting-Protokolle zu gewährleisten, bleibt die Identität der betreffenden Person (z. B. Name und Rolle) in diesen Protokollen erhalten. Dies dient der Authentizität und Integrität der Dokumentation. Die übrigen personenbezogenen Daten werden unwiderruflich entfernt, sofern keine anderen rechtlich zulässigen Gründe für die Speicherung vorliegen (z. B. steuer- oder handelsrechtliche Aufbewahrungsfristen). Im letztgenannten Fall erfolgt die Löschung nach Fortfall dieser Gründe.

                        **Allgemeine Hinweise zu den Rechtsgrundlagen der Datenverarbeitung auf dieser Website**

                        Sofern Sie in die Datenverarbeitung eingewilligt haben, verarbeiten wir Ihre personenbezogenen Daten auf Grundlage von Art. 6 Abs. 1 lit. a DSGVO bzw. Art. 9 Abs. 2 lit. a DSGVO, sofern besondere Datenkategorien nach Art. 9 Abs. 1 DSGVO verarbeitet werden. Im Falle einer ausdrücklichen Einwilligung in die Übertragung personenbezogener Daten in Drittstaaten erfolgt die Datenverarbeitung außerdem auf Grundlage von Art. 49 Abs. 1 lit. a DSGVO. Sofern Sie in die Speicherung von Cookies oder in den Zugriff auf Informationen in Ihr Endgerät (z. B. via Device-Fingerprinting) eingewilligt haben, erfolgt die Datenverarbeitung zusätzlich auf Grundlage von § 25 Abs. 1 TDDDG. Die Einwilligung ist jederzeit widerrufbar. Sind Ihre Daten zur Vertragserfüllung oder zur Durchführung vorvertraglicher Maßnahmen erforderlich, verarbeiten wir Ihre Daten auf Grundlage des Art. 6 Abs. 1 lit. b DSGVO. Des Weiteren verarbeiten wir Ihre Daten, sofern diese
                        zur Erfüllung einer rechtlichen Verpflichtung erforderlich sind auf Grundlage von Art. 6 Abs. 1 lit. c DSGVO. Die Datenverarbeitung kann ferner auf Grundlage unseres berechtigten Interesses nach Art. 6 Abs. 1 lit. f DSGVO erfolgen. Über die jeweils im Einzelfall einschlägigen Rechtsgrundlagen wird in den folgenden Absätzen dieser Datenschutzerklärung informiert.

                        **Widerruf Ihrer Einwilligung zur Datenverarbeitung**
                        Viele Datenverarbeitungsvorgänge sind nur mit Ihrer ausdrücklichen Einwilligung möglich. Sie können eine bereits erteilte Einwilligung jederzeit widerrufen. Die Rechtmäßigkeit der bis zum Widerruf erfolgten Datenverarbeitung bleibt vom Widerruf unberührt.

                        **Widerspruchsrecht gegen die Datenerhebung in besonderen Fällen sowie gegen
                        Direktwerbung (Art. 21 DSGVO)**
                        WENN DIE DATENVERARBEITUNG AUF GRUNDLAGE VON ART. 6 ABS. 1 LIT. E ODER F DSGVO ERFOLGT, HABEN SIE JEDERZEIT DAS RECHT, AUS GRÜNDEN, DIE SICH AUS IHRER BESONDEREN SITUATION ERGEBEN, GEGEN DIE VERARBEITUNG IHRER PERSONENBEZOGENEN DATEN WIDERSPRUCH EINZULEGEN; DIES GILT AUCH FÜR EIN AUF DIESE BESTIMMUNGEN GESTÜTZTES PROFILING. DIE JEWEILIGE RECHTSGRUNDLAGE, AUF DENEN EINE VERARBEITUNG BERUHT, ENTNEHMEN SIE DIESER DATENSCHUTZERKLÄRUNG. WENN SIE WIDERSPRUCH EINLEGEN, WERDEN WIR IHRE BETROFFENEN PERSONENBEZOGENEN DATEN NICHT MEHR VERARBEITEN, ES SEI DENN, WIR KÖNNEN ZWINGENDE SCHUTZWÜRDIGE GRÜNDE FÜR DIE VERARBEITUNG NACHWEISEN, DIE IHRE INTERESSEN, RECHTE UND FREIHEITEN ÜBERWIEGEN ODER DIE VERARBEITUNG DIENT DER GELTENDMACHUNG, AUSÜBUNG ODER VERTEIDIGUNG VON
                        RECHTSANSPRÜCHEN (WIDERSPRUCH NACH ART. 21 ABS. 1 DSGVO). WERDEN IHRE PERSONENBEZOGENEN DATEN VERARBEITET, UM DIREKTWERBUNG ZU BETREIBEN, SO HABEN SIE DAS RECHT, JEDERZEIT WIDERSPRUCH GEGEN DIE VERARBEITUNG SIE BETREFFENDER PERSONENBEZOGENER DATEN ZUM ZWECKE DERARTIGER WERBUNG EINZULEGEN; DIES GILT AUCH FÜR DAS PROFILING, SOWEIT ES MIT SOLCHER DIREKTWERBUNG IN VERBINDUNG STEHT. WENN SIE WIDERSPRECHEN, WERDEN IHRE PERSONENBEZOGENEN DATEN ANSCHLIESSEND NICHT MEHR ZUM ZWECKE DER DIREKTWERBUNG VERWENDET (WIDERSPRUCH NACH ART. 21 ABS. 2 DSGVO).

                        **Beschwerderecht bei der zuständigen Aufsichtsbehörde**
                        Im Falle von Verstößen gegen die DSGVO steht den Betroffenen ein Beschwerderecht bei einer
                        Aufsichtsbehörde, insbesondere in dem Mitgliedstaat ihres gewöhnlichen Aufenthalts, ihres Arbeitsplatzes oder des Orts des mutmaßlichen Verstoßes zu. Das Beschwerderecht besteht unbeschadet anderweitiger verwaltungsrechtlicher oder gerichtlicher Rechtsbehelfe.

                        **Recht auf Datenübertragbarkeit**
                        Sie haben das Recht, Daten, die wir auf Grundlage Ihrer Einwilligung oder in Erfüllung eines Vertrags
                        automatisiert verarbeiten, an sich oder an einen Dritten in einem gängigen, maschinenlesbaren Format aushändigen zu lassen. Sofern Sie die direkte Übertragung der Daten an einen anderen Verantwortlichen verlangen, erfolgt dies nur, soweit es technisch machbar ist.

                        **Auskunft, Berichtigung und Löschung**
                        Sie haben im Rahmen der geltenden gesetzlichen Bestimmungen jederzeit das Recht auf unentgeltliche Auskunft über Ihre gespeicherten personenbezogenen Daten, deren Herkunft und Empfänger und den Zweck der Datenverarbeitung und ggf. ein Recht auf Berichtigung oder Löschung dieser Daten. Hierzu sowie zu weiteren Fragen zum Thema personenbezogene Daten können Sie sich jederzeit an uns wenden.

                        **Recht auf Einschränkung der Verarbeitung**
                        Sie haben das Recht, die Einschränkung der Verarbeitung Ihrer personenbezogenen Daten zu verlangen. Hierzu können Sie sich jederzeit an uns wenden. Das Recht auf Einschränkung der Verarbeitung besteht in folgenden Fällen:

                        - Wenn Sie die Richtigkeit Ihrer bei uns gespeicherten personenbezogenen Daten bestreiten, benötigen wir in der Regel Zeit, um dies zu überprüfen. Für die Dauer der Prüfung haben Sie das Recht, die Einschränkung der Verarbeitung Ihrer personenbezogenen Daten zu verlangen.
                        - Wenn die Verarbeitung Ihrer personenbezogenen Daten unrechtmäßig geschah/geschieht, können Sie statt der Löschung die Einschränkung der Datenverarbeitung verlangen.
                        - Wenn wir Ihre personenbezogenen Daten nicht mehr benötigen, Sie sie jedoch zur Ausübung, Verteidigung oder Geltendmachung von Rechtsansprüchen benötigen, haben Sie das Recht, statt der Löschung die Einschränkung der Verarbeitung Ihrer personenbezogenen Daten zu verlangen.
                        - Wenn Sie einen Widerspruch nach Art. 21 Abs. 1 DSGVO eingelegt haben, muss eine Abwägung zwischen Ihren und unseren Interessen vorgenommen werden. Solange noch nicht feststeht, wessen Interessen überwiegen, haben Sie das Recht, die Einschränkung der Verarbeitung Ihrer personenbezogenen Daten zu verlangen.
                        - Wenn Sie die Verarbeitung Ihrer personenbezogenen Daten eingeschränkt haben, dürfen diese Daten – von ihrer Speicherung abgesehen – nur mit Ihrer Einwilligung oder zur Geltendmachung, Ausübung oder Verteidigung von Rechtsansprüchen oder zum Schutz der Rechte einer anderen natürlichen oder juristischen Person oder aus Gründen eines wichtigen öffentlichen Interesses der Europäischen Union oder eines Mitgliedstaats verarbeitet werden.

                        **SSL- bzw. TLS-Verschlüsselung**

                        Diese App nutzt aus Sicherheitsgründen und zum Schutz der Übertragung vertraulicher Inhalte, wie zum Beispiel Registrierungsdaten oder Anfragen, die Sie über die App senden, eine SSL- bzw. TLS-Verschlüsselung. Eine verschlüsselte Verbindung erkennen Sie daran, dass in Ihrer App-Verbindung ein entsprechendes Sicherheitszertifikat hinterlegt ist.

                        Wenn die SSL- bzw. TLS-Verschlüsselung aktiviert ist, können die Daten, die Sie an uns übermitteln, nicht von Dritten mitgelesen werden.

                        **Widerspruch gegen Werbe-E-Mails**

                        Der Nutzung von im Rahmen der Impressumspflicht veröffentlichten Kontaktdaten zur Übersendung von nicht ausdrücklich angeforderter Werbung und Informationsmaterialien wird hiermit widersprochen. Die Betreiber der Seiten behalten sich ausdrücklich rechtliche Schritte im Falle der unverlangten Zusendung von Werbeinformationen, etwa durch Spam-E-Mails, vor.
                        """)
                        Text("4. Datenerfassung auf dieser Website")
                            .font(.headline)
                            .bold()
                            .padding(.vertical, 8)

                        Text("""
                           **Server-Log-Dateien**

                        Der Provider der Seiten erhebt und speichert automatisch Informationen in so genannten Server-Log-Dateien, die Ihr Browser automatisch an uns übermittelt. Dies sind:

                           - Browsertyp und Browserversion
                           - verwendetes Betriebssystem
                           - Referrer URL
                           - Hostname des zugreifenden Rechners
                           - Uhrzeit der Serveranfrage
                           - IP-Adresse

                        Eine Zusammenführung dieser Daten mit anderen Datenquellen wird nicht vorgenommen.
                        Die Erfassung dieser Daten erfolgt auf Grundlage von Art. 6 Abs. 1 lit. f DSGVO. Der Betreiber hat ein berechtigtes Interesse an der technisch fehlerfreien Darstellung und der Optimierung seiner Website, hierzu müssen die Server-Log-Files erfasst werden.  

                        """)
                        Text("5. Newsletter")
                            .font(.headline)
                            .bold()
                            .padding(.vertical, 8)

                        Text("""
                           **Newsletterdaten**

                        Wenn Sie den auf der App angebotenen Newsletter beziehen möchten, benötigen wir von Ihnen eine E-Mail-Adresse sowie Informationen, welche uns die Überprüfung gestatten, dass Sie der Inhaber der angegebenen E-Mail-Adresse sind und mit dem Empfang des Newsletters einverstanden sind. Weitere Daten werden nicht bzw. nur auf freiwilliger Basis erhoben. Diese Daten verwenden wir ausschließlich für den Versand der angeforderten Informationen und geben diese nicht an Dritte weiter.

                        Die Verarbeitung der in das Newsletteranmeldeformular eingegebenen Daten erfolgt ausschließlich auf Grundlage Ihrer Einwilligung (Art. 6 Abs. 1 lit. a DSGVO). Die erteilte Einwilligung zur Speicherung der Daten, der E-Mail-Adresse sowie deren Nutzung zum Versand des Newsletters können Sie jederzeit widerrufen, etwa über den „Austragen“-Link im Newsletter. Die Rechtmäßigkeit der bereits erfolgten Datenverarbeitungsvorgänge bleibt vom Widerruf unberührt.

                        Die von Ihnen zum Zwecke des Newsletter-Bezugs bei uns hinterlegten Daten werden von uns bis zu Ihrer Austragung aus dem Newsletter bei uns gespeichert und nach der Abbestellung des Newsletters oder nach Zweckfortfall aus der Newsletterverteilerliste gelöscht. Wir behalten uns vor, E-Mail-Adressen aus unserem Newsletterverteiler nach eigenem Ermessen im Rahmen unseres berechtigten Interesses nach Art. 6 Abs. 1 lit. f DSGVO zu löschen oder zu sperren.

                        Daten, die zu anderen Zwecken bei uns gespeichert wurden, bleiben hiervon unberührt.
                        """)

                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)


                HStack {
                    Button(action: onCancel) {
                        Text("Abbrechen")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: onAccept) {
                        Text("Akzeptieren")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}


//struct Onboarding_Register_Previews: PreviewProvider {
//    static var previews: some View {
//        Onboarding_Register()
//            .environment(\.colorScheme, .light)
//        Onboarding_Register()
//            .environment(\.colorScheme, .dark)
//    }
//}
