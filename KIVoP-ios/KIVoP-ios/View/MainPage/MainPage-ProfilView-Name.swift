import SwiftUI

struct MainPage_ProfilView_Name: View {
    @State private var name: String = "Max Mustermann"
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 10)
            HStack {
                Text("Dein Name: ")
                    .font(.headline)
                    .foregroundColor(Color.primary)
                TextField("", text: $name)
                    .font(.headline)
                    .foregroundColor(Color.primary)
                    .padding(5)
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(5)
                Spacer()
            }
            .padding(10)
            .background(Color(UIColor.systemBackground).opacity(0.8))
            .cornerRadius(10)
            .padding(.horizontal)

            Button(action: {
                // Action for save button
            }) {
                Text("Speichern")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Name", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // Standard-Zurück-Button ausblenden
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Zurück zur vorherigen Ansicht
                }) {
                    HStack {
                        Image(systemName: "chevron.backward") // Pfeil-Symbol für Zurück-Button
                        Text("Profil") // Dein gewünschter Text
                    }
                }
            }
        }
    }
}

struct MainPage_ProfilView_Name_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainPage_ProfilView_Name()
        }
    }
}
