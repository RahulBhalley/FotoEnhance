//
//  EnhancementProgressView.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 18/07/22.
//

import SwiftUI
import SwiftUIX

struct EnhancementProgressView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack(alignment: .topTrailing) {
            BlurEffectView(style: colorScheme == .light ? .systemUltraThinMaterialLight : .systemUltraThinMaterialDark)
                .frame(width: 220, height: 180)
                .cornerRadius(10)
            VStack {
                HStack {
                    Spacer()
                    AIThumbnailView()
                }
                .padding([.top, .trailing])
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .frame(width: 50, height: 50)
                    Text("Enhancing photo...")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .colorScheme(.init(colorScheme == .light ? .light : .dark)!)
                        .foregroundColor(colorScheme == .light ? .black : .white)
                }
            }
        }
        .frame(width: 220, height: 180)
        .shadow(radius: 4)
    }
}

struct EnhancementProgressView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Image("1024")
                    .resizable()
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: .fill)
                EnhancementProgressView()
            }
            .preferredColorScheme(.light)
            ZStack {
                Image("1024")
                    .resizable()
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: .fill)
                EnhancementProgressView()
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct AIThumbnailView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            BlurEffectView(style: colorScheme == .light ? .systemThinMaterialLight : .systemThinMaterialDark)
                .frame(width: 36, height: 36)
                .cornerRadius(6)
            Text("AI")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
        }
        .shadow(radius: 4)
    }
}
