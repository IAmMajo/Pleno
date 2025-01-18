//
//  MarkdownEditorView.swift
//  iOS Protokolle
//
//  Created by Christian Heller on 25.11.24.
//

import SwiftUI
import MarkdownUI
import MeetingServiceDTOs

struct MarkdownEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing: Bool = false
    @State private var markdownText: String = ""
    
    @State private var amIRecorder: Bool = false
    
    var meetingId: UUID
    var lang: String
    
    @ObservedObject private var recordManager = RecordManager()
    @StateObject private var identityManager = IdentityManager()

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
                        Text("Einreichen")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(amIRecorder ? Color.blue : Color.gray)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .disabled(!amIRecorder)
                    .padding(.bottom, 16)
                }
                .background(Color(.systemGray6)) // Hellgrauer Hintergrund
                .animation(.easeInOut, value: isEditing) // Animation bei Statuswechsel
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isEditing{
                            saveRecord()
                        }
                        isEditing.toggle() // Umschalten zwischen Bearbeiten und Speichern
                    }) {
                        Text(isEditing ? "Speichern" : "Bearbeiten")
                    }.disabled(!amIRecorder)
                }
            }
        }
        .onAppear {
            identityManager.getMyIdentity()
            Task {
                await recordManager.getRecordMeetingLang(meetingId: meetingId, lang: lang)
                
                try? await Task.sleep(nanoseconds: 250_000_000)
                if let record = recordManager.record {
                    markdownText = record.content
                    print("Das ist der Text: \(markdownText)")
                    print("identityManager: \(identityManager.identity)")
                    print("recordIdentiy: \(record.identity.id)")
                    if identityManager.identity == record.identity.id {
                        amIRecorder = true
                        print("Ich bin protokollant")
                    }
                }
            }
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
