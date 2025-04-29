//
//  HomeViewModel.swift
//  PicPose
//
//  Created by Jawahar Nathani on 22/04/25.
//


import Foundation
import SwiftUI

class HomeViewModel: NSObject, ObservableObject {
    
    @Published var userProfiles: [ProfileCardModel] = []
    @Published private(set) var lastMatchProfile: ProfileCardModel? = nil
    @Published private(set) var isFirstFetching: Bool = true
    @Published private(set) var error: String? = nil
    @Published private(set) var isLoading: Bool = true
    
    func swipeUser(user: ProfileCardModel, hasLiked: Bool) {
        print("Swiped: \(user.id)")
    }
    
    func fetchProfiles(recommendedImages: [ProfileCardModel]){
        self.isLoading = true
        
        Task{
            DispatchQueue.main.async{
                self.isFirstFetching = false
                self.userProfiles = recommendedImages
                self.isLoading = false
            }
        }
    }
}
