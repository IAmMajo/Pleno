import SwiftUI

struct CurrentMeeting: View {
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading){
                VStack {
                    Text("Jahreshauptversammlung")
                        .font(.title) // Setzt die Schriftgröße auf groß
                        .fontWeight(.bold) // Macht den Text fett
                        .foregroundColor(.primary) // Setzt die Farbe auf die primäre Farbe des Themas
                        .padding()
                } // Fügt etwas Abstand um den Text hinzu
                HStack{
                    Text("18:06 Uhr")
                    Text("(ca. 160 min.)")
                        .font(.caption) // Kleiner Schriftgrad
                        .foregroundColor(.gray) // Graue Farbe
                    Spacer()
                    HStack(spacing: 4) { // kleiner Abstand zwischen dem Symbol und der Personenanzahl
                        Image(systemName: "person.3.fill") // Symbol für eine Gruppe von Personen
                        Text("9/12")
                    }
                }.padding(.horizontal)
                List {
                    // Adresse
                    Section(header: Text("Adresse")) {
                        Text("In der alten Turnhalle hinter dem Friedhof, Altes Grab 5 b, 42069 Hölle")
                    }
                    
                    // Organiation
                    Section(header: Text("Organisation")) {
                        HStack{
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                            VStack(alignment: .leading) {
                                Text("Heinz-Peters")
                                Text("Sitzungsleiter")
                                    .font(.caption) // Kleiner Schriftgrad
                                    .foregroundColor(.gray) // Graue Farbe
                            }
                        }
                    }
                    
                    // Agenda
                    Section(header: Text("Agenda")) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                Text("•").bold()
                                Text("Vorsitzende wählen")
                            }
                            HStack(alignment: .top) {
                                Text("•").bold()
                                Text("Langweiliger Orga-Punkt")
                            }
                            HStack(alignment: .top) {
                                Text("•").bold()
                                Text("Glühwein")
                            }
                            HStack(alignment: .top) {
                                Text("•").bold()
                                Text("Bla")
                            }
                            HStack(alignment: .top) {
                                Text("•").bold()
                                Text("Abschied")
                            }
                        }
                    }
                    
                    // Sitzung
                    Section(header: Text("Sitzung")) {
                        NavigationLink(destination: PlaceholderView()) {
                            Text("Anwesenheit")
                        }
                    }
                }
            }.toolbar { // Toolbar hinzufügen
                ToolbarItem(placement: .navigationBarTrailing) { // Position auf der rechten Seite
                    Text("21.01.2024")
                }
            }
                
            
        }

    }
}


#Preview {
    CurrentMeeting()
}
