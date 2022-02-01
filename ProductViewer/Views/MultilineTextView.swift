	//
	//  MultilineTextView.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import SwiftUI


	/// Multiline Text : Text with scrollview
struct MultilineTextView: View {
	var multiLineText:String
	var body: some View {
		ScrollView {
			VStack(alignment: .leading) {
				Text(multiLineText)
					.font(.body)
					.fontWeight(.medium)
					.lineLimit(nil)
			}.frame(maxWidth: .infinity)
		}.padding([.leading,.trailing],3.0)
	}
}

struct MultilineTextView_Previews: PreviewProvider {
	static var previews: some View {
		MultilineTextView(multiLineText: "This is long description...Line 1: This is long description... \n Line 2: This is long description... \nLine 3: This is long description...")
			.previewLayout(.sizeThatFits)
		
	}
}
