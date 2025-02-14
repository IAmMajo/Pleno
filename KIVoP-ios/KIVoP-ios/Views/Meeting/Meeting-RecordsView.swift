// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import SwiftUI
import MeetingServiceDTOs

// Auswahl View auf welches Protokoll der User geleitet werden möchte
struct MeetingRecordsView: View {
    // Sitzung wird mitgeliefert
    var meeting: GetMeetingDTO
    
    // RecordManager als ViewModel
    @StateObject private var recordManager = RecordManager()
    
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
                    Text("Keine Protokolle verfügbar.")
                        .foregroundColor(.secondary)
                // Wenn viewmodel geladen hat
                } else {
                    ForEach(recordManager.records, id: \.lang) { record in
                        // Link zum Markdown Editor wo das Protokoll ggf. angeschaut werden kann
                        NavigationLink(destination: MarkdownEditorView(meetingId: record.meetingId, lang: record.lang)) {
                            Text("Protokoll: \(LanguageManager.getLanguage(langCode: record.lang))")
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
}
