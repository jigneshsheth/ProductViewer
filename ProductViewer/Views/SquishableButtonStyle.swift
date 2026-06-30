//
//  SquishableButtonStyle.swift
//  ProductViewer
//
//  Created by Jigs Sheth on 1/26/22.
//

import SwiftUI

/// ButtonStyle implementation for press button effect.
struct SquishableButtonStyle: ButtonStyle {
    var fadeOnPress = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed && fadeOnPress ? 0.75 : 1)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

//Extension can have computed property and functions. It can't have stored properties
// ButtonStyle is a protocol
extension ButtonStyle where Self == SquishableButtonStyle {
    
    //Extension cannot have a store property. It can have only a computed property.
    static var squishable: SquishableButtonStyle {
        SquishableButtonStyle()
    }
    
    // You can't do this because you are doing the protocol extension, not the concrete type extension.
    // static let squishable: SquishableButtonStyle = SquishableButtonStyle()
    
    
    static func squishable(fadeOnPress: Bool = true) -> SquishableButtonStyle {
        SquishableButtonStyle(fadeOnPress: fadeOnPress)
    }
}
