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
    @State private var currentIndex = 0
    @State private var ClubLogo: String = "VL"
    @State private var navigateToLogin = false
    @State private var hasCheckedOnboarding = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    var isManualNavigation: Bool = false // Neuer Parameter
    @Binding var isLoggedIn: Bool




    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // Vereinslogo placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(Text(ClubLogo).foregroundColor(.gray))
                    .padding(.bottom, 10)
                
                if currentIndex == 0 {
                    // Erster Onboarding-Bildschirm
                    VStack {
                        Image("onboarding2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                        
                        VStack(spacing: 0) {
                            Text("Mit")
                                .font(.title3)
                                .fontWeight(.regular) +
                            Text(" ")
                                .font(.title3)
                                .fontWeight(.regular) +
                            Text("Pleno")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue) +
                            Text(" ")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue) +
                            Text("zu einer verbesserten")
                                .font(.title3)
                                .fontWeight(.regular) +
                            Text(" ")
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
                    // Zweiter Onboarding-Bildschirm
                    VStack {
                        Image("onboarding1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                        
                        VStack {
                            Text("Verwalte")
                                .font(.title3)
                                .fontWeight(.regular)
                            + Text(" ")
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
                            + Text("Vereinsreise...")
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
                
                // Seitenindikator
                HStack(spacing: 8) {
                    Circle()
                        .fill(currentIndex == 0 ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                    
                    Circle()
                        .fill(currentIndex == 1 ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .padding(.bottom, 20)
                
                // Navigationsbuttons
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
                                // Flag um zu Login weiterleiten
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
                    Button(action: {
                        // Onboarding überspringen
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
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 && currentIndex < 1 {
                            // Swipe nach links
                            withAnimation {
                                currentIndex += 1
                            }
                        } else if value.translation.width > 50 && currentIndex > 0 {
                            // Swipe nach rechts
                            withAnimation {
                                currentIndex -= 1
                            }
                        }
                    }
            )
            .navigationDestination(isPresented: $navigateToLogin) {
                Onboarding_Login(isLoggedIn: $isLoggedIn)
            }

        }
        .onAppear {
            // Nur automatisch zur LoginView navigieren, wenn dies nicht manuell aufgerufen wurde
            if hasSeenOnboarding && !isManualNavigation {
                navigateToLogin = true
            }
        }


        .navigationBarBackButtonHidden(true)
    }
}

/*struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding()
    }
}
*/
