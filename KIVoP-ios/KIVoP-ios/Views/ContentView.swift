//
//  ContentView.swift
//  KIVoP-ios
//
//  Created by Amine Ahamri on 29.10.24.
//

import SwiftUI

struct ContentView: View {
   var body: some View {
      NavigationView {
         NavigationLink(destination: Votings_VotingsOverview()) {
            Text("Abstimmungen")
         }
      }
   }
}

#Preview {
    ContentView()
}
