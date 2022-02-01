	//
	//  LoadingView.swift
	//  ProductViewer
	//
	//  Created by Jigs Sheth on 1/26/22.
	//

import SwiftUI


	/// Loading view for the data.
struct LoadingView: View {
	let text:String
	var body: some View {
		ZStack {
			Color(.lightGray)
				.opacity(0.2)
				.ignoresSafeArea()
			ProgressView(text)
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 10)
						.fill(Color(.systemBackground)
										.opacity(0.2))
						.shadow(radius: 1)
				)
		}
	}
}

struct LoadingView_Previews: PreviewProvider {
	static var previews: some View {
		LoadingView(text: String.loadingProduct)
	}
}
