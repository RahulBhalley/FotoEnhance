//
//  LaunchAppView.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 22/07/22.
//

import SwiftUI

struct LaunchAppView: View {
    @State private var rotate = false
    let color1 = Color(white: 0.8)
    let color2 = Color(white: 0.95)
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [color2, color1]),
                           startPoint: .leading,
                           endPoint: .trailing)
                .ignoresSafeArea()
            VStack {
                Image("1024")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .rotationEffect(.degrees(rotate ? 360 : 0))
                    .animation(Animation.spring().repeatCount(2, autoreverses: true), value: rotate)
                    //.animation(Animation.linear(duration: 0.5).repeatForever(autoreverses: false), value: rotate)
                /*Text("Delta")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)*/
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                rotate.toggle()
            }
        }
    }
}

struct LaunchAppView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LaunchAppView()
        }
    }
}
