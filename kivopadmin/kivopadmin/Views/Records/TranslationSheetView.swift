import SwiftUI

struct TranslationSheetView: View {
    @Environment(\.dismiss) var dismiss // Zum Schließen des Sheets
    @State private var lang2: String = "EN" // Standardmäßig ausgewählte Sprache
    
    var meetingId: UUID
    var lang1: String
    
    @StateObject private var recordManager = RecordManager()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Sprache auswählen")) {
                    Picker("Sprache", selection: $lang2) {
                        ForEach(LanguageManager.getLanguages(), id: \.code) { language in
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
}
