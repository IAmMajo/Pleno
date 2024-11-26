import SwiftUI

struct MainPage: View {
    @State private var Name: String = "Max Mustermann"
    @State private var ShortName: String = "V"
    @State private var Meeting: String = "Jahreshauptversammlung"
    @State private var selectedView: SidebarOption = .nutzerverwaltung
    @State private var isAdminExpanded: Bool = true

    
    private var User: String {
        Name.components(separatedBy: " ").first ?? ""
    }
    
    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Seitenleiste
                VStack(alignment: .leading, spacing: 0) {
                    // Begrüßungsbereich
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hallo Admin, \(User)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                        
                        HStack {
                            Text("Adminbereich")
                                .font(.caption)
                                .bold()
                                .foregroundColor(Color.secondary)
                            
                            Spacer()
                            
                            Button(action: {
                                isAdminExpanded.toggle()
                            }) {
                                Image(systemName: isAdminExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    
                    // Einklappbarer Adminbereich
                    if isAdminExpanded {
                        // Bereich für "Vereinseinstellungen"
                        Button(action: {
                            selectedView = .vereinseinstellungen
                        }) {
                            HStack(spacing: 15) {
                                Circle()
                                    .fill(Color.gray.opacity(0.8))
                                    .frame(width: 50, height: 50)
                                    .overlay(Text(ShortName).foregroundColor(.white).font(.caption))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Vereinseinstellungen")
                                        .font(.headline)
                                        .foregroundColor(Color.primary)
                                    Text("Übersicht und Verwaltung")
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .foregroundColor(Color.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: selectedView == .vereinseinstellungen ? "chevron.down" : "chevron.right")
                                    .foregroundColor(Color.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground)) // Hintergrund für Dark- und Light-Mode
                            .cornerRadius(15)
                            .padding(.bottom, 10)
                        }
                        
                        // Optionen in der Seitenleiste
                        VStack(alignment: .leading, spacing: 15) {
                            Button(action: {
                                selectedView = .nutzerverwaltung
                            }) {
                                HStack(alignment: .center, spacing: 15) {
                                    Image(systemName: "person.3.fill")
                                        .foregroundColor(.accentColor)
                                        .frame(width: 20)
                                    Text("Nutzerverwaltung")
                                        .foregroundColor(Color.primary)
                                    Spacer()
                                    Image(systemName: selectedView == .nutzerverwaltung ? "chevron.down" : "chevron.right")
                                        .foregroundColor(Color.secondary)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            Button(action: {
                                selectedView = .funktionen
                            }) {
                                HStack(alignment: .center, spacing: 15) {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.accentColor)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Konfiguration der Funktionen")
                                            .foregroundColor(Color.primary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    Image(systemName: selectedView == .funktionen ? "chevron.down" : "chevron.right")
                                        .foregroundColor(Color.secondary)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    // Box für Sitzung am unteren Rand
                    VStack(alignment: .leading, spacing: 10) {
                        Text(Meeting)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.white)
                            Text("21.01.2024")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("10")
                                    .foregroundColor(.white)
                                Image(systemName: "person.3")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.white)
                            Text("18:06")
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        Button(action: {
                            // Aktion für aktuelle Sitzung
                        }) {
                            Text("Zur aktuellen Sitzung")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColor.systemBackground))
                                .foregroundColor(.accentColor)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(15)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .frame(width: 320) // Feste Breite für Seitenleiste
                .background(Color(UIColor.systemBackground)) // Dynamische Hintergrundfarbe für Dark/Light Mode
                
                // Hauptanzeige rechts
                VStack {
                    switch selectedView {
                    case .vereinseinstellungen:
                        Text("Vereinseinstellungen")
                            .font(.largeTitle)
                            .padding()
                    case .nutzerverwaltung:
                        NutzerverwaltungView()
                    case .funktionen:
                        FunktionenView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground)) // Hintergrund für Dark/Light Mode
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)

    }

}

enum SidebarOption {
    case vereinseinstellungen
    case nutzerverwaltung
    case funktionen
}



// Beispielansicht für Konfiguration der Funktionen
struct FunktionenView: View {
    var body: some View {
        Text("Konfiguration der Funktionen")
            .font(.largeTitle)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
