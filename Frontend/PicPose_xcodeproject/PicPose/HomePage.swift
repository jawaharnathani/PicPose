//
//  HomePage.swift
//  PicPose
//
//  Created by Jawahar Nathani on 22/04/25.
//

import SwiftUI

// MARK: - Model
struct Place: Identifiable {
    let id = UUID()
    let title: String
    let mainImage: String
}

// MARK: - Data
let samplePlaces = [
    Place(title: "eiffletower", mainImage: "eiffel_tower"),
    Place(title: "animepark", mainImage: "anime_park"),
    Place(title: "disneyland", mainImage: "disney_land"),
    Place(title: "london", mainImage: "london"),
    Place(title: "randomposes", mainImage: "random_day")
]

// MARK: - View
struct HomePageView: View {
    @State private var selectedPlaceTitle: String? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Top Bar
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

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(samplePlaces) { place in
                            VStack(alignment: .leading, spacing: 10) {
                                // Main place image
                                Button(action: {
                                    selectedPlaceTitle = place.title
                                }) {
                                    Image(place.mainImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .clipped()
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }

                                // Place title
                                Text(place.title)
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                    .foregroundColor(Color.white)
                            }

                            Rectangle()
                                .fill(Color.white)
                                .frame(height: 0.5)
                                .opacity(1.0)
                                .padding(.horizontal, 5)
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color.black)
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedPlaceTitle != nil },
                set: { isActive in
                    if !isActive {
                        selectedPlaceTitle = nil
                    }
                }
            )) {
                UploadPageView(placeTitle: selectedPlaceTitle ?? "")
            }
        }
    }
}


struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
