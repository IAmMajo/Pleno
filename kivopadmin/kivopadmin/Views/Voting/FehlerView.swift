// This file is licensed under the MIT-0 License.

import SwiftUI

struct FehlerView: View {
    let errorMessage: String
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Fehler")
                .font(.title)
                .foregroundColor(.red)

            Text(errorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: { onBack() }) {
                Label("Zurück", systemImage: "arrow.left")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .background(Color.white)
    }
}
