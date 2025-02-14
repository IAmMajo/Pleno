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
//  ImageView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 17.12.24.
//

import SwiftUI

// A view that displays an image with zoom and drag functionalities.
struct FullImageView: View {
   // MARK: - Environment & State Variables
       
       /// Handles dismissing the view when the close button is tapped.
       @Environment(\.dismiss) private var dismiss
       
       /// The amount of zoom currently being applied.
       @State private var currentZoom = 0.0
       
       /// The accumulated zoom level from previous gestures.
       @State private var totalZoom = 1.0
       
       /// The offset from dragging the image.
       @State private var dragOffset = CGSize.zero
       
       /// The total accumulated offset (drag position).
       @State private var accumulatedOffset = CGSize.zero
       
       /// The image being displayed.
       let uiImage: UIImage
   
   // MARK: - Body
   var body: some View {
      GeometryReader { geometry in
          let screenSize = geometry.size
          let imageSize = uiImage.size
          let aspectRatio = imageSize.width / imageSize.height

         // Initial dimensions for the image
          let initialImageWidth = screenSize.width
          let initialImageHeight = initialImageWidth / aspectRatio

         // Calculate the scaled image size based on zoom level
          let scaledImageSize = CGSize(
              width: initialImageWidth * totalZoom,
              height: initialImageHeight * totalZoom
          )

          // Maximum offset to prevent dragging beyond bounds
          let maxXOffset = max((scaledImageSize.width - screenSize.width) / 2, 0)
          let maxYOffset = max((scaledImageSize.height - screenSize.height) / 2, 0)

         // MARK: - Display Image
          Image(uiImage: uiImage)
              .resizable()
              .scaledToFit()
              .scaleEffect(currentZoom + totalZoom)
              .offset(
                  x: clamp(dragOffset.width + accumulatedOffset.width, -maxXOffset, maxXOffset),
                  y: clamp(dragOffset.height + accumulatedOffset.height, -maxYOffset, maxYOffset)
              )
              .gesture(
                  SimultaneousGesture(
                     // MARK: - Zoom Gesture (Pinch to Zoom)
                      MagnificationGesture()
                          .onChanged { value in
                              currentZoom = (value - 1) * totalZoom
                          }
                          .onEnded { value in
                              // Update total zoom
                              totalZoom += currentZoom
                              currentZoom = 0

                              if totalZoom < 1.0 {
                                  withAnimation(.easeOut(duration: 0.3)) {
                                      totalZoom = 1.0
                                  }
                              } else if totalZoom > 5.0 {
                                  withAnimation(.easeIn(duration: 0.1)) {
                                      totalZoom = 5.0
                                  }
                              }

                              // Adjust offsets after zoom to maintain position
                              accumulatedOffset.width = clamp(accumulatedOffset.width * (scaledImageSize.width / (initialImageWidth * totalZoom)), -maxXOffset, maxXOffset)
                              accumulatedOffset.height = clamp(accumulatedOffset.height * (scaledImageSize.height / (initialImageHeight * totalZoom)), -maxYOffset, maxYOffset)
                          },
                      // MARK: - Drag Gesture (Pan to Move)
                      DragGesture()
                          .onChanged { value in
                              dragOffset = value.translation
                          }
                          .onEnded { value in
                              // Update accumulated offsets with clamping
                              accumulatedOffset.width = clamp(accumulatedOffset.width + value.translation.width, -maxXOffset, maxXOffset)
                              accumulatedOffset.height = clamp(accumulatedOffset.height + value.translation.height, -maxYOffset, maxYOffset)
                              dragOffset = .zero
                          }
                  )
              )
              .onAppear {
                  // Reset offsets to center the image initially
                  accumulatedOffset = .zero
                  dragOffset = .zero
              }
              .accessibilityZoomAction { action in
                 // Accessibility support for zooming in & out
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
   
   // Helper function to clamp a value between a minimum and maximum
   private func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
      return min(max(value, minValue), maxValue)
   }
}

#Preview {
}
