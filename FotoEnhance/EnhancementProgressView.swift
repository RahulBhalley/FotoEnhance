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
//        ZStack {
//            Image("Watermark")
//                .resizable()
//                .ignoresSafeArea()
            ZStack {
                BlurEffectView(style: colorScheme == .light ? .light : .dark)
                    .frame(width: 220, height: 180)
                    .cornerRadius(10)
                VStack {
                    HStack {
                        Spacer()
                        /*Image("Watermark")
                            .sizeToFitSquare(sideLength: 30)*/
                        ZStack {
                            BlurEffectView(style: colorScheme == .light ? .systemThickMaterialLight : .systemThickMaterialDark)
                                .frame(width: 36, height: 36)
                                .cornerRadius(6)
                            Text("AI")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .shadow(radius: 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, -20)
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
//        }
    }
}

struct EnhancementProgressView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancementProgressView()
            .preferredColorScheme(.light)
    }
}
