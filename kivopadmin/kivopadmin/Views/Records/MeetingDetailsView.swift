import SwiftUI

struct MeetingDetailsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Kopfbereich

                // Körperbereich (scrollbar)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        TitleSection()
                        AddressSection()
                        OrganizationSection()
                        ProtocolSection()
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
//                    NavigationLink(destination: MarkdownEditorView()) {
//                        Text("Editor")
//                    }
                }
            }
        }
    }
}

// Unterkomponenten

struct TitleSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
        }
    }
}

struct AddressSection: View {
    var body: some View {
        Text("""
        In der alten Turnhalle hinter dem Friedhof
        Altes Grab 5 b, 42069 Hölle
        """)
        .font(.body)
    }
}

struct OrganizationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Organisation")
                .font(.footnote)
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                OrganizationBox(name: "Heinz-Peters", role: "Sitzungsleiter")
                Divider()
                OrganizationBox(name: "Franz", role: "Protokollant")
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 1)
        }
    }
}

struct OrganizationBox: View {
    let name: String
    let role: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.body)
                Text(role)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

struct ProtocolSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Protokoll:")
                .font(.headline)

            Text("")
                .font(.body)
                .multilineTextAlignment(.leading)
        }
    }
}

// Vorschau

struct MeetingDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingDetailsView()
    }
}
