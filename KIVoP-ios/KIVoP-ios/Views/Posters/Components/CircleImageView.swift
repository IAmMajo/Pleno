//
//  CircleImageView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI

struct CircleImageView: View {
   let status: Status
   
   var body: some View {
      if status == .notDisplayed {
         Rectangle()
//            .fill(Color(UIColor.systemGray4))
            .fill(.white)
            .frame(width: 165, height: 165)
            .overlay(
               VStack {
                  Image(systemName: "camera.fill")
                     .foregroundStyle(.gray)
                     .font(.system(size: 50))
                     .padding(.bottom, 2)
                  Text("Aufhängen\nbestätigen")
                     .font(.callout)
                     .fontWeight(.semibold)
                     .foregroundStyle(.gray)
               }
            )
            .cornerRadius(500)
            .shadow(radius: 5)
      } else {
         Image("TestPositionImage")
            .resizable()
            .scaledToFill()
            .frame(width: 165, height: 165)
            .clipShape(Circle())
            .shadow(radius: 5)
      }
   }
}

#Preview {
   CircleImageView(status: Status.hung)
}
