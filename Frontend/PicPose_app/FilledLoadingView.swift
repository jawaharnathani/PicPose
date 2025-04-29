////
////  FilledLoadingView.swift
////  PicPose
////
////  Created by Jawahar Nathani on 22/04/25.
////

import SwiftUI

struct FilledLoadingView: View {
    @State private var isRectangleAnimating = false
    @State private var currentMessageIndex = 0
    @State private var visibleLines: [String] = []
    @State private var currentLineIndex = 0
    @State private var navigateToPoses = false
    
    var metadata: [String]
    var recommendedImages: [ProfileCardModel]
    
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
            
            // Changing Text
            Text("Fetching results")
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(visibleLines, id: \.self) { line in
                    Text(line)
                        .font(.body)
                        .foregroundColor(.black)
                        .transition(.opacity)
                }
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                        if currentLineIndex < metadata.count {
                            withAnimation {
                                visibleLines.append(metadata[currentLineIndex])
                            }
                            currentLineIndex += 1
                        } else {
                            timer.invalidate()
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    navigateToPoses = true
                }
            }
        }
        .navigationDestination(isPresented: $navigateToPoses) {
            PosesView(recommendedImages: recommendedImages)
        }
    }
}

struct FilledLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        FilledLoadingView(metadata: [], recommendedImages: [])
    }
}
