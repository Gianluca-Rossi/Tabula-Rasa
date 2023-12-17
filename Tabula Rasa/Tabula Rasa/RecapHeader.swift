//
//  RecapHeader.swift
//  Tabula Rasa 2
//
//  Created by Gianluca Rossi on 31/12/22.
//

import SwiftUI

struct RecapHeader: View {
    @Binding var size: String
    @State var oldSizeValue: String = ""
    @State var oldSizeMeasureValue: String = ""//"Bit"
    @State var subSubHeader: String = ""//"Bit"
    @Binding var sizeMeasure: String
    // 1. Animate From: Writing animation
    @State private var writing = false
    @State private var isAnimating = false
    @State var shine = false
    @State var measureShine = false
    @State private var writingMeasure = false
    @State private var timer: Timer?
    @State private var timer2: Timer?
    @State private var timer3: Timer?
    @State private var measureAnimTimer: Timer?
    @State private var completeAnimationTimer: Timer?
    @State var sizeTextScale: CGFloat = 1.0
    @State var sizeTextWidth: CGFloat = 0.0
    var body: some View {
        HStack(){
            VStack(alignment: .leading, spacing: 0){
                ZStack{
                    Text(oldSizeValue)
                        .tracking(0)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: 90, weight: .semibold))
                        .foregroundColor(Color(UIColor(named: "HeaderTitleColor") ?? .gray))
                        .padding(0)
//                        .frame(alignment: .center)
                        .onChange(of: size, perform: { newSize in
                            print("Assigning a new size to the header: ", newSize, oldSizeValue)
                            // Writing Animation
                            if newSize != oldSizeValue {
                                if isAnimating {
                                    //if it was already animating
                                    
                                    print("The header was already animating")
                                    // Stops previously queued shine animation from triggering
                                    self.timer2?.invalidate()
                                    self.timer3?.invalidate()
                                    // Reverse the animation
                                    withAnimation(.easeIn(duration: 0.3)) {
                                        writing = false
                                    }
                                    
                                    self.completeAnimationTimer?.invalidate()
                                    completeAnimationTimer = Timer.scheduledTimer(withTimeInterval: 2.9, repeats: false) { _ in
                                        isAnimating = false
                                    }
                                    
                                    // Make the new animation start to set the new value
                                    self.timer?.invalidate()
                                    timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                        oldSizeValue = newSize
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            writing.toggle()
                                        }
                                        //                                    self.timer?.invalidate()
                                        
                                        self.timer2?.invalidate()
                                        timer2 = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                            
                                            if shine {
                                                // Reverse the animation
                                                shine.toggle()
                                                
                                                // Make the new animation start to set the new value
                                                self.timer3?.invalidate()
                                                timer3 = Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
                                                    withAnimation(.easeOut(duration: 2)) {
                                                        shine.toggle()
                                                    }
                                                    self.timer3?.invalidate()
                                                }
                                            } else {
                                                withAnimation(Animation.linear(duration: 2)){
                                                    
                                                    shine.toggle()
                                                }
                                            }
                                            self.timer2?.invalidate()
                                        }
                                    }
                                } else {
                                    //if it wasn't animating
                                    print("The header was NOT animating")
                                    isAnimating = true
                                    
                                    self.completeAnimationTimer?.invalidate()
                                    completeAnimationTimer = Timer.scheduledTimer(withTimeInterval: 2.9, repeats: false) { _ in
                                        isAnimating = false
                                    }
                                    
                                    self.timer?.invalidate()
                                    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                        // set the new value and animate
                                        oldSizeValue = newSize
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            writing = true
                                        }
                                        self.timer2?.invalidate()
                                        timer2 = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                            
                                            if shine {
                                                // Reverse the animation
                                                shine.toggle()
                                                
                                                // Make the new animation start to set the new value
                                                self.timer3?.invalidate()
                                                timer3 = Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
                                                    withAnimation(.easeOut(duration: 2)) {
                                                        shine.toggle()
                                                    }
                                                    self.timer3?.invalidate()
                                                }
                                            } else {
                                                withAnimation(Animation.linear(duration: 2)){
                                                    
                                                    shine.toggle()
                                                }
                                            }
                                            self.timer2?.invalidate()
                                        }
                                    }
                                    // Reverse the animation
                                    withAnimation(.easeIn(duration: 0.3)) {
                                        writing = false
                                    }
                                }
                            }
                        })
                        .onAppear() {
                            size += " "
                            // Triggers the writing animation as the view appears
                        }
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear(perform: {
                                sizeTextWidth = geometry.size.width
//                                print("sizeTextWidth :\(sizeTextWidth)")
                            }).onChange(of: geometry.size.width, perform: { newTextWidth in
                                sizeTextWidth = newTextWidth
//                                print("sizeTextWidth :\(sizeTextWidth)")
                            })
                        })
                        .mask(Rectangle().offset(x: writing ? 0 : (-sizeTextWidth - 150)))
                    HStack(spacing: 0){
                        Text(oldSizeValue)
                            .tracking(0)
                            .minimumScaleFactor(0.1)
                            .font(.system(size: 90, weight: .semibold))
                            .foregroundColor(Color.white)
                            .padding(0)
                            .frame(alignment: .center)
                        //                        .lineLimit(1).font(.system(size: 58, weight: .bold))
                    }
                    //                    .frame(alignment: .center)
                    //                    .padding(0)
                    //                    .scaledToFit()
                    .mask(// Masking For Shimmer Effect...
                        Rectangle()
                        // For Some More Nice Effect Were Going to use Gradient...
                            .fill(
                                
                                // You can use any Color Here...
                                LinearGradient(gradient: .init(colors: [Color.white.opacity(0.5),Color.white,Color.white.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                            )
                            .rotationEffect(.init(degrees: 70))
                            .padding(20)
                        // Moving View Continously...
                        // so it will create Shimmer Effect...
                            .offset(x: -250)
                            .offset(x: shine ? 500 : 0))
//                    .onChange(of: size, perform: { newSize in
//                        withAnimation(Animation.linear(duration: 2)){
//
//                            shine.toggle()
//                        }
//                    })
                }
                .frame(alignment: .center)
                .padding(0)
                .scaledToFit()
                ZStack{
                    Text(oldSizeMeasureValue)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(UIColor(named: "HeaderTitleColor") ?? .gray))
                        .padding(0)
                        .mask(Rectangle().offset(x: writingMeasure ? 0 : -150))
                        .onChange(of: sizeMeasure, perform: { newMeasure in
                            // Writing Animation
//                            if writingMeasure {
                            if newMeasure != oldSizeMeasureValue {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    writingMeasure = false
                                }
                                self.measureAnimTimer?.invalidate()
                                measureAnimTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                    subSubHeader = ("Can be freed")
                                    oldSizeMeasureValue = newMeasure
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        writingMeasure.toggle()
                                    }
                                    self.measureAnimTimer?.invalidate()
                                }
                            }
//                            } else {
//                                writingMeasure = false
//                                subSubHeader = ("Can be freed")
//                                oldSizeMeasureValue = newMeasure
//                                withAnimation(.easeOut(duration: 0.5)) {
//                                    writingMeasure.toggle()
//                                }
//                            }
                        })
                        .onAppear() {
//                            sizeMeasure += " "
                            // Triggers the writing animation as the view appears
                        }
                        .scaledToFit()
                    HStack(spacing: 0){

//                        ForEach(0..<oldSizeMeasureValue.count,id: \.self){index in

                            Text(oldSizeMeasureValue)
                                .scaledToFit()
                                .minimumScaleFactor(0.1)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Color.white)
                                .padding(0)
