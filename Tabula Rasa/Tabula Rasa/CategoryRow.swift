//
//  CategoryRow.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 31/12/22.
//

import SwiftUI

struct CategoryRow: View {
    @Binding var isChecked: Tribool
//    @State var id: UUID
    @State var name: String
    @Binding var size: String
    @State var oldSizeValue: String = "Analyzing"
    @State var hasFineSelection: Bool
    @Binding var isOffScreen: Bool
    @State var requiresManualSelection: Bool
    @Binding var shouldShowList: Bool
//    @Binding var isPressed: [Bool]
    @State private var writing = false
    @State private var timer: Timer?
//    @State var appIcons: [UIImage] = [UIImage(),UIImage(),UIImage()]
//    @State var isDragGesture = false
//    var index: Int
    @State var sizeTextWidth: CGFloat = 0.0
    
    @State var stopAnimating = false
    @State var animate = true
    
    var body: some View {
        Button(action: {
            if hasFineSelection {
                //                    print("toggle lista")
                playHapticTransient(intensity: 0.5, sharpness: 0.05)
//                withAnimation(.easeInOut) { //fa crashare se le liste vengono aperte e chiuse velocemente
                
//                if stopAnimating {
//                    stopAnimating = false
//                }
                
                if isOffScreen || !shouldShowList {
                    print("\(name) setting stopAnimating to true")
                    stopAnimating = true
                } else {
                    resetAnimation()
//                    stopAnimating = false
                }
                
                shouldShowList.toggle()
                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    stopAnimating = false
//                }
            } else {
                //                    print("ceccato")
                isChecked.toggle()
                //                    Haptics.shared.select()
            }

////            if !requiresManualSelection {
//                if hasFineSelection {
//                    print("toggle lista")
//                    shouldShowList.toggle()
//                } else {
//                    print("ceccato")
//                    isChecked.toggle()
//                }
//            }
        }) {
            HStack(){
                VStack(alignment: .leading, spacing: 13){
                    Text(name)
                        .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
                        .font(.system(size: 21, weight: .semibold))
                        .lineLimit(3)
//                        .minimumScaleFactor(0.5) // Fa laggare quando si apre una lista
                        .foregroundColor(.white)
//                        .frame(maxHeight: .infinity)
                        .fixedSize(horizontal: false, vertical: true)
//                        .frame(maxWidth: .infinity)
                        .animation(nil)
                    Text(oldSizeValue)
                        .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color(UIColor(named: "CategoryRowSize") ?? .gray))
                        .onChange(of: size, perform: { newSize in
                            // Writing Animation
                            if writing {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    writing.toggle()
                                }
                                self.timer?.invalidate()
                                timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                        oldSizeValue = newSize
                                    withAnimation(.easeOut(duration: 0.3)) {
                                    writing.toggle()
                                }
                                    self.timer?.invalidate()
                                }
                            } else {
                                oldSizeValue = newSize
                                withAnimation(.easeOut(duration: 0.5)) {
                                    writing.toggle()
                                }
                            }
                        })
                        .onAppear() {
                            size += " "
                            // Triggers the writing animation
                        }
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear(perform: {
                                sizeTextWidth = geometry.size.width
                            }).onChange(of: geometry.size.width, perform: { newTextWidth in
                                sizeTextWidth = newTextWidth
                            })
                        })
                        .mask(Rectangle().offset(x: writing ? 0 : ( -sizeTextWidth - 150)))
                        .animation(nil)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .animation(nil)
                Spacer()
                    .animation(nil)
                if !requiresManualSelection {
                    Toggle("", isOn: toggleValue())
                        .onChange(of: isChecked) { _ in
                        Haptics.shared.select()
                            print("haptic")
                    }
                    .animation(.spring(response: 0.16, dampingFraction: 1, blendDuration: 0.3))
                    .toggleStyle(CheckboxStyle())
                    .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
                    .disabled(!hasFineSelection)
                    .animation(nil)
                } else {
                    if (hasFineSelection) {
//                        Button(action: {
//                            shouldShowList.toggle()
//                        }) {
                            Image(systemName: "chevron.up")
                                .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
                                .font(.system(size: 24, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
                                .animation(nil)
                                .scaleEffect(shouldShowList ? CGSize(width: 1.0, height: 1.0) : CGSize(width: 1.0, height: -1.0))
                                .animation(.spring(response: 0.16, dampingFraction: 1, blendDuration: 0.3))
//                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 26, leading: 26, bottom: 26, trailing: 26))
            .background(RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(UIColor(named: "CardBackground") ?? .black)))
            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color(UIColor(named: "CardBorder") ?? .gray), lineWidth: 1))
//            .fixedSize(horizontal: false, vertical: true) // Doesn't cause the button to
        }
//        .animation(shouldShowList ? nil :
//                                    (isOffScreen ?
//                                                    nil :
//                                                    .interpolatingSpring(mass: 1, stiffness: 500, damping: 100, initialVelocity: 0)))
//        .onChange(of: isOffScreen, perform: { _ in
//            print(name + " isOffScreen changed to \(isOffScreen)")
//            shouldAnimate = !isOffScreen
//        })
        // If the category row is currently sticked to the top, the animation shouldn't play because it will cause stuttering during scrolling and it will slowly slide to the top when the list gets closed, if it is not offScreen the screen will not scroll automatically to it and so it doesn't matter if it is animated or not.
