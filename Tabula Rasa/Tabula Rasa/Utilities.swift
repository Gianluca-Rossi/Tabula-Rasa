//
//  Utilities.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 20/02/23.
//

import SwiftUI
//
//struct SizePreferenceKey: PreferenceKey {
//    static var defaultValue: CGSize = .zero
//
//    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
//        value = nextValue()
////        print("PREFERENCE KEY MODIFICATA")
//    }
//}
//
//struct MeasureSizeModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content.background(GeometryReader { geometry in
//            Color.clear.preference(key: SizePreferenceKey.self,
//                                   value: geometry.size)
//        }.hidden()
//        )
//    }
//}
//
//extension View {
//    func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
//        self.modifier(MeasureSizeModifier())
//            .onPreferenceChange(SizePreferenceKey.self, perform: action)
//    }
//}





//
//struct ChildSizeReader<Content: View>: View {
//    @Binding var size: CGSize
//    let content: () -> Content
//    var body: some View {
//        ZStack {
//            content()
//                .background(
//                    GeometryReader { proxy in
//                        Color.clear
//                            .preference(key: SizePreferenceKey2.self, value: proxy.size)
//                    }
//                )
//        }
//        .onPreferenceChange(SizePreferenceKey2.self) { preferences in
//            self.size = preferences
//            print("size changed")
//        }
//    }
//}
//
//struct SizePreferenceKey2: PreferenceKey {
//    typealias Value = CGSize
//    static var defaultValue: Value = .zero
//
//    static func reduce(value _: inout Value, nextValue: () -> Value) {
//        _ = nextValue()
//    }
//}
//
//
//
//
//
//
//struct GeometryContentSize<Content: View>: View {
//    public var content: (CGSize) -> Content
//
//    var body: some View {
//        GeometryReader { geo in
//            content(geo.size)
//        }
//    }
//}












//
//extension View {
//    func delaysTouches(for duration: TimeInterval = 0.25, onTap action: @escaping () -> Void = {}) -> some View {
//        modifier(DelaysTouches(duration: duration, action: action))
//    }
//}
//
//fileprivate struct DelaysTouches: ViewModifier {
//    @State private var disabled = false
//    @State private var touchDownDate: Date? = nil
//    
//    var duration: TimeInterval
//    var action: () -> Void
//    
//    func body(content: Content) -> some View {
//        Button(action: action) {
//            content
//        }
//        .buttonStyle(DelaysTouchesButtonStyle(disabled: $disabled, duration: duration, touchDownDate: $touchDownDate))
//        .disabled(disabled)
//    }
//}
//
//fileprivate struct DelaysTouchesButtonStyle: ButtonStyle {
//    @Binding var disabled: Bool
//    var duration: TimeInterval
//    @Binding var touchDownDate: Date?
//    
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .onChange(of: configuration.isPressed, perform: handleIsPressed)
//    }
//    
//    private func handleIsPressed(isPressed: Bool) {
//        if isPressed {
//            let date = Date()
//            touchDownDate = date
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + max(duration, 0)) {
//                if date == touchDownDate {
//                    disabled = true
//                    
//                    DispatchQueue.main.async {
//                        disabled = false
//                    }
//                }
//            }
//        } else {
//            touchDownDate = nil
//            disabled = false
//        }
//    }
//}






//import UIKit

class Haptics {
    static let shared = Haptics()
    
    private init() { }
    
    func select() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}




//struct HeightPreferenceKey : PreferenceKey {
//    
//    static var defaultValue: CGFloat = 0
//    
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
//    
//}
//
//struct WidthPreferenceKey : PreferenceKey {
//    
//    static var defaultValue: CGFloat = 0
//    
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
//    
//}
//
//struct SizePreferenceKey : PreferenceKey {
//    
//    static var defaultValue: CGSize = .zero
//    
//    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
//    
//}
//
//extension View {
//    
//    func readWidth() -> some View {
//        background(GeometryReader {
//            Color.clear.preference(key: WidthPreferenceKey.self, value: $0.size.width)
//        })
//    }
//    
//    func readHeight() -> some View {
//        background(GeometryReader {
//            Color.clear.preference(key: HeightPreferenceKey.self, value: $0.size.height)
//        })
//    }
//    
//    func onWidthChange(perform action: @escaping (CGFloat) -> Void) -> some View {
//        onPreferenceChange(WidthPreferenceKey.self) { width in
//            action(width)
//        }
//    }
//    
//    func onHeightChange(perform action: @escaping (CGFloat) -> Void) -> some View {
//        onPreferenceChange(HeightPreferenceKey.self) { height in
//            action(height)
//        }
//    }
//    
//    func readSize() -> some View {
//        background(GeometryReader {
//            Color.clear.preference(key: SizePreferenceKey.self, value: $0.size)
//        })
//    }
//    
//    func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
//        onPreferenceChange(SizePreferenceKey.self) { size in
//            action(size)
//        }
//    }
//    
//}

import CoreHaptics

// Haptic Engine & Player State:
private var engine: CHHapticEngine!
private var engineNeedsStart = true
private var continuousPlayer: CHHapticAdvancedPatternPlayer!

var supportsHaptics: Bool = {
    CHHapticEngine.capabilitiesForHardware().supportsHaptics
}()

func createAndStartHapticEngine() {
    guard supportsHaptics else { return }
    
    // Create and configure a haptic engine.
    do {
        engine = try CHHapticEngine()
    } catch let error {
        fatalError("Engine Creation Error: \(error)")
    }
    
    // Mute audio to reduce latency for collision haptics.
    engine.playsHapticsOnly = true
    
    // The stopped handler alerts you of engine stoppage.
    engine.stoppedHandler = { reason in
        print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
        switch reason {
        case .audioSessionInterrupt:
            print("Audio session interrupt")
        case .applicationSuspended:
            print("Application suspended")
        case .idleTimeout:
            print("Idle timeout")
        case .systemError:
            print("System error")
        case .notifyWhenFinished:
            print("Playback finished")
        case .gameControllerDisconnect:
            print("Controller disconnected.")
        case .engineDestroyed:
            print("Engine destroyed.")
        @unknown default:
            print("Unknown error")
        }
    }
    
    // The reset handler provides an opportunity to restart the engine.
    engine.resetHandler = {
        
        print("Reset Handler: Restarting the engine.")
        
        do {
            // Try restarting the engine.
            try engine.start()
            
            // Indicate that the next time the app requires a haptic, the app doesn't need to call engine.start().
            engineNeedsStart = false
            
//            // Recreate the continuous player.
//            createContinuousHapticPlayer()
            
        } catch {
            print("Failed to start the engine")
        }
    }
    
    // Start the haptic engine for the first time.
    do {
        try engine.start()
    } catch {
        print("Failed to start the engine: \(error)")
    }
}

// Play a haptic transient pattern at the given time, intensity, and sharpness.
func playHapticTransient(intensity: Float,
                                 sharpness: Float) {
    // Check if the device supports haptics.
    let hapticCapability = CHHapticEngine.capabilitiesForHardware()
    let supportsHaptics = hapticCapability.supportsHaptics
    
    // Abort if the device doesn't support haptics.
    if !supportsHaptics {
        return
    }
    
    // Create an event (static) parameter to represent the haptic's intensity.
    let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity,
                                                    value: intensity)
    
    // Create an event (static) parameter to represent the haptic's sharpness.
    let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness,
                                                    value: sharpness)
    
    // Create an event to represent the transient haptic pattern.
    let event = CHHapticEvent(eventType: .hapticTransient,
                              parameters: [intensityParameter, sharpnessParameter],
                              relativeTime: 0)
    
    // Create a pattern from the haptic event.
    do {
        let pattern = try CHHapticPattern(events: [event], parameters: [])
        
        // Create a player to play the haptic pattern.
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate) // Play now.
    } catch let error {
        print("Error creating a haptic transient pattern: \(error)")
    }
    }


