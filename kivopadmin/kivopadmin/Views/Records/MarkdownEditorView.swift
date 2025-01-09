import SwiftUI
import MarkdownUI
import MeetingServiceDTOs

struct MarkdownEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing: Bool = false
    @State private var markdownText: String = ""
    @State private var isTranslationSheetPresented = false // Zustand für das Sheet

    
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

                    Button(action: {
                        recordManager.submitRecordMeetingLang(meetingId: meetingId, lang: lang) { result in
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
            }
        }
        .onAppear {
            Task {
                await recordManager.getRecordMeetingLang(meetingId: meetingId, lang: lang)
                try? await Task.sleep(nanoseconds: 250_000_000)
                if let record = recordManager.record {
                    markdownText = record.content
                    print("Das ist der Text: \(markdownText)")
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
    @State private var lang2: String = "DE" // Standardmäßig ausgewählte Sprache
    
    var meetingId: UUID
    var lang1: String
    
    @StateObject private var recordManager = RecordManager()
    
    let languages = ["DE", "EN", "FR", "ES"] // Unterstützte Sprachen

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Sprache auswählen")) {
                    Picker("Sprache", selection: $lang2) {
                        ForEach(languages, id: \.self) { language in
                            Text(language)
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
}

