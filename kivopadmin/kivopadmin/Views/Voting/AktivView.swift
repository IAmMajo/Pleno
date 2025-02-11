// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

struct AktivView: View {
    @StateObject private var viewModel: AktivViewModel

    init(voting: GetVotingDTO, onBack: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: AktivViewModel(voting: voting, onBack: onBack))
    }

    var body: some View {
        VStack {
            if viewModel.voting.iVoted {
                if let liveStatus = viewModel.liveStatus {
                    votingProgressView(liveStatus: liveStatus) // ❗ Parameter übergeben
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage: errorMessage)
                } else {
                    loadingView
                }
            } else {
                participationWarningView
            }




            Spacer()

            if viewModel.voting.iVoted {
                votingDetailsView
            }

            Spacer()

            closeVotingButton
        }
        .onAppear {
            if viewModel.voting.iVoted {
                viewModel.connectWebSocket()
            } else {
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
