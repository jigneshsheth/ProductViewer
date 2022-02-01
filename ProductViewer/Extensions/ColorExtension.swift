	//
	//  ColorExtension.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import Foundation
import SwiftUI


extension Color {
	
	static let lightBlack = Color.black.opacity(0.6)
	
		/// Random Color
	static var random:Color {
		return Color(
			red: .random(in: 0...1),
			green: .random(in: 0...1),
			blue: .random(in: 0...1)
		).opacity(0.3)
	}
}




