import SwiftUI

struct TranslationSheetView: View {
    @Environment(\.dismiss) var dismiss // Zum Schließen des Sheets
    @State private var lang2: String = "EN" // Standardmäßig ausgewählte Sprache
    
    // Id der Sitzung
    var meetingId: UUID
    
    // Sprache der Sitzung, die in eine andere Sprache übersetzt werden soll (wird beim View-Aufruf übergeben)
    var lang1: String
    
    // ViewModel
    @StateObject private var recordManager = RecordManager()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Sprache auswählen")) {
                    // Picker, um die Zielsprache auszuwählen
                    Picker("Sprache", selection: $lang2) {
                        ForEach(LanguageManager.getLanguages(), id: \.code) { language in
                            Text(language.name).tag(language.code) // Hier wird das Kürzel gespeichert
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                // Button, der die Übersetzung bestätigt
                button
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
    
    private var button: some View {
        Button(action: {
            recordManager.translateRecordMeetingLang(meetingId: meetingId, lang1: lang1, lang2: lang2) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Record erfolgreich übersetzt")
                    case .failure(let error):
                        print("Fehler beim Übersetzen: \(error.localizedDescription)")
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
}
