import SwiftUI
import MarkdownUI
import MeetingServiceDTOs
import Foundation

struct MarkdownEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing: Bool = false
    @State private var markdownText: String = ""
    @State private var isTranslationSheetPresented = false // Zustand für das Sheet
    @State private var isExtendSheetPresented = false // Zustand für das AI-Feature
    @State private var isSocialPostSheetPresented = false


    @State private var recordStatus: RecordStatus = .underway


    
    var meetingId: UUID
    var lang: String
    
    @StateObject private var recordManager = RecordManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    VStack {
                        if isEditing {
                            // Markdown-Editor aktiv
                            TextEditor(text: $markdownText)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding()
                                .shadow(radius: 2)
                        } else {
                            // Markdown gerendert anzeigen
                            ScrollView {
                                Markdown(markdownText)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding()
                        }
                    }

                    if recordStatus == .underway {
                        Button(action: {
                            // Aktion für den Zustand "underway"
                            recordManager.submitRecordMeetingLang(meetingId: meetingId, lang: lang) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        print("Record erfolgreich eingereicht")
                                        // Hier kannst du das UI aktualisieren
                                    case .failure(let error):
                                        print("Fehler beim Einreichen: \(error.localizedDescription)")
                                        // Fehler behandeln
                                    }
                                }
                            }
                            
                            dismiss()
                        }) {
                            Text("Einreichen")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 16)
                    } else if recordStatus == .submitted {
                        Button(action: {
                            // Aktion für den Zustand "submitted"
                            recordManager.approveRecordMeetingLang(meetingId: meetingId, lang: lang) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        print("Record erfolgreich veröffentlicht")
                                        // Hier kannst du das UI aktualisieren
                                    case .failure(let error):
                                        print("Fehler beim Veröffentlichen: \(error.localizedDescription)")
                                        // Fehler behandeln
                                    }
                                }
                            }
                            
                            dismiss()
                        }) {
                            Text("Veröffentlichen")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 16)
                    }
                    // Wenn `recordStatus` einen anderen Wert hat, wird nichts angezeigt.

                }
                .background(Color(.systemGray6)) // Hellgrauer Hintergrund
                .animation(.easeInOut, value: isEditing) // Animation bei Statuswechsel
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        recordManager.deleteRecordMeetingLang(meetingId: meetingId, lang: lang) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success:
                                    print("Record erfolgreich gelöscht")
                                    // Hier kannst du das UI aktualisieren
                                case .failure(let error):
                                    print("Fehler beim Löschen: \(error.localizedDescription)")
                                    // Fehler behandeln
                                }
                            }
                        }

                        dismiss()
                    }) {
                        Image(systemName: "trash") // Symbol der Mülltonne
                            .foregroundColor(.red) // Rote Farbe für das Symbol
                    }
                }
                // Übersetzen-Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isTranslationSheetPresented.toggle()
                    }) {
                        Image(systemName: "globe") // Symbol für Übersetzung (Weltkugel)
                            .foregroundColor(.blue) // Blaue Farbe für das Symbol
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isEditing{
                            saveRecord()
                        }
                        isEditing.toggle() // Umschalten zwischen Bearbeiten und Speichern
                    }) {
                        Text(isEditing ? "Speichern" : "Bearbeiten")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                                    if isEditing {
                                        Button(action: {
                                            isExtendSheetPresented.toggle()
                                        }) {
                                            Image(systemName: "wand.and.stars")
                                                .foregroundColor(.blue)
                                        }
                                    } else {
                                        Button(action: {
                                            isSocialPostSheetPresented.toggle()
                                        }) {
                                            Image(systemName: "square.and.arrow.up")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
            }
            .sheet(isPresented: $isExtendSheetPresented) {
                ExtendRecordView(markdownText: $markdownText, lang: lang)
            }
            .sheet(isPresented: $isSocialPostSheetPresented) {
                            SocialMediaPostView(markdownText: markdownText, lang: lang)
                        }
        }
        .onAppear {
            
            Task {
                await recordManager.getRecordMeetingLang(meetingId: meetingId, lang: lang)
                try? await Task.sleep(nanoseconds: 250_000_000)
                if let record = recordManager.record {
                    markdownText = record.content
                    print("Das ist der Text: \(markdownText)")
                    recordStatus = record.status
                }
                
            }
        }
        .sheet(isPresented: $isTranslationSheetPresented) {
            TranslationSheetView(meetingId: meetingId, lang1: lang) // Ansicht für das Sheet
        }
    }

    // Speichern der Änderungen
    private func saveRecord() {
        Task {
            let patchDTO = PatchRecordDTO(content: markdownText)
            await recordManager.patchRecordMeetingLang(patchRecordDTO: patchDTO, meetingId: meetingId, lang: lang)
        }
    }
}

