//
//  Loading.swift
//  PicPose
//
//  Created by Jawahar Nathani on 28/04/25.
//


import SwiftUI

struct LoadingView: View {
    @State private var isRectangleAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            // Animated Rectangle
            Rectangle()
                .fill(Color.blue) // Customize color as needed
                .frame(width: 100, height: 3)
                .scaleEffect(x: isRectangleAnimating ? 1.5 : 1.0, y: 1.0)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        isRectangleAnimating = true
                    }
                }
            
            Text("Generating metadata")
                .font(.title3)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
