//
//  PosesView.swift
//  PicPose
//
//  Created by Jawahar Nathani on 22/04/25.
//


import SwiftUI

struct PosesView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var showMatchView = false
    
    var recommendedImages: [ProfileCardModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Top Bar
            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                
                Spacer()
                
                Image("company")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                
                Spacer()
            }
            .padding(.horizontal, 100)
            .padding(.top, 1)
            .padding(.bottom, 8)
            .background(.white)
            
            ZStack {
                VStack {
                    
                        SwipeView(
                            profiles: $homeViewModel.userProfiles,
                            onSwiped: { userModel, hasLiked in
                                homeViewModel.swipeUser(user: userModel, hasLiked: hasLiked)
                            }
                        )
                    
                }
                .onAppear(perform: performOnAppear)
                .onReceive(homeViewModel.$lastMatchProfile) { newValue in
                    if newValue != nil {
                        withAnimation {
                            showMatchView.toggle()
                        }
                    }
                }
            }
            .background(Color.black)
        }
    }

    private func performOnAppear(){
        if homeViewModel.isFirstFetching{
            homeViewModel.fetchProfiles(recommendedImages: recommendedImages)
        }
    }
}

struct PosesView_Previews: PreviewProvider {
    static var previews: some View {
        PosesView(recommendedImages: [])
    }
}