struct TranslationSheetView: View {
    @Environment(\.dismiss) var dismiss // Zum Schließen des Sheets
    @State private var lang2: String = "EN" // Standardmäßig ausgewählte Sprache
    
    var meetingId: UUID
    var lang1: String
    
    //@State private var languages: [String] = []
    let manager = LanguageManager()
    
    @StateObject private var recordManager = RecordManager()
    
    private var languages: [(name: String, code: String)] {
        let languages: [(name: String, code: String)] = [
            ("Arabisch", "ar"),
            ("Chinesisch", "zh"),
            ("Dänisch", "da"),
            ("Deutsch", "de"),
            ("Englisch", "en"),
            ("Französisch", "fr"),
            ("Griechisch", "el"),
            ("Hindi", "hi"),
            ("Italienisch", "it"),
            ("Japanisch", "ja"),
            ("Koreanisch", "ko"),
            ("Niederländisch", "nl"),
            ("Norwegisch", "no"),
            ("Polnisch", "pl"),
            ("Portugiesisch", "pt"),
            ("Rumänisch", "ro"), // Hinzugefügt
            ("Russisch", "ru"),
            ("Schwedisch", "sv"),
            ("Spanisch", "es"),
            ("Thai", "th"), // Hinzugefügt
            ("Türkisch", "tr"),
            ("Ungarisch", "hu")
        ]
        return languages
    }


    
    //lazy var languages: [String] = Self.generateLanguages()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Sprache auswählen")) {
                    Picker("Sprache", selection: $lang2) {
                        ForEach(languages, id: \.code) { language in
                            Text(language.name).tag(language.code) // Hier wird das Kürzel gespeichert
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Button(action: {
                    recordManager.translateRecordMeetingLang(meetingId: meetingId, lang1: lang1, lang2: lang2) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                print("Record erfolgreich übersetzt")
                                // Hier kannst du das UI aktualisieren
                            case .failure(let error):
                                print("Fehler beim Übersetzen: \(error.localizedDescription)")
                                // Fehler behandeln
                            }
                        }
                    }

                    dismiss()
                }) {
                    Text("Übersetzen")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Übersetzen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss() // Sheet schließen
                    }
                }
            }
        }
    }
//    private func loadLanguages() {
//        // Hole die lokalisierten Sprachcodes aus dem Bundle
//        if let bundleLocalizations = Bundle.main.localizations as? [String] {
//            // Optional: Sortiere und entferne nicht relevante Lokalisierungen
//            languages = bundleLocalizations.filter { $0 != "Base" }.sorted()
//        }
//        
//    }
    
//    static func generateLanguages() -> [String] {
//        // Hole alle verfügbaren Lokalisierungen
//        let appLocalizations = Bundle.main.localizations
//        
//        // Filtere eindeutige Sprachcodes
//        let allLocales = Locale.availableIdentifiers
//        let uniqueLanguages = Set(
//            allLocales.compactMap { identifier in
//                Locale(identifier: identifier).language.languageCode.identifier
//            }
//        )
//        
//        // Unterstützte Sprachen mit der App-Lokalisierung abgleichen
//        let supportedLanguages = appLocalizations.filter { uniqueLanguages.contains($0) }
//        return supportedLanguages.map { $0.uppercased() }
//    }
}


