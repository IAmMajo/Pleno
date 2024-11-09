//
//  Onboarding.swift
//  KIVoP-ios
//
//  Created by Amine Ahamri on 07.11.24.
//

import SwiftUI

struct Onboarding: View {
    @State private var currentIndex = 0
    @State private var ClubLogo: String = "VL"
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack{
            VStack {
                Spacer()
                
                // Vereinslogo placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .overlay(Text(ClubLogo).foregroundColor(.gray))
                    .padding(.bottom, 10)
                
                if currentIndex == 0 {
                    // Erster onboarding screen
                    VStack {
                        Image("Onboarding1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                        
                        VStack(spacing: 0) {
                            Text("Mit ")
                                .font(.title3)
                                .fontWeight(.regular) +
                            Text("KIVoP ")
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
                    // Zweiter onboarding screen
                    VStack {
                        Image("Onboarding2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                        
                        VStack {
                            Text("Verwalte ")
                                .font(.title3)
                                .fontWeight(.regular)
                            + Text("Ratssitzungen, ")
                                .font(.title3)
                                .fontWeight(.regular)
                                .foregroundColor(.blue)
                            + Text("erstelle ")
                                .font(.title3)
                                .fontWeight(.regular)
                            + Text("Umfragen, ")
                                .font(.title3)
                                .fontWeight(.regular)
                                .foregroundColor(.blue)
                            + Text("oder plane deine nächste ")
                                .font(.title3)
                                .fontWeight(.regular)
                            + Text("Vereinsreise...")
                                .font(.title3)
                                .fontWeight(.regular)
                                .foregroundColor(.blue)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        
                        Spacer().frame(height: 20)
                    }
                }
                
                Spacer()
                
                // Seiten indikator
                HStack(spacing: 8) {
                    Circle()
                        .fill(currentIndex == 0 ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                    
                    Circle()
                        .fill(currentIndex == 1 ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .padding(.bottom, 20)
                
                // Navigation buttons
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
                        // Aktion
                    }) {
                        NavigationLink(destination: Onboarding_Login()) {
                            Text("Einführung überspringen")
                                .foregroundColor(.gray)
                                .font(.footnote)
                                .underline()
                        }}
                    .padding(.bottom, 20)
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 && currentIndex < 1 {
                            // Swipe links nach vorne
                            withAnimation {
                                currentIndex += 1
                            }
                        } else if value.translation.width > 50 && currentIndex > 0 {
                            // Swipe rechts nach hinten
                            withAnimation {
                                currentIndex -= 1
                            }
                        }
                    }
            )
            .navigationDestination(isPresented: $navigateToLogin) {
                Onboarding_Login()
            }
        } .navigationBarBackButtonHidden(true)
    }

}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding()
    }
}
