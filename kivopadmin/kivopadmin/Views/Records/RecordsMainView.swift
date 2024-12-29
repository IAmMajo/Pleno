//
//  ProtokollView.swift
//  iOS Protokolle
//
//  Created by Christian Heller on 18.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct RecordsMainView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Kopfbereich mit Zurück-Button, Überschrift und Suchfeld
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Protokolle")
                        .font(.largeTitle)
                        .bold()
                        .padding(.leading)
                    
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Text("Suchen")
                                .foregroundColor(.gray)
                            Spacer()
                            Button(action: {
                                // Mikrofon-Aktion
                            }) {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .shadow(radius: 2)
                    }
                }
                
                // Scrollbare Liste mit hellgrauem Hintergrund
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                    // Aktuelle Sitzung
                    Text("Aktuelle Sitzung")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.leading)
                    
                    Button(action: {
                        // Aktion für aktuellen Button
                    }) {
                        NavigationLink(destination: MeetingDetailsView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Jahresversammlung")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("21.01.2024")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                    }
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
                        
                        
                        // Gruppe: Januar - 2024
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Januar - 2024")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.leading)
                            
                            VStack(spacing: 0) {
                                // Erste Zeile
                                Button(action: {
                                    // Aktion für Sitzung 1
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Sitzungs-Titel")
                                                .font(.body)
                                                .foregroundColor(.black)
                                            Text("14.01.2024")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                }
                                .cornerRadius(12, corners: [.topLeft, .topRight])
                                
                                Divider() // Trennlinie
                                    .padding(.horizontal)
                                
                                // Letzte Zeile
                                Button(action: {
                                    // Aktion für Sitzung 2
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Sitzungs-Titel")
                                                .font(.body)
                                                .foregroundColor(.black)
                                            Text("07.01.2024")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                }
                                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                        }
                        .padding(.horizontal) // Abstand zum Bildschirmrand
                        
                        // Gruppe: Dezember - 2023
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dezember - 2023")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.leading)
                            
                            VStack(spacing: 0) {
                                // Erste Zeile
                                Button(action: {
                                    // Aktion für Sitzung 1
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Sitzungs-Titel")
                                                .font(.body)
                                                .foregroundColor(.black)
                                            Text("22.12.2023")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                }
                                .cornerRadius(12, corners: [.topLeft, .topRight])
                                
                                Divider() // Trennlinie
                                    .padding(.horizontal)
                                
                                // Zweite Zeile
                                Button(action: {
                                    // Aktion für Sitzung 2
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Sitzungs-Titel")
                                                .font(.body)
                                                .foregroundColor(.black)
                                            Text("12.12.2023")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                }
                                
                                Divider() // Trennlinie
                                    .padding(.horizontal)
                                
                                // Letzte Zeile
                                Button(action: {
                                    // Aktion für Sitzung 3
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Sitzungs-Titel")
                                                .font(.body)
                                                .foregroundColor(.black)
                                            Text("03.12.2023")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                }
                                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                        }
                        .padding(.horizontal) // Abstand zum Bildschirmrand
                    }
                }
                .background(Color(.systemGray6)) // Hellgrauer Hintergrund
            }
            //.navigationTitle("Protokolle")
            //.toolbarBackground(Color.white, for: .navigationBar)
            //.toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// Erweiterung für Corner Radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ProtokolleView_Previews: PreviewProvider {
    static var previews: some View {
        RecordsMainView()
    }
}