struct ExtendRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var markdownText: String
    @State private var aiGeneratedText: String = "" // Unformatierter KI-Text
    @State private var formattedText: String = "" // Formatierter KI-Text
    @State private var userEditedText: String = "" // Bearbeiteter Text
    @State private var isLoading = true
    @State private var isEditing = false // Bearbeitungsmodus
    var lang: String

    var body: some View {
        VStack(spacing: 20) {
            // **Titel-Leiste mit Zurück & Speichern**
            HStack {
                if isEditing {
                    Button("Zurück") {
                        isEditing = false
                        userEditedText = aiGeneratedText
                        formattedText = formatMarkdown(aiGeneratedText)
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
                Text("KI-generierte Verbesserung")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Button(action: {
                    isEditing.toggle()
                    if !isEditing {
                        aiGeneratedText = userEditedText
                        formattedText = formatMarkdown(userEditedText)
                    }
                }) {
                    HStack {
                        if isEditing {
                            Text("Speichern")
                                .font(.system(size: 18))
                        } else {
                            Image(systemName: "pencil")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .frame(height: 44)

            HStack(spacing: 20) {
                VStack {
                    Text("Originaltext")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    TextEditor(text: $markdownText)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 300)
                        .cornerRadius(8)
                        .border(Color.gray, width: 1)
                }
                VStack {
                    Text("KI-Vorschlag")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    if isLoading {
                        TextEditor(text: $aiGeneratedText)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .background(Color.white)
                            .cornerRadius(8)
                            .border(Color.gray, width: 1)
                    } else if isEditing {
                        TextEditor(text: $userEditedText)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 300)
                            .background(Color.white)
                            .cornerRadius(8)
                            .border(Color.gray, width: 1)
                    } else {
                        ScrollView {
                            Markdown(formattedText)
                                .markdownTheme(.basic)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                        .border(Color.gray, width: 1)
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            Spacer()
            HStack(spacing: 15) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Verwerfen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    markdownText = formattedText
                    dismiss()
                }) {
                    Text("Übernehmen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .frame(minWidth: 1200, maxWidth: 2800)
        .task {
            await fetchExtendedRecord()
        }
    }

    private func fetchExtendedRecord() async {
        isLoading = true
        aiGeneratedText = ""

        await RecordsAPI.extendRecord(content: markdownText, lang: lang) { chunk in
            DispatchQueue.main.async {
                aiGeneratedText += chunk + "\n"
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Finaler AI-Text:\n\(aiGeneratedText)")
            formattedText = formatMarkdown(aiGeneratedText)
            userEditedText = aiGeneratedText
            isLoading = false
        }
    }

    private func formatMarkdown(_ text: String) -> String {
        var formattedText = text
        formattedText = formattedText.replacingOccurrences(of: "### ", with: "\n### ")
        formattedText = formattedText.replacingOccurrences(of: "## ", with: "\n## ")
        //formattedText = formattedText.replacingOccurrences(of: "# ", with: "\n# ")
        formattedText = formattedText.replacingOccurrences(of: "- ", with: "\n- ")
        formattedText = formattedText.replacingOccurrences(of: "---", with: "\n\n—\n\n")
        formattedText = formattedText.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        return formattedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}



struct SocialMediaPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var socialMediaText: String = ""
    @State private var isLoading = true
    var markdownText: String
    var lang: String

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Text(socialMediaText.isEmpty ? "Lade Social-Media-Post..." : removeMarkdownSyntax(from: socialMediaText))
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: sharePost) {
                    Label("Teilen", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .task {
                await fetchSocialMediaPost()
            }
            .navigationTitle("Generierter Social-Media-Post") // **Mittiger Titel**
            .navigationBarTitleDisplayMode(.inline) // **Sorgt für eine perfekte zentrierte Darstellung**
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func fetchSocialMediaPost() async {
        isLoading = true
        socialMediaText = ""
        
        await RecordsAPI.generateSocialMediaPost(content: markdownText, lang: lang) { chunk in
            DispatchQueue.main.async {
                socialMediaText += chunk + " "
            }
        }
        
        isLoading = false
    }
    
    private func sharePost() {
        let activityController = UIActivityViewController(activityItems: [socialMediaText], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true, completion: nil)
        }
    }
    
    private func removeMarkdownSyntax(from text: String) -> String {
        var cleanedText = text

        // **Markdown entfernen**
        cleanedText = cleanedText.replacingOccurrences(of: "# ", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "## ", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "### ", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "**", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "*", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "- ", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "---", with: "")
        cleanedText = cleanedText.replacingOccurrences(of: "—", with: "")
        cleanedText = cleanedText.trimmingCharacters(in: CharacterSet(charactersIn: "\"“”„"))

        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}