//                        }
                    }
                    .mask(// Masking For Shimmer Effect...
                        Rectangle()
                        // For Some More Nice Effect Were Going to use Gradient...
                            .fill(
                                
                                // You can use any Color Here...
                                LinearGradient(gradient: .init(colors: [Color.white.opacity(0.5),Color.white,Color.white.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                            )
                            .rotationEffect(.init(degrees: 70))
                            .padding(20)
                        // Moving View Continously...
                        // so it will create Shimmer Effect...
                            .offset(x: -250)
                            .offset(x: measureShine ? 500 : 0) )
                    .frame(alignment: .center)
                    .scaledToFit()
                    .padding(0)
//                    .mask(// Masking For Shimmer Effect...
//                        Rectangle()
//                        // For Some More Nice Effect Were Going to use Gradient...
//                            .fill(
//
//                                // You can use any Color Here...
//                                LinearGradient(gradient: .init(colors: [Color.white.opacity(0.5),Color.white,Color.white.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
//                            )
//                            .rotationEffect(.init(degrees: 70))
//                            .padding(20)
//                        // Moving View Continously...
//                        // so it will create Shimmer Effect...
//                            .offset(x: -250)
//                            .offset(x: measureShine ? 500 : 0))
                    .onChange(of: sizeMeasure, perform: { newSizeMeasure in
                        withAnimation(Animation.linear(duration: 2)){

                            measureShine.toggle()
                        }
                    })
                }
//                Text("Can be freed")
//                    .font(.system(size: 18, weight: .regular, design: .default))
//                //                    .background(Color.black)
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.leading)
//                    .padding(0)
//                    .minimumScaleFactor(0.1)
//                    .scaledToFit()
                //                Spacer()
                
                ZStack{
                    Text(subSubHeader)
                        .minimumScaleFactor(0.1)
                        .font(.system(size: 18, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                        .padding(0)
//                        .minimumScaleFactor(0.1)
//                        .scaledToFit()
                        .mask(Rectangle().offset(x: writingMeasure ? 0 : -150))
                        .onAppear() {
                            subSubHeader += " "
                            // Triggers the writing animation as the view appears
                        }
                        .scaledToFit()
                    HStack(spacing: 0){
                        
                        //                        ForEach(0..<oldSizeMeasureValue.count,id: \.self){index in
                        
                        Text(subSubHeader)
                            .scaledToFit()
                            .minimumScaleFactor(0.1)
                            .font(.system(size: 18, weight: .regular, design: .default))
                            .foregroundColor(Color.white)
                            .padding(0)
                        //                        }
                    }
                    .mask(// Masking For Shimmer Effect...
                        Rectangle()
                        // For Some More Nice Effect Were Going to use Gradient...
                            .fill(
                                
                                // You can use any Color Here...
                                LinearGradient(gradient: .init(colors: [Color.white.opacity(0.5),Color.white,Color.white.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                            )
                            .rotationEffect(.init(degrees: 70))
                            .padding(20)
                        // Moving View Continously...
                        // so it will create Shimmer Effect...
                            .offset(x: -250)
                            .offset(x: measureShine ? 500 : 0) )
                    .frame(alignment: .center)
                    .scaledToFit()
                    .padding(0)
                }

            }
//            .frame(width: UIScreen.main.bounds.width/2 - 30 - 36)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 36))
            Spacer()
//            VStack{
//                RoundedRectangle(cornerRadius: 12)
//                    .frame(maxHeight: 280)
//                    .aspectRatio(0.72, contentMode: .fit)
//                    .foregroundColor(Color.gray)
//                //                Spacer()
//            }
        }
        //        .padding(EdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 36))
    }
}

struct RecapHeader_InteractivePreview: View {
    @State var size = ""
    @State var size1 = ""
    @State var size2 = ""
    @State var sizeMeasure = ""
    @State var sizeMeasure1 = ""
    @State var sizeMeasure2 = ""
    var body: some View {
        VStack{
            RecapHeader(size: $size, sizeMeasure: $sizeMeasure)
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        size = "un refresh"
                        sizeMeasure = "Kilobyte"
                    }
                })
            RecapHeader(size: $size1, sizeMeasure: $sizeMeasure1)
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        size1 = "un refresh"
                        sizeMeasure1 = "Kilobyte"
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        size1 = "due refresh"
                        sizeMeasure1 = "Megabyte"
                    }
                })
            RecapHeader(size: $size2, sizeMeasure: $sizeMeasure2)
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        size2 = "un refresh"
                        sizeMeasure2 = "Kilobyte"
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                        size2 = "due refresh"
                        sizeMeasure2 = "Megabyte"
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.3) {
                        size2 = "tre refresh"
                        sizeMeasure2 = "Gigabyte"
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.9) {
                        size2 = "quattro refresh"
                        sizeMeasure2 = "Gigabyte"
                    }
                })
        }.background(Color(UIColor(named: "BackgroundColor") ?? .black)
            .edgesIgnoringSafeArea(.vertical))
    }
}

struct RecapHeader_Previews: PreviewProvider {
    static var previews: some View {
        RecapHeader_InteractivePreview()
    }
}
