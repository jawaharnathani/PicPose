//
//  SwipeView.swift
//  PicPose
//
//  Created by Jawahar Nathani on 22/04/25.
//

import SwiftUI

enum SwipeAction{
    case swipeLeft, swipeRight, doNothing
}

struct SwipeView: View {
    @Binding var profiles: [ProfileCardModel]
    @State var swipeAction: SwipeAction = .doNothing
    //Bool: true if it was a like (swipe to the right
    var onSwiped: (ProfileCardModel, Bool) -> ()
    
    var body: some View {
        VStack{
            Spacer()
            VStack{
                ZStack{
                    Text("All Done").font(.title3).fontWeight(.medium).foregroundColor(Color(UIColor.systemGray)).multilineTextAlignment(.center)
                    ForEach(profiles.indices, id: \.self){ index  in
                        let model: ProfileCardModel = profiles[index]
                        SwipeableCardView(model: model, swipeAction: $swipeAction, onSwiped: performSwipe)
                    }
                }
            }.padding()
            Spacer()
            HStack {
                Spacer()
                HStack {
                    GradientOutlineButton(action: { swipeAction = .swipeLeft }, iconName: "multiply", colors: AppColor.dislikeColors)
                    Spacer()
//                    Button(action: {
//                        print("Logo clicked")
//                    }) {
//                        Image("logo")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 65)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    Spacer()
                    GradientOutlineButton(action: { swipeAction = .swipeRight }, iconName: "heart", colors: AppColor.likeColors)
                }
                .padding() // inner padding for spacing content inside the HStack
//                .background(Color.white)
                .cornerRadius(16) // adjust radius as needed
                .padding(.horizontal, 70) // this gives space from the screen's left/right
                Spacer()
            }
        }
    }
    
    private func performSwipe(userProfile: ProfileCardModel, hasLiked: Bool){
        removeTopItem()
        onSwiped(userProfile, hasLiked)
    }
    
    private func removeTopItem(){
        profiles.removeLast()
    }
    
    
}

//Swipe functionality
import SwiftUI

struct SwipeableCardView: View {
    private let nope = "NOPE"
    private let like = "LIKE"
    private let screenWidthLimit = UIScreen.main.bounds.width * 0.5
    
    let model: ProfileCardModel
    @State private var dragOffset = CGSize.zero
    @Binding var swipeAction: SwipeAction
    var onSwiped: (ProfileCardModel, Bool) -> Void
    
    var body: some View {
        ZStack {
            // Base view (test with a colored rectangle to ensure rendering)
            SwipeCardView(model: model)
            HStack {
                Text(like)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.green) // Test with solid color
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green, lineWidth: 4)
                    )
                    .rotationEffect(.degrees(-30))
                    .opacity(getLikeOpacity())
                
                Spacer()
                
                Text(nope)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red) // Test with solid color
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red, lineWidth: 4)
                    )
                    .rotationEffect(.degrees(30))
                    .opacity(getDislikeOpacity())
            }
            .padding(.top, 25)
            .padding(.horizontal, 20)
        }
        .offset(x: dragOffset.width, y: dragOffset.height)
        .rotationEffect(.degrees(dragOffset.width * -0.06), anchor: .center)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0.0)
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    performDragEnd(value.translation)
                }
        )
        .onChange(of: swipeAction) {
            if swipeAction != .doNothing {
                performSwipe(swipeAction)
            }
        }
    }
    
    private func performSwipe(_ swipeAction: SwipeAction) {
        withAnimation(.linear(duration: 0.3)) {
            if swipeAction == .swipeRight {
                dragOffset.width += screenWidthLimit * 2
            } else if swipeAction == .swipeLeft {
                dragOffset.width -= screenWidthLimit * 2
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSwiped(model, swipeAction == .swipeRight)
        }
        self.swipeAction = .doNothing
    }
    
    private func performDragEnd(_ translation: CGSize) {
        let translationX = translation.width
        if hasLiked(translationX) {
            withAnimation(.linear(duration: 0.3)) {
                dragOffset = translation
                dragOffset.width += screenWidthLimit
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwiped(model, true)
            }
        } else if hasDisliked(translationX) {
            withAnimation(.linear(duration: 0.3)) {
                dragOffset = translation
                dragOffset.width -= screenWidthLimit
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwiped(model, false)
            }
        } else {
            withAnimation(.default) {
                dragOffset = .zero
            }
        }
    }
    
    private func hasLiked(_ value: Double) -> Bool {
        let ratio = dragOffset.width / screenWidthLimit
        return ratio >= 1
    }
    
    private func hasDisliked(_ value: Double) -> Bool {
        let ratio = -dragOffset.width / screenWidthLimit
        return ratio >= 1
    }
    
    private func getLikeOpacity() -> Double {
        let ratio = dragOffset.width / screenWidthLimit
        if ratio >= 1 {
            return 1.0
        } else if ratio <= 0 {
            return 0.0
        } else {
            return ratio
        }
    }
    
    private func getDislikeOpacity() -> Double {
        let ratio = -dragOffset.width / screenWidthLimit
        if ratio >= 1 {
            return 1.0
        } else if ratio <= 0 {
            return 0.0
        } else {
            return ratio
        }
    }
}

//Card design
struct SwipeCardView: View {
    let model: ProfileCardModel
    
    @State private var currentImageIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom){
            GeometryReader{ geometry in
                Image(uiImage: model.picture[currentImageIndex])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .gesture(
                        DragGesture(minimumDistance: 0).onEnded { value in
                            if value.translation.equalTo(.zero) {
                                if value.location.x <= geometry.size.width / 2 {
                                    showPrevPicture()
                                } else {
                                    showNextPicture()
                                }
                            }
                        }
                    )
            }
            
            VStack{
                if(model.picture.count > 1){
                    HStack{
                        ForEach(0..<model.picture.count, id: \.self){ index in
                            Rectangle().frame(height: 3).foregroundColor(index == currentImageIndex ? .white : .gray).opacity(index == currentImageIndex ? 1 : 0.5)
                        }
                    }
                    .padding(.top, 6)
                    .padding(.leading)
                    .padding(.trailing)
                }
                Spacer()
                VStack{
                    HStack(alignment: .firstTextBaseline){
                        Text(model.caption).font(.largeTitle).fontWeight(.semibold)
                        Spacer()
                    }
                }
                .padding()
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(0.7, contentMode: .fit)
        .background(.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
    
    
    private func showNextPicture(){
        if currentImageIndex < model.picture.count - 1 {
            currentImageIndex += 1
        }
    }
    
    private func showPrevPicture(){
        if currentImageIndex > 0 {
            currentImageIndex -= 1
        }
    }
}


struct SwipeView_Previews: PreviewProvider {
    @State static private var profiles: [ProfileCardModel] = []
    static var previews: some View {
        SwipeView(profiles: $profiles, onSwiped: {_,_ in})
    }
}
