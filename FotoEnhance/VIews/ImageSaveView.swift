//
//  ImageSaveView.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 24/07/22.
//

import SwiftUI
import SwiftUIX

struct ImageSaveView: View {
    @Environment(\.colorScheme) var colorScheme
    let sideLength: CGFloat = 190
    var body: some View {
        ZStack(alignment: .center) {
            BlurEffectView(style: colorScheme == .light ? .systemUltraThinMaterialLight : .systemUltraThinMaterialDark)
                .frame(width: sideLength, height: sideLength)
                .cornerRadius(10)
            VStack {
                Image(systemName: SFSymbolName(rawValue: "checkmark.circle")!)
                    .resizable()
                    .sizeToFitSquare(sideLength: 100)
                    .foregroundColor(.secondary)
                Text("Saved to Photos")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .padding(.top)
            }
        }
    }
}

struct ImageSaveView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Image("1024")
                ImageSaveView()
            }
            .preferredColorScheme(.light)
            ZStack {
                Image("1024")
                ImageSaveView()
            }
            .preferredColorScheme(.dark)
        }
    }
}
