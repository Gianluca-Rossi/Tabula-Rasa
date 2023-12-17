//
//  HorizontalDivider.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 12/03/23.
//

import SwiftUI

struct HorizontalDivider: View {
    
    let color: Color
    let height: CGFloat
    
    init(color: Color = .clear, height: CGFloat = 0.5) {
        self.color = color
        self.height = height
    }
    
    var body: some View {
        color
            .frame(height: height)
    }
}

struct HorizontalDivider_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalDivider(color: .clear)
    }
}
