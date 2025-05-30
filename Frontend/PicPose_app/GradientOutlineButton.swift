//
//  GradientOutlineButton.swift
//  PicPose
//
//  Created by Jawahar Nathani on 22/04/25.
//


import SwiftUI

struct GradientOutlineButton: View {
    
    let action: () -> ()
    let iconName: String
    let colors: [Color]
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding()
                .overlay(
                    Ellipse()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: colors),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
        }
    }
}

struct GradientOutlineButton_Previews: PreviewProvider {
    static var previews: some View {
        GradientOutlineButton(action: {
            print("It works!")
        },iconName: "heart", colors: [Color(red: 232/255, green: 57/255, blue: 132/255), Color(red: 244/255, green: 125/255, blue: 83/255)])
    }
}
