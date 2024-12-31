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
               Image(systemName: viewModel.status)
                   .foregroundStyle(viewModel.symbolColor)
               Spacer()
           }
           .contentShape(Rectangle())
           .onTapGesture {
               onVotingSelected(viewModel.voting)
           }
           .task {
               await viewModel.loadSymbolColorAndStatus()
           }
       }
}

//#Preview {
//   Votings_VotingRowView(viewModel: <#VotingViewModel#>, onVotingSelected: <#(GetVotingDTO) -> Void#>)
//}
