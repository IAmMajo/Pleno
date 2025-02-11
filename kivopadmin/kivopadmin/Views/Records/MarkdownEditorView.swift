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
                    
                    if (recordStatus == .underway && isEditing == false) {
                        submitButton
                    } else if (recordStatus == .submitted && isEditing == false){
                        approveButton
                    }
                }
                .background(Color(.systemGray6)) // Hellgrauer Hintergrund
                .animation(.easeInOut, value: isEditing) // Animation bei Statuswechsel
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    deleteButton
                }
                // Übersetzen-Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    translateButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
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
    
    private var translateButton: some View {
        Button(action: {
            isTranslationSheetPresented.toggle()
        }) {
            Image(systemName: "globe") // Symbol für Übersetzung (Weltkugel)
                .foregroundColor(.blue) // Blaue Farbe für das Symbol
        }
    }
}





