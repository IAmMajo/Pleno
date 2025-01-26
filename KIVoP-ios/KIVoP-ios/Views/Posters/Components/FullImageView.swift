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
   @State private var dragOffset = CGSize.zero
   @State private var accumulatedOffset = CGSize.zero

   let uiImage: UIImage
   
   var body: some View {
//      GeometryReader { geometry in
////                 let imageSize = geometry.size
////                 let scaledImageSize = CGSize(
////                     width: imageSize.width * totalZoom,
////                     height: imageSize.height * totalZoom
////                 )
////                 let maxXOffset = max((scaledImageSize.width - imageSize.width) / 2, 0)
////                 let maxYOffset = max((scaledImageSize.height - imageSize.height) / 2, 0)
//         let screenSize = geometry.size
//         let imageSize = uiImage.size
//         let aspectRatio = imageSize.width / imageSize.height
//
//         // Calculate the initial image frame
//         let initialImageWidth = screenSize.width
//         let initialImageHeight = initialImageWidth / aspectRatio
//
//         let scaledImageSize = CGSize(
//             width: initialImageWidth * totalZoom,
//             height: initialImageHeight * totalZoom
//         )
//
//         // Calculate the maximum offset to prevent dragging beyond bounds
//         let maxXOffset = max((scaledImageSize.width - screenSize.width) / 2, 0)
//         let maxYOffset = max((scaledImageSize.height - screenSize.height) / 2, 0)
//
//         // Calculate initial centering offset
//         let initialOffsetX = (screenSize.width - scaledImageSize.width) / 2
//         let initialOffsetY = (screenSize.height - scaledImageSize.height) / 2
//      Image(uiImage: uiImage)
//         .resizable()
//         .scaledToFit()
//         .scaleEffect(currentZoom + totalZoom)
////         .offset(x: dragOffset.width + accumulatedOffset.width, y: dragOffset.height + accumulatedOffset.height)
//         .offset(
////             x: clamp(dragOffset.width + accumulatedOffset.width, -maxXOffset, maxXOffset),
////             y: clamp(dragOffset.height + accumulatedOffset.height, -maxYOffset, maxYOffset)
//             x: initialOffsetX + clamp(dragOffset.width + accumulatedOffset.width, -maxXOffset, maxXOffset),
//             y: initialOffsetY + clamp(dragOffset.height + accumulatedOffset.height, -maxYOffset, maxYOffset)
//         )
////         .onAppear {
////             // Reset offsets to ensure centering on view load
////             dragOffset = .zero
////             accumulatedOffset = .zero
////         }
//         .gesture(
//            SimultaneousGesture(
//               MagnifyGesture()
//                  .onChanged { value in
//                     currentZoom = (value.magnification - 1) * totalZoom
//                  }
//                  .onEnded { value in
//                     totalZoom = totalZoom + currentZoom
////                     totalZoom = min(max(1.0, totalZoom), 5.0)
//                     currentZoom = 0
//                     if totalZoom < 1.0 {
//                        withAnimation(.easeOut(duration: 0.3)) {
//                           totalZoom = 1.0
//                        }
//                     } else if totalZoom > 5.0 {
//                        withAnimation(.easeIn(duration: 0.1)) {
//                           totalZoom = 5.0
//                        }
//                     }
//                  },
//               DragGesture()
//                  .onChanged { value in
//                     dragOffset = value.translation
//                  }
//                  .onEnded { value in
////                     accumulatedOffset.width += value.translation.width
////                     accumulatedOffset.height += value.translation.height
//                     accumulatedOffset.width = clamp(accumulatedOffset.width + value.translation.width, -maxXOffset, maxXOffset)
//                     accumulatedOffset.height = clamp(accumulatedOffset.height + value.translation.height, -maxYOffset, maxYOffset)
//                     
//                     // Keep the image within bounds
//                     dragOffset = .zero
//                  }
//            )
//         )
//         .accessibilityZoomAction { action in
//            if action.direction == .zoomIn {
//               totalZoom += 1
//            } else {
//               totalZoom -= 1
//            }
//         }
//         .navigationBarBackButtonHidden(true)
//         .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//               Button {
//                  dismiss()
//               } label: {
//                  HStack {
//                     Text("Schließen")
//                  }
//               }
//            }
//         }
//   }
      
      
      GeometryReader { geometry in
          let screenSize = geometry.size
          let imageSize = uiImage.size
          let aspectRatio = imageSize.width / imageSize.height

          // Calculate the initial image dimensions
          let initialImageWidth = screenSize.width
          let initialImageHeight = initialImageWidth / aspectRatio

          // Scaled image size based on zoom level
          let scaledImageSize = CGSize(
              width: initialImageWidth * totalZoom,
              height: initialImageHeight * totalZoom
          )

          // Maximum offset to prevent dragging beyond bounds
          let maxXOffset = max((scaledImageSize.width - screenSize.width) / 2, 0)
          let maxYOffset = max((scaledImageSize.height - screenSize.height) / 2, 0)

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
      
//      GeometryReader { geometry in
//                 let screenSize = geometry.size
//                 let imageSize = uiImage.size
//                 let aspectRatio = imageSize.width / imageSize.height
//
//                 // Calculate the initial image frame
//                 let initialImageWidth = screenSize.width
//                 let initialImageHeight = initialImageWidth / aspectRatio
//
//                 let scaledImageSize = CGSize(
//                     width: initialImageWidth * totalZoom,
//                     height: initialImageHeight * totalZoom
//                 )
//
//                 // Calculate the maximum offset to prevent dragging beyond bounds
//                 let maxXOffset = max((scaledImageSize.width - screenSize.width) / 2, 0)
//                 let maxYOffset = max((scaledImageSize.height - screenSize.height) / 2, 0)
//
//                 // Calculate initial centering offset
//                 let initialOffsetX = (screenSize.width - scaledImageSize.width) / 2
//                 let initialOffsetY = (screenSize.height - scaledImageSize.height) / 2
//
//                 Image(uiImage: uiImage)
//                     .resizable()
//                     .scaledToFit()
//                     .scaleEffect(totalZoom)
//                     .offset(
//                         x: initialOffsetX + clamp(dragOffset.width + accumulatedOffset.width, -maxXOffset, maxXOffset),
//                         y: initialOffsetY + clamp(dragOffset.height + accumulatedOffset.height, -maxYOffset, maxYOffset)
//                     )
//                     .onAppear {
//                         // Reset offsets to ensure centering on view load
//                         dragOffset = .zero
//                         accumulatedOffset = .zero
//                     }
//                     .gesture(
//                         SimultaneousGesture(
//                             MagnificationGesture()
//                                 .onChanged { value in
//                                     currentZoom = (value - 1) * totalZoom
//                                     totalZoom = min(max(1.0, totalZoom + currentZoom), 5.0) // Limit zoom from 1x to 5x
//                                 }
//                                 .onEnded { _ in
//                                     totalZoom = min(max(1.0, totalZoom), 5.0)
//                                     currentZoom = 0
//                                 },
//                             DragGesture()
//                                 .onChanged { value in
//                                     dragOffset = value.translation
//                                 }
//                                 .onEnded { value in
//                                     accumulatedOffset.width = clamp(accumulatedOffset.width + value.translation.width, -maxXOffset, maxXOffset)
//                                     accumulatedOffset.height = clamp(accumulatedOffset.height + value.translation.height, -maxYOffset, maxYOffset)
//                                     dragOffset = .zero
//                                 }
//                         )
//                     )
//                     .navigationBarBackButtonHidden(true)
//                     .toolbar {
//                         ToolbarItem(placement: .navigationBarLeading) {
//                             Button {
//                                 dismiss()
//                             } label: {
//                                 HStack {
//                                     Text("Schließen")
//                                 }
//                             }
//                         }
//                     }
//             }
         
         }

         // Helper function to clamp a value between a minimum and maximum
         private func clamp(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
             return min(max(value, minValue), maxValue)
         }
}

#Preview {
//   FullImageView(image: "TestPositionImage")
}
