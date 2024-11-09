import SwiftUI

struct Onboarding_Wait: View {
    @State private var clubName: String = "Name des Vereins der manchmal auch sehr lange werden kann e.V."
    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 40)
            
            // Title
            ZStack(alignment: .bottom) {
                Text("Fast Fertig")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                Rectangle()
                    .frame(width: 103, height: 3) // Breite des Rechtecks anpassen
                    .foregroundColor(.primary) // Farbe der Linie
                    .offset(y: 5) // Abstand nach unten justieren
            }
            .padding(.bottom, 40)
            .padding(.top, 40)
            
            // Description Text
            VStack(alignment: .center, spacing: 24) {
                Text("Bitte klicke nun auf den ")
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                + Text("Link")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                + Text(" in der Bestätigungs-Mail.")
                    .fontWeight(.semibold)
                    .font(.system(size: 24))
                
                Text("Anschließend kann der ")
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                + Text("Organisator")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                + Text(" deines Vereins dich aufnehmen.")
                    .fontWeight(.semibold)
                    .font(.system(size: 24))

                
                Text("Sobald dies geschehen ist, erhältst du eine ")
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                + Text("Mitteilung.")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                    .fontWeight(.semibold)

            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Vereinslogo Placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 150)
                .overlay(
                    Text("Vereinslogo")
                        .foregroundColor(.gray)
                )
                .padding(.bottom, 20)
                .padding(.top, 60)
            
            // Vereinsname
            Text(clubName)
                .font(.system(size: 16))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            
            Spacer()
        }
        .background(Color(UIColor.systemGray6))
        .edgesIgnoringSafeArea(.all)
    }
}

struct Onboarding_Wait_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_Wait()
    }
}
