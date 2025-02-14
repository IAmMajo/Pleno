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
import MarkdownUI
import MeetingServiceDTOs

struct MarkdownEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Bool Variable für Bearbeitungsmodus
    @State private var isEditing: Bool = false
    
    // Markdown-Text, zunächst leer
    @State private var markdownText: String = ""
    
    // Bool Variable, die angibt, ob man selsbt der Protokollant ist
    @State private var amIRecorder: Bool = false
    
    // Variable, die angibt, ob das Protokoll veröffentlicht wurde
    @State private var approved: Bool = false
    
    // Variable, die angibt, ob der Bildschirm lädt
    // Wird genutzt, wenn das Protokoll noch nicht veröffentlicht wurde
    @State private var isLoading: Bool = true
    
    // Id der Sitzung wird beim View Aufruf mitgegeben
    var meetingId: UUID
    
    // Sprache des Protokolls wird beim View Aufruf mitgegeben
    var lang: String
    
    // ViewModel für die Protokolle
    @ObservedObject private var recordManager = RecordManager()

    // Variable, die für den Warte-Bildschirm genutzt wird
    @State private var isAnimating = false

    var body: some View {
        NavigationStack {
            VStack() {
                ZStack(alignment: .bottom) {
                    // Wenn alle Fetch Befehel durchgeführt wurden, wird isLoading = true gesetzt
                    // Verhinhert, das ein User das Protokoll sehen kann, obwohl er gar nicht die Berechtigung hat
                    if !isLoading {
                        // Wenn der User Protokollant ist oder das Protokoll veröffentlicht wurde, kann er den Inhalt sehen
                        if amIRecorder || approved {
                            VStack {
                                if isEditing {
                                    // Markdown-Editor aktiv
                                    editorView
                                } else {
                                    // Markdown gerendert anzeigen
                                    textView
                                }
                            }
                        } else {
                            ScrollView{
                                // Lade-View, falls das Protokoll nicht angezeigt wird
                                waitingView
                            }.refreshable {
                                Task {
                                    updateView()
                                }
                            }

                        }
                    }
                    // Wenn der User Protokollant ist und der Bearbeitungsmodus deaktiviert ist, kann das Protokoll eingereicht werden
                    // sonst ist der Button nicht sichtbar
                    if (amIRecorder && (isEditing == false)) {
                        submitButton
                    }
                    

                }
                .animation(.easeInOut, value: isEditing) // Animation bei Statuswechsel
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if amIRecorder {
                        editButton
                    }
                }
            }
            .refreshable {
                updateView()
            }
        }
        .onAppear {
            updateView()
        }

    }
    
    private func updateView() {
        Task {
            // Protokoll laden
            await recordManager.getRecordMeetingLang(meetingId: meetingId, lang: lang)
            
            try? await Task.sleep(nanoseconds: 250_000_000)

            if let record = recordManager.record {
                // Inhalt des Protokolls auslesen
                markdownText = record.content
                
                // Protokollanten-Variable auslesen
                amIRecorder = record.iAmTheRecorder
                
                // Status des Protokolls auslesen
                if record.status == .approved {
                    approved = true
                }
            }
            isLoading = false
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

extension MarkdownEditorView {
    private var waitingView: some View {
        VStack(spacing: 20) {
            
             // Animiertes Symbol (z. B. ein sich drehender Kreis)
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20) // Größe des Kreises
                .scaleEffect(isAnimating ? 1.2 : 0.8) // Skalierung der Animation
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )

             // Text
             Text("Das Protokoll wurde noch nicht veröffentlicht.")
                 .font(.headline)
                 .foregroundColor(.gray)
         }.onAppear {
             isAnimating = true // Animation starten, wenn die View erscheint
         }
         .offset(y: 200)
    }
    
    // Hier wird gerendertes Markdown angezeigt
    private var textView: some View {
        ScrollView {
            Markdown(markdownText)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }
    
    // Editor Ansicht
    private var editorView: some View {
        TextEditor(text: $markdownText)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding()
            .shadow(radius: 2)
    }
    
    // Button zum Einreichen
    private var submitButton: some View {
        Button(action: {
            recordManager.submitRecordMeetingLang(meetingId: meetingId, lang: lang) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Record erfolgreich veröffentlicht")
                        
                    case .failure(let error):
                        print("Fehler beim Veröffentlichen: \(error.localizedDescription)")
                        
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
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal)
        }
        .padding(.bottom, 16)
    }
    
    // Button zum Editieren
    // Togglet die Variable isEditing
    private var editButton: some View {
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