extension String {
    func before(first delimiter: Character) -> String {
        if let index = firstIndex(of: delimiter) {
            let before = prefix(upTo: index)
            return String(before)
        }
        return self
    }
    
    func after(first delimiter: Character) -> String {
        if let index = firstIndex(of: delimiter) {
            let after = suffix(from: index).dropFirst()
            return String(after)
        }
        return self
    }
    
    func removingLeadingSpacesAndNewlines() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespacesAndNewlines) }) else {
            return self
        }
        return String(self[index...])
    }
    
    func trimmingTrailingSpaces() -> String {
        if let range = rangeOfCharacter(from: .whitespacesAndNewlines, options: [.anchored, .backwards]) {
            return String(self[..<range.lowerBound]).trimmingTrailingSpaces()
        }
        return self
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}


func getAlliOSLanguages() -> [String] {
//    let langCode = Locale.current.languageCode ?? ""
//    let regionCode = Locale.current.regionCode ?? ""
//    let language = "\(langCode)-\(regionCode)"
//
//    var languages = [String]()
//    let currentLocale = NSLocale.current as NSLocale
//    for languageCode in NSLocale.availableLocaleIdentifiers {
//        if let name = currentLocale.displayName(forKey: NSLocale.Key.languageCode, value: languageCode),
//           !languages.contains(name) {
//            languages.append(name)
//        }
//    }
//    return languages.sorted()
    
    return Locale.availableIdentifiers.sorted()
}


//extension View {
//    /// Applies the given transform if the given condition evaluates to `true`.
//    /// - Parameters:
//    ///   - condition: The condition to evaluate.
//    ///   - transform: The transform to apply to the source `View`.
//    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
//    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
//        if condition {
//            transform(self)
//        } else {
//            self
//        }
//    }
//}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    
    
    
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}

struct SizeCalculator: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}

extension View {

}

extension Bool {
    static var iOS13: Bool {
        guard #available(iOS 14, *) else {
            // It's iOS 13 so return true.
            return true
        }
        // It's iOS 14 so return false.
        return false
    }
}

extension String {
    
    /// An `NSRange` that represents the full range of the string.
    
    var nsRange: NSRange {
        return NSRange(startIndex ..< endIndex, in: self)
    }

    /// Substring from `NSRange`
    ///
    /// - Parameter nsRange: `NSRange` within the string.
    /// - Returns: `Substring` with the given `NSRange`, or `nil` if the range can't be converted.
    
    subscript(nsRange: NSRange) -> Substring? {
        return Range(nsRange, in: self)
            .flatMap { self[$0] }
    }
    
    func folderName() -> String {
        
        let regex = try! NSRegularExpression(pattern: "/\\s*(\\S[^/]*)$")
        if let match = regex.firstMatch(in: self, range: self.nsRange), let result = self[match.range(at: 1)] {
            if result == "" {
                return "/"
            } else {
                return String(result)
            }
        }
        return self
    }
    
    func substringAfterLastOccurenceOf(_ char: Character) -> String {
        
        let regex = try! NSRegularExpression(pattern: "\(char)\\s*(\\S[^\(char)]*)$")
        if let match = regex.firstMatch(in: self, range: self.nsRange), let result = self[match.range(at: 1)] {
            return String(result)
        }
        return ""
    }
    
}
