import SwiftUI

struct MainPage: View {
    @State private var Name: String = "Max Mustermann"
    @State private var ShortName: String = "MM"
    @State private var Meeting: String = "Jahreshauptversammlung"
    private var User: String {
        Name.components(separatedBy: " ").first ?? ""
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Greeting
                Text("Hallo, \(User)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                    .padding([.top, .leading], 20)
                
                // Profile Information
                NavigationLink(destination: MainPage_ProfilView()) {
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)
                            .overlay(Text(ShortName).foregroundColor(.white))
                        
                        VStack(alignment: .leading) {
                            Text(Name)
                                .font(.headline)
                                .foregroundColor(Color.primary)
                            Text("Profil und Vereinsinformationen")
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(15)
                    .padding(.horizontal,10)
                    .padding(10)
                }
                
                // Options in einer Liste
                List {
                    // Einzeloption Sitzungen
                    Section {
                       NavigationLink(destination: KIVoP_ios.Meeting()) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.accentColor)
                                Text("Sitzungen")
                                    .foregroundColor(Color.primary)
                            }
                        }
                    }
                    
                    // Zusätzliche Optionen
                    Section {
                        NavigationLink(destination: Votings()) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(.accentColor)
                                Text("Abstimmungen")
                                    .foregroundColor(Color.primary)
                            }
                        }
                        
                        NavigationLink(destination: ProtokolleView()) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.accentColor)
                                Text("Protokolle")
                                    .foregroundColor(Color.primary)
                            }
                        }
                        
                        NavigationLink(destination: AnwesenheitView()) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                    .foregroundColor(.accentColor)
                                Text("Anwesenheit")
                                    .foregroundColor(Color.primary)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color.clear)
                .padding(.top, -10)
                
                Spacer()
                
                // Meeting Box
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
                        .padding(.trailing, 10)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.white)
                        Text("18:06")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    Button(action: {
                        // Aktion für aktuelles Meeting
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
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true) // Verstecken von navigation bar und back button
        }
    }
}

// Sample Views für die anderen Punkte nach hinzufügen bitte löschen!!!

struct ProtokolleView: View {
    var body: some View {
        Text("Protokolle")
            .font(.largeTitle)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
