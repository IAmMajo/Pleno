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
    @State private var approved: Bool = false
    @State private var isLoading: Bool = true
    
    var meetingId: UUID
    var lang: String
    
    @ObservedObject private var recordManager = RecordManager()
    @StateObject private var identityManager = IdentityManager()
    @State private var isAnimating = false

    var body: some View {
        NavigationStack {
            VStack() {
                ZStack(alignment: .bottom) {
                    if !isLoading {
                        if amIRecorder || approved {
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
                        } else {
                            ScrollView{
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
                            }.refreshable {
                                identityManager.getMyIdentity()
                                Task {
                                    await recordManager.getRecordMeetingLang(meetingId: meetingId, lang: lang)
                                    
                                    try? await Task.sleep(nanoseconds: 250_000_000)

                                    if let record = recordManager.record {
                                        markdownText = record.content
                                        if record.status == .approved {
                                            approved = true
                                        }
                                        if identityManager.identity == record.identity.id {
                                            if record.status == .underway {
                                                amIRecorder = true
                                                print("Ich bin protokollant")
                                            }

                                        }
                                    }
                                    isLoading = false
                                }
                            }

                        }
                    }



                    if amIRecorder {
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
                        .padding(.bottom, 16)
                    }
                    

                }
                .animation(.easeInOut, value: isEditing) // Animation bei Statuswechsel
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if amIRecorder {
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
            .refreshable {
                identityManager.getMyIdentity()
                Task {
                    await recordManager.getRecordMeetingLang(meetingId: meetingId, lang: lang)
                    
                    try? await Task.sleep(nanoseconds: 250_000_000)

                    if let record = recordManager.record {
                        markdownText = record.content
                        if record.status == .approved {
                            approved = true
                        }
                        if identityManager.identity == record.identity.id {
                            if record.status == .underway {
                                amIRecorder = true
                                print("Ich bin protokollant")
                            }

                        }
                    }
                    isLoading = false
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
                    if record.status == .approved {
                        approved = true
                    }
                    if identityManager.identity == record.identity.id {
                        if record.status == .underway {
                            amIRecorder = true
                            print("Ich bin protokollant")
                        }

                    }
                }
                isLoading = false
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
