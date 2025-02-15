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

//
//  MeetingDetailsView.swift
//  iOS Protokolle
//
//  Created by Christian Heller on 19.11.24.
//

import SwiftUI

struct MeetingDetailsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Kopfbereich
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Button(action: {
                            // Aktion für den Zurück-Knopf
                        }) {
                            HStack {
                                //NavigationLink(destination: ProtokollView()) {
                        Image(systemName: "chevron.left")
                                        .foregroundColor(.blue)
                                    Text("Zurück")
                                        .foregroundColor(.blue)
                                //}
                            }
                        }
                        Spacer()
                        Text("21.01.2024")
                            .font(.headline)
                            .bold()
                        Spacer()
                            Button(action: {
                                // Navigation zu MeetingDetailsView
                            }) {
                                //NavigationLink(destination: MarkdownEditorView()) {
                                HStack {
                                    Text("Editor")
                                        .foregroundColor(.blue)
                                //}
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(radius: 2)

                // Körperbereich (scrollbar)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Titel und Uhrzeit
                        Text("Jahreshauptversammlung")
                            .font(.title)
                            .bold()

                        HStack {
                            HStack(spacing: 4) {
                                Text("18:06")
                                Text("(ca. 160 min.)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "person.3.fill")
                                Text("8/12")
                            }
                        }

                        // Adresse und Ortsbeschreibung
                        Text("""
                        In der alten Turnhalle hinter dem Friedhof
                        Altes Grab 5 b, 42069 Hölle
                        """)
                        .font(.body)

                        // Organisation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Organisation")
                                .font(.footnote)
                                .foregroundColor(.gray)

                            VStack(spacing: 0) {
                                // Box 1
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Heinz-Peters")
                                            .font(.body)
                                        Text("Sitzungsleiter")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)

                                Divider() // Trennlinie

                                // Box 2
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Franz")
                                            .font(.body)
                                        Text("Protokollant")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                        }

                        // Protokoll
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Protokoll:")
                                .font(.headline)

                            Text("")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color(.systemGray6)) // Hellgrauer Hintergrund
            }
            .navigationBarTitle("21.01.2024", displayMode: .inline)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
//                        NavigationLink(destination: MarkdownEditorView()) {
//                            Text("Editor")
//                        }
                    }
                }
            }
        }
    }
}


