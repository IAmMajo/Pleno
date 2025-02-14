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
import Foundation

struct MarkdownEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Bool Variable: Steuert den Bearbeitungsmodus
    @State private var isEditing: Bool = false
    
    // Angezeigter markdownText: Zunächst leer, wird mit API-Aufruf befüllt
    @State private var markdownText: String = ""
    
    // Variablen für AI-Service
    @State private var isTranslationSheetPresented = false // Zustand für das Sheet
    @State private var isExtendSheetPresented = false // Zustand für das AI-Feature
    @State private var isSocialPostSheetPresented = false
    
    // Variable für den Zustand des Protokolls: standardmäßig auf "underway"
    @State private var recordStatus: RecordStatus = .underway
    
    // ID der Sitzung, wird beim View-Aufruf übergeben
    var meetingId: UUID

    // Sprache des Protokolls: wird benötigt um das Protokoll vom Server zu holen
    var lang: String
    
    // ViewModel
    @StateObject private var recordManager = RecordManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    VStack {
                        // In Abhängigkeit von isEditing wird der Texteditor aktiviert
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
                    
                    // wenn ein Protokoll noch nicht eingereicht wurde und der Bearbeitungsmodus deaktiviert ist, wird der Button zum Einreichen angezeigt
                    if (recordStatus == .underway && isEditing == false) {
                        submitButton
                        
                    // Wenn das Protokoll eingereicht wurde und der Bearbeitungsmodus deaktiviert ist, wird der Button zum veröffentlichen angezeigt
                    } else if (recordStatus == .submitted && isEditing == false){
                        approveButton
                    }
                }
                .background(Color(.systemGray6)) // Hellgrauer Hintergrund
                .animation(.easeInOut, value: isEditing) // Animation bei Statuswechsel
            }
            .toolbar {
                // Löschen
                ToolbarItem(placement: .navigationBarTrailing) {
                    deleteButton
                }
                // Übersetzen-Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    translateButton
                }
                // Speichern
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
                // Bearbeiten
                ToolbarItem(placement: .navigationBarTrailing) {
                    editButton
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
        // Sheet zum Übersetzen
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

extension MarkdownEditorView{
    // Button zum Einreichen
    private var submitButton: some View {
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
    }
    // Button zum Veröffentlichen
    private var approveButton: some View {
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
    
    // Button zum löschen
    private var deleteButton: some View {
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
    
    // Button, um den Bearbeitungsmodus zu togglen
    private var editButton: some View {
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
    
    // Button, um die Änderungen zu speichern
    private var saveButton: some View {
        Button(action: {
            if isEditing{
                saveRecord()
            }
            isEditing.toggle() // Umschalten zwischen Bearbeiten und Speichern
        }) {
            Text(isEditing ? "Speichern" : "Bearbeiten")
        }
    }
    
    // Button, um das Translation-Sheet aufzurufen
    private var translateButton: some View {
        Button(action: {
            isTranslationSheetPresented.toggle()
        }) {
            Image(systemName: "globe") // Symbol für Übersetzung (Weltkugel)
                .foregroundColor(.blue) // Blaue Farbe für das Symbol
        }
    }
}





