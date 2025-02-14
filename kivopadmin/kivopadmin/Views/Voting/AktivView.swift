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
import MeetingServiceDTOs

struct AktivView: View {
    // ViewModel für die Live-Abstimmung
    @StateObject private var viewModel: AktivViewModel

    // Initialisiert die Ansicht mit einer Abstimmung und einer Rückkehr-Funktion
    init(voting: GetVotingDTO, onBack: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: AktivViewModel(voting: voting, onBack: onBack))
    }

    var body: some View {
        VStack {
            // Falls der Benutzer abgestimmt hat, wird der Live-Status angezeigt
            if viewModel.voting.iVoted {
                if let liveStatus = viewModel.liveStatus {
                    votingProgressView(liveStatus: liveStatus)
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage: errorMessage)
                } else {
                    loadingView
                }
            } else {
                // Falls der Benutzer nicht abgestimmt hat, erscheint eine Warnung
                participationWarningView
            }

            Spacer()

            // Abstimmungsdetails nur anzeigen, wenn der Benutzer abgestimmt hat
            if viewModel.voting.iVoted {
                votingDetailsView
            }

            Spacer()

            // Button zum Beenden der Abstimmung bleibt immer sichtbar
            closeVotingButton
        }
        .onAppear {
            if viewModel.voting.iVoted {
                // WebSocket-Verbindung nur aufbauen, wenn der Benutzer abgestimmt hat
                viewModel.connectWebSocket()
            } else {
                // Falls der Benutzer nicht abgestimmt hat, nach 2 Sekunden zurücknavigieren
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    viewModel.onBack()
                }
            }
        }
        .onDisappear {
            viewModel.disconnectWebSocket()
        }
        .onChange(of: viewModel.liveStatus) { _, _ in
            viewModel.updateProgress()
        }
    }

    // Zeigt den Abstimmungsfortschritt als Kreisdiagramm an
    private func votingProgressView(liveStatus: String) -> some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 35)
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 35, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: viewModel.progress)
                Text("\(viewModel.value)/\(viewModel.total)")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
            }
            .padding(30)

            if !liveStatus.isEmpty {
                Text(liveStatus)
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
    }

    // Lade-Ansicht für Echtzeit-Daten
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2)
                .padding()
            Text("Warte auf Echtzeit-Daten...")
                .foregroundColor(.gray)
                .padding()
            Spacer()
        }
    }

    // Fehleranzeige, wenn Probleme beim Abrufen der Live-Daten auftreten
    private func errorView(errorMessage: String) -> some View {
        VStack {
            Spacer()
            Text("Fehler beim Laden der Daten: \(errorMessage)")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }

    // Warnung, falls der Benutzer noch nicht abgestimmt hat
    private var participationWarningView: some View {
        VStack {
            Spacer()
            Text("Sie müssen zuerst an der Abstimmung teilnehmen, um den Live-Stand zu sehen.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding()
            Spacer()
        }
    }

    // Zeigt die Frage der Abstimmung an
    private var votingDetailsView: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(viewModel.voting.question)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .cornerRadius(10)
    }

    // Button zum Beenden der Abstimmung
    private var closeVotingButton: some View {
        Button(action: viewModel.closeVoting) {
            if viewModel.isClosing {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                Text("Abstimmung beenden")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .disabled(viewModel.isClosing)
    }
}
