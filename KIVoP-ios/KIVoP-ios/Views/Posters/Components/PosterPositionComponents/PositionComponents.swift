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

//
//  PositionComponents.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 12.02.25.
//

import SwiftUI
import PosterServiceDTOs

// MARK: - Responsible Users View
/// Displays a list of users responsible for a poster position
struct ResponsibleUsersView: View {
   let position: PosterPositionResponseDTO
   @Environment(\.colorScheme) var colorScheme
   
   var body: some View {
      VStack (alignment: .leading, spacing: 6) {
         // Header text displaying the number of responsible users
         Text("VERANTWORTLICHE (\(position.responsibleUsers.count))")
            .font(.footnote)
            .foregroundStyle(Color(UIColor.secondaryLabel))
            .padding(.leading, 32)
         ZStack {
            VStack {
               // Iterate over the responsible users and display their details
               ForEach (position.responsibleUsers, id: \.id) { user in
                  HStack {
                     UserProfileImageView(userId: user.id)
                     Text(user.name) // User name
                     Spacer()
                     
                     // Display dates for actions performed by the user
                     if position.postedBy == user.name || position.removedBy == user.name {
                        VStack {
                           if position.postedBy  == user.name {
                              let date = position.postedAt ?? Date()
                              Text("aufgehängt am \(formatDate(date))")
                           }
                           if position.removedBy == user.name {
                              let date = position.removedAt ?? Date()
                              Spacer()
                              Text("abgehängt am \(formatDate(date))")
                           }
                        }
                        .font(.footnote)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                     }
                  }
                  // Add a divider except for the last user
                  if user.id != position.responsibleUsers.last?.id {
                     Divider()
                        .padding(.vertical, 2)
                  }
               }
            }
            .padding(.horizontal) .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
         }
         .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
         .cornerRadius(10)
         .padding(.horizontal)
      }
      .padding(.vertical)
   }
   
   /// Formats a `Date` into a readable string (dd.MM.yy)
   func formatDate(_ date: Date) -> String {
      let date = Date() // Current date
      let formatter = DateFormatter()
      formatter.dateFormat = "dd.MM.yy"
      let formattedDate = formatter.string(from: date)
      return formattedDate
   }
}

// MARK: - Address View
/// Displays the address of a poster position, with options to copy coordinates and open in a map.
struct AddressView: View {
   let position: PosterPositionResponseDTO
   let address: String
   @Binding var showMapOptions: Bool
   @State private var tappedCopyButton: Bool = false
   @State private var copiedToClipboard: Bool = false
   
   @Environment(\.colorScheme) var colorScheme
   
   var body: some View {
      VStack (alignment: .leading, spacing: 6) {
         // Header text
         Text("ADRESSE IN DER NÄHE")
            .font(.footnote)
            .foregroundStyle(Color(UIColor.secondaryLabel))
            .padding(.leading, 32)
         ZStack {
            VStack {
               // Address display
               HStack(spacing: 0) {
                  Text(address)
                     .textSelection(.enabled)
                  
                  Spacer()
                  
                  // Share location button
                  VStack {
                     Button(action: { showMapOptions = true }) {
                        Image(systemName: "square.and.arrow.up")
                     }
                     .buttonStyle(PlainButtonStyle())
                     .foregroundStyle(.blue)
                     .frame(width: 25, height: 25)
                     .padding(.top, 8)
                     
                     Spacer()
                  }
               }
               
               Divider().padding(.vertical, 2)
               
               // Coordinates display with copy button
               HStack {
                  Text("\(String(format: "%.6f", position.latitude))° N, \(String(format: "%.6f", position.longitude))° E")
                     .textSelection(.enabled)
                  
                  Spacer()
                  
                  // Copy coordinates to clipboard
                  Button(action: {
                     tappedCopyButton.toggle()
                     UIPasteboard.general.string = "\(String(format: "%.6f", position.latitude))° N, \(String(format: "%.6f", position.longitude))° E"
                     withAnimation(.snappy) {
                        copiedToClipboard = true
                     }
                     DispatchQueue.main.asyncAfter (deadline: .now() + 1.8) {
                        withAnimation(.snappy) {
                           copiedToClipboard = false
                        }
                     }
                  }) {
                     Image(systemName: "document.on.document")
                  }
                  .buttonStyle(PlainButtonStyle())
                  .foregroundStyle(.blue)
                  .frame(width: 25, height: 25)
                  .sensoryFeedback(.success, trigger: tappedCopyButton)
               }
            }
            .padding(.horizontal) .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
         }
         .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
         .cornerRadius(10)
         .padding(.horizontal)
      }
      .overlay {
         // Show message when coordinates are copied
         if copiedToClipboard {
            Text ("In Zwischenablage kopiert")
               .font(.system(.body, design: .rounded, weight: .semibold))
               .foregroundStyle(.white)
               .padding ()
               .background(Color.blue.cornerRadius(12))
               .padding(.bottom)
               .shadow(radius: 5)
               .transition(.move (edge: .bottom))
               .frame(maxHeight: .infinity, alignment: .bottom)
         }
      }
   }
}

