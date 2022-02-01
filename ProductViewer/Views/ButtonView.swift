	//
	//  ButtonView.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import SwiftUI

	/// Customized Button for the `Add To Cart` & ` Add to List`
struct ButtonView: View {
	
	let title:String
	let backgroundColor:Color
	let foregroundColor:Color
	let action:(() -> Void)
	@State private var isAnimated = false
	
	var body: some View {
		Button(action: action){
			Text(title)
				.fontWeight(.semibold)
				.frame(height: 50)
				.frame(minWidth: 100, maxWidth: 400)
				.font(.title2)
				.foregroundStyle(foregroundColor)
				.background { backgroundColor }
				.clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
				.contentShape(Rectangle())
				.padding([.leading,.trailing],5)
		}
		.accessibilityIdentifier(title)
		.buttonStyle(.squishable)
	}
	
}

struct ButtonView_Previews: PreviewProvider {
	static var previews: some View {
		VStack{
			ButtonView(title: String.addToList, backgroundColor: .gray.opacity(0.4), foregroundColor: .black){
				print("Tapping add to List !!!")
			}
			ButtonView(title: String.addToCart, backgroundColor: .accentColor, foregroundColor: .white){
				print("Tapping add to Cart !!!")
			}
		}
		.previewLayout(.sizeThatFits)
.previewInterfaceOrientation(.landscapeLeft)
		
	}
}
