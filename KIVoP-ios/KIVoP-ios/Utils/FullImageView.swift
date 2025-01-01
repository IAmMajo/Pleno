//
//  ImageView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 17.12.24.
//

import SwiftUI

struct FullImageView: View {
   @Environment(\.dismiss) private var dismiss
   @State private var currentZoom = 0.0
   @State private var totalZoom = 1.0

   let image: String
   
   var body: some View {
      Image("\(image)")
         .resizable()
         .scaledToFit()
         .scaleEffect(currentZoom + totalZoom)
         .gesture(
            MagnifyGesture()
               .onChanged { value in
//                  currentZoom = value.magnification - 1
                  // Adjust zoom dynamically to keep speed consistent
                  currentZoom = (value.magnification - 1) * totalZoom
               }
               .onEnded { value in
                  totalZoom += currentZoom
                  currentZoom = 0
                  if totalZoom < 1.0 {
                     withAnimation(.easeOut(duration: 0.3)) {
                        totalZoom = 1.0
                     }
                  }
               }
         )
         .accessibilityZoomAction { action in
            if action.direction == .zoomIn {
               totalZoom += 1
            } else {
               totalZoom -= 1
            }
         }
         .navigationBarBackButtonHidden(true)
         .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
               Button {
                  dismiss()
               } label: {
                  HStack {
                     Text("Schließen")
                  }
               }
            }
         }
   }
}

#Preview {
   FullImageView(image: "TestPositionImage")
}
