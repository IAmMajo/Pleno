import SwiftUI
import MeetingServiceDTOs

struct MeetingRecordsView: View {
    var meeting: GetMeetingDTO
    @StateObject private var recordManager = RecordManager() // RecordManager als StateObject
    
    var body: some View {
        NavigationStack {
            List {
                if recordManager.isLoading {
                    ProgressView("Lade Protokolle...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = recordManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if recordManager.records.isEmpty {
                    Text("No records available.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(recordManager.records, id: \.lang) { record in
                        NavigationLink(destination: MarkdownEditorView(meetingId: record.meetingId, lang: record.lang)) {
                            Text("Protokoll: \(getLanguage(langCode: record.lang))")
                        }
                    }
                }
            }
            .navigationTitle("Protokolle zu \(meeting.name)")
        }
        .onAppear(){
            recordManager.getRecordsMeeting(meetingId: meeting.id)
        }
    }

    private func getLanguage(langCode: String) -> String {
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


        // Suche nach dem Kürzel und gib den Namen zurück
        if let language = languages.first(where: { $0.code == langCode }) {
            return language.name
        }

        // Standardwert, falls das Kürzel nicht gefunden wird
        return langCode
    }
}
