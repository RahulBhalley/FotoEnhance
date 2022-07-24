//
//  FeedbackRequestView.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 18/07/22.
//

import SwiftUI
import SwiftUIX

struct FeedbackRequestView: View {
    var body: some View {
        VStack {
            Text("Feedback Request")
                .font(.system(size: 40, weight: .bold, design: .rounded))
            Text("🤩 Help us improve your experience")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .padding(.bottom, 20)
            VStack {
                HStack {
                    VStack {
                        Text("🌱 New Feature Requests")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                    Spacer()
                }
                .padding()
                HStack {
                    Text("If you need a new feature that seems missing from FotoEnhance, we can add it.")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                }
                .padding(.horizontal)
                HStack {
                    Text("🐞 Bugs")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    Spacer()
                }
                .padding()
                HStack {
                    Text("Did you expect FotoEnhance to do something else when you tapped that? Let us know.")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                }
                .padding(.horizontal)
                HStack {
                    Text("💥 Crashes")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    Spacer()
                }
                .padding()
                HStack {
                    Text("Did FotoEnhance crash on your device? Let us know how to reproduce the crash to fix it.")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                }
                .padding(.horizontal)
                HStack {
                    Text("🙏 Please consider sending your feedback.")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .padding()
            }
            Spacer()
            Text("♥️ We greatly value your feedback.")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
        }
        .padding(.vertical, 40)
    }
}

struct FeedbackRequestView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackRequestView()
    }
}
