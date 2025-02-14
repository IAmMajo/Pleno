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

struct Onboarding: View {
    // Index des aktuellen Onboarding-Bildschirms
    @State private var currentIndex = 0
    // Vereinslogo als Platzhalter-Text
    @State private var ClubLogo: String = "VL"
    // Steuerung der Navigation zur Login-Ansicht
    @State private var navigateToLogin = false
    // Prüft, ob das Onboarding bereits angesehen wurde
    @State private var hasCheckedOnboarding = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    // Parameter zur manuellen Navigation (falls von außerhalb gesteuert)
    var isManualNavigation: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // Platzhalter für das Vereinslogo
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(Text(ClubLogo).foregroundColor(.gray))
                    .padding(.bottom, 10)
                
                if currentIndex == 0 {
                    // Erster Onboarding-Bildschirm mit Image und Text
                    VStack {
                        Image("onboarding2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                        
                        VStack(spacing: 0) {
                            Text("Mit ")
                                .font(.title3)
                                .fontWeight(.regular) +
                            Text("Pleno ")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue) +
                            Text("zu einer verbesserten ")
                                .font(.title3)
                                .fontWeight(.regular) +
                            Text("Vereinsplanung")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        
                        Spacer().frame(height: 20)
                    }
                } else if currentIndex == 1 {
                    // Zweiter Onboarding-Bildschirm mit Image und Beschreibung der Features
                    VStack {
                        Image("onboarding1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                        
                        VStack {
                            Text("Verwalte ")
                                .font(.title3)
                                .fontWeight(.regular)
                            + Text("Ratssitzungen, ")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            + Text("erstelle ")
                                .font(.title3)
                                .fontWeight(.regular)
                            + Text("Umfragen, ")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            + Text("oder plane deine nächste ")
                                .font(.title3)
                                .fontWeight(.regular)
                            + Text(" Vereinsreise...")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        
                        Spacer().frame(height: 20)
                    }
                }
                
                Spacer()
                
                // Indikator für die aktuelle Seite (Onboarding-Schritte)
                HStack(spacing: 8) {
                    Circle()
                        .fill(currentIndex == 0 ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                    
                    Circle()
                        .fill(currentIndex == 1 ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .padding(.bottom, 20)
                
                // Navigationsbuttons für Vor- und Zurückblättern
                HStack {
                    if currentIndex > 0 {
                        Button(action: {
                            withAnimation {
                                currentIndex -= 1
                            }
                        }) {
                            Text("Zurück")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: 44)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .fontWeight(.bold)
                        }
                    }
                    
                    if currentIndex < 1 {
                        Spacer()
                    }
                    
                    Button(action: {
                        withAnimation {
                            if currentIndex < 1 {
                                currentIndex += 1
                            } else {
                                // Falls letzter Bildschirm erreicht, Navigation zur Login-Seite
                                hasSeenOnboarding = true
                                navigateToLogin = true
                            }
                        }
                    }) {
                        Text("Weiter")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                
                if currentIndex == 0 {
                    // Möglichkeit, das Onboarding zu überspringen
                    Button(action: {
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        navigateToLogin = true
                    }) {
                        Text("Einführung überspringen")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .underline()
                    }
                    .padding(.bottom, 20)
                }
            }
            // Wischen nach links oder rechts erlaubt Navigation zwischen den Onboarding-Bildschirmen
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 && currentIndex < 1 {
                            // Wischbewegung nach links
                            withAnimation {
                                currentIndex += 1
                            }
                        } else if value.translation.width > 50 && currentIndex > 0 {
                            // Wischbewegung nach rechts
                            withAnimation {
                                currentIndex -= 1
                            }
                        }
                    }
            )
            // Navigation zur Login-Seite nach Onboarding-Abschluss
            .navigationDestination(isPresented: $navigateToLogin) {
                Onboarding_Login()
            }
        }
        .onAppear {
            // Falls das Onboarding bereits gesehen wurde, direkt zur Login-Seite weiterleiten
            if hasSeenOnboarding && !isManualNavigation {
                navigateToLogin = true
            }
        }
        // Versteckt den Zurück-Button in der Navigation
        .navigationBarBackButtonHidden(true)
    }
}

// Vorschau für das Onboarding-View
struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding()
    }
}
