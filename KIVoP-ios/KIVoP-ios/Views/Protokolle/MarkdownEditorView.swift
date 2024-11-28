//
//  MarkdownEditorView.swift
//  iOS Protokolle
//
//  Created by Christian Heller on 25.11.24.
//

import SwiftUI
import MarkdownUI

struct MarkdownEditorView: View {
    @State private var isEditing: Bool = false // Zustand des Bearbeitungsmodus
    @State private var markdownText: String = "Hier stehen Notizen für das **Protokoll** und weitere Dinge..." // Initialer Text

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Kopfbereich
//                VStack(alignment: .leading, spacing: 8) {
//                    HStack {
//                        Button(action: {
//                            // Navigation zu MeetingDetailsView
//                        }) {
//                            NavigationLink(destination: MeetingDetailsView()) {
//                                HStack {
//                                    Image(systemName: "chevron.left")
//                                        .foregroundColor(.blue)
//                                    Text("Zurück")
//                                        .foregroundColor(.blue)
//                                }
//                            }
//                        }
//                        Spacer()
//                        Text("21.01.2024")
//                            .font(.headline)
//                            .bold()
//                        Spacer()
//                        Button(action: {
//                            isEditing.toggle() // Umschalten zwischen Bearbeiten und Speichern
//                        }) {
//                            Text(isEditing ? "Speichern" : "Bearbeiten")
//                                .foregroundColor(.blue)
//                        }
//                    }
//                }
//                .padding()
//                .background(Color.white)
//                .shadow(radius: 2)

                // Körperbereich
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
                                .onAppear {
                                    // Tastatur aktivieren, falls erforderlich
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                        } else {
                            // Markdown gerendert anzeigen
                            ScrollView {
                                Markdown(markdownText) // MarkdownUI für gerenderte Anzeige
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding()
                        }
                    }

                    if !isEditing {
                        // "Veröffentlichen"-Button anzeigen, wenn nicht bearbeitet wird
                        Button(action: {
                            // Aktion für den Zurück-Knopf
                        }) {
//                            NavigationLink(destination: MeetingDetailsView()) {
                                Text("Veröffentlichen")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
//                            }
                        }
                        .padding(.bottom, 16)
                    }
                }
                .background(Color(.systemGray6)) // Hellgrauer Hintergrund
                .animation(.easeInOut, value: isEditing) // Animation bei Statuswechsel
            }
            //.navigationBarTitle("21.01.2024", displayMode: .inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    isEditing.toggle() // Umschalten zwischen Bearbeiten und Speichern
                                }) {
                                    Text(isEditing ? "Speichern" : "Bearbeiten")
                                }
                            }
                        }
        }
    }
}

struct MarkdownEditorView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownEditorView()
    }
}
