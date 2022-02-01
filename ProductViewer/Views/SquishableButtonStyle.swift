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

extension ButtonStyle where Self == SquishableButtonStyle {
	static var squishable: SquishableButtonStyle {
		SquishableButtonStyle()
	}
	
	static func squishable(fadeOnPress: Bool = true) -> SquishableButtonStyle {
		SquishableButtonStyle(fadeOnPress: fadeOnPress)
	}
}
