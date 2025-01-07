//
//  Votings_VotingRowView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 28.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct Votings_VotingRowView: View {
   @ObservedObject var viewModel: VotingViewModel
       var onVotingSelected: (GetVotingDTO) -> Void

       var body: some View {
           HStack {
               Text(viewModel.voting.question)
                   .frame(maxWidth: .infinity, alignment: .leading)
               Spacer()
              if viewModel.status != "" {
                 Image(systemName: viewModel.status)
                    .foregroundStyle(viewModel.symbolColor)
              }
               Spacer()
           }
           .contentShape(Rectangle())
           .onTapGesture {
               onVotingSelected(viewModel.voting)
           }
           .task {
               await viewModel.loadSymbolColorAndStatus()
           }
           .onChange(of: viewModel.voting.id) { old, newValue in
              Task {
//                 print("RowView: viewModel.voting changed")
                 await viewModel.loadSymbolColorAndStatus()
              }
           }
       }
}

//#Preview {
//   Votings_VotingRowView(viewModel: <#VotingViewModel#>, onVotingSelected: <#(GetVotingDTO) -> Void#>)
//}