//        .animation(isOffScreen ? nil )
//        .if(isOffScreen || shouldShowList, transform: { view in
//            view
//                .animation(nil)
//        })
//        .onAppear(perform: {animate.toggle()})
//        .animation(nil, value: stopAnimating)
        .animation(stopAnimating ? nil : .interpolatingSpring(mass: 1, stiffness: 700, damping: 100, initialVelocity: 0))
        .onChange(of: shouldShowList, perform: { _ in
            if stopAnimating && !shouldShowList {
                print("\(name) setting stopAnimating to false")
                stopAnimating = false
                }
        })
        .onChange(of: isOffScreen, perform: { _ in
            if shouldShowList {
                print("\(name) is showing list, stop animating toggled")
//                stopAnimating.toggle()
                stopAnimating = true
            } else {
                print("\(name) is NOT showing list, animating toggled")
//                animate.toggle()
                stopAnimating = false
//                animate = true
            }
        })
//                    (shouldShowList ?
//                     nil :
//                            .interpolatingSpring(mass: 1, stiffness: 500, damping: 100, initialVelocity: 0)))
//        .animation(nil, value: !shouldAnimate)
//        .animation(.interpolatingSpring(mass: 1, stiffness: 500, damping: 100, initialVelocity: 0))
        .buttonStyle(CategoryButtonStyle(hasFineSelection: hasFineSelection))//, shouldShowList: $shouldShowList, isChecked: $isChecked))//, onStateChanged: { pressState in
//            print("state changed \(pressState)")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                if pressState {
//                    isDragGesture = true
//                }
////                if !pressState {
////                    print("hai tappato")
////                    isDragGesture = false
////                } else {
//////                    print("stai draggando")
//////                    isDragGesture = true
////                }
//            }
//            if pressState == false {
//                isDragGesture = false
//            }
//            isPressed = pressState
//            if isPressed {
//                if hasFineSelection {
//                    print("toggle lista")
//                    shouldShowList.toggle()
//                } else {
//                    print("ceccato")
//                    isChecked.toggle()
//                }
//            }
//        }, isTapGesture: $isDragGesture))
//        .animation(.interpolatingSpring(mass: 1, stiffness: shouldShowList ? 100 : 500, damping: 100, initialVelocity: 0))
    }
    
    private func resetAnimation() {
//        stopAnimating = false
    }
    
    private func toggleValue() -> Binding<Bool> {
        return .init(
            get: { isChecked == true },
            set: { isChecked = Tribool($0) })
    }
}
//state changed true
//tap gesture true
//toggle lista
//cache true
//state changed false
//state changed true
//tap gesture true
//toggle lista
//cache true
//state changed false

struct CategoryButtonStyle: ButtonStyle {
    var hasFineSelection: Bool
//    @Binding var isPressed: [Bool]
//    @Binding var shouldShowList: Bool
//    @Binding var isChecked: Tribool
//    var index: Int
//    var onStateChanged: (Bool) -> Void
//    @Binding var isTapGesture: Bool
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect((configuration.isPressed && hasFineSelection) ? 0.96 : 1.0)
            .opacity((configuration.isPressed && !hasFineSelection) ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
//            .onTapGesture {
////                isTapGesture = true
////                for i in isPressed.indices { isPressed[i] = false }
//////                pare che si bugga
////                isPressed[index] = configuration.isPressed
////                print("tap gesture \(isPressed)")
//                if hasFineSelection {
////                    print("toggle lista")
//                    playHapticTransient(intensity: 0.5, sharpness: 0.05)
//                    shouldShowList.toggle()
//                } else {
////                    print("ceccato")
//                    isChecked.toggle()
////                    Haptics.shared.select()
//                }
//
//            }
//            .onChange(of: configuration.isPressed) {
////                if configuration.isPressed == false {
////                    isTapGesture = configuration.isPressed
////                }
////                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
////                    if configuration.isPressed {
////                        isTapGesture = true
////                    }
////                    //                if !pressState {
////                    //                    print("hai tappato")
////                    //                    isDragGesture = false
////                    //                } else {
////                    ////                    print("stai draggando")
////                    ////                    isDragGesture = true
////                    //                }
////                }
////                if configuration.isPressed == false {
////                    isTapGesture = false
////                }
//                onStateChanged($0)  // << report if pressed externally
//            }
//            .onLongPressGesture(minimumDuration: 0.0, perform: {
////                isPressed = configuration.isPressed
////                if isPressed {
////                    if hasFineSelection {
////                        print("toggle lista")
////                        shouldShowList.toggle()
////                    } else {
////                        print("ceccato")
////                        isChecked.toggle()
////                    }
////                }
//            })
//            .gesture(DragGesture(minimumDistance: 0)
//                .onChanged({_ in
//                    isDragGesture = true
//                    print("drag gesture \(isDragGesture)")
//                })
//                    .onEnded({_ in
//                        isDragGesture = false
//                        print("drag gesture \(isDragGesture)")
//                    }))
    }
}

struct CategoryRow_InteractivePreviews: View {
    @State var isChecked: [Tribool] = [true, false, false, false]
    @State var shouldShowList: [Bool] = [true, true, true, false]
    var body: some View {
        VStack{
            CategoryRow(isChecked: $isChecked[0], name: "Database", size: .constant("500 MB"), hasFineSelection: false, isOffScreen: .constant(false), requiresManualSelection: false, shouldShowList: $shouldShowList[0])
            CategoryRow(isChecked: $isChecked[1], name: "Database", size: .constant("500 MB"), hasFineSelection: true, isOffScreen: .constant(false), requiresManualSelection: false, shouldShowList: $shouldShowList[1])
            CategoryRow(isChecked: $isChecked[2], name: "Database", size: .constant("500 MB"), hasFineSelection: true, isOffScreen: .constant(false), requiresManualSelection: true, shouldShowList: $shouldShowList[2])
            CategoryRow(isChecked: $isChecked[3], name: "Database", size: .constant("500 MB"), hasFineSelection: true, isOffScreen: .constant(false), requiresManualSelection: true, shouldShowList: $shouldShowList[3])
        }
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            CategoryRow_InteractivePreviews()
        }
    }
}
