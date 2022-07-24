//
//  SubscriptionView.swift
//  FotoEnhance
//
//  Created by Rahul Bhalley on 12/07/22.
//

import SwiftUI
import SwiftUIX

struct SubscriptionView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State var imageName = "1024"
    @Binding var showingSubscription: Bool
    
    var body: some View {
        ZStack {
            /*Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .brightness(colorScheme == .light ? -0.3 : -0.5)
                .ignoresSafeArea()*/
            VStack(alignment: .center) {
                VStack {
                    Button(systemImage: SFSymbolName(rawValue: "xmark.circle")!) {
                        showingSubscription = false
                    }
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                }
                Text("Unlock Pro")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .padding(.vertical, 40)
                    .shadow(color: .black, radius: 20, x: 10, y: 10)
                HStack {
                    VStack(alignment: .leading) {
                        Group {
                            Text("Features")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                            Text("No Internet Required")
                            Text("Enhance Unlimited Photos")
                            Text("No Watermark")
                        }
                        .shadow(color: .black, radius: 20, x: 10, y: 10)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .brightness(1.0)
                        .padding(.vertical, 10)
                    }
                    VStack(alignment: .leading) {
                        Group {
                            Text("Free")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                            Image(systemName: "checkmark.circle.fill")
                            Image(systemName: "checkmark.circle")
                            Image(systemName: "checkmark.circle")
                        }
                        .shadow(color: .black, radius: 20, x: 10, y: 10)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .padding(.vertical, 10)
                    }
                    VStack(alignment: .leading) {
                        Group {
                            Text("Pro")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                            Image(systemName: "checkmark.circle.fill")
                            Image(systemName: "checkmark.circle.fill")
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .shadow(color: .black, radius: 20, x: 10, y: 10)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .padding(.vertical, 10)
                    }
                }
                
                Spacer()
                
                // MARK: Subscription Buttons
                
                Group {
                    ZStack {
                        BlurEffectView(style: colorScheme == .light ? .light : .dark)
                            .cornerRadius(40)
                        Button("Subscribe") {
                            
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                    ZStack {
                        BlurEffectView(style: colorScheme == .light ? .light : .dark)
                            .cornerRadius(40)
                        Button("Enable Free Trial") {
                            
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                }
                .frame(width: 340, height: 70)
                
                Text("3 days free, then ₹89.00/week.")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .foregroundColor(.white)
            .padding(.vertical)
        }
        .onLongPressGesture {
            if imageName == "flowers2" {
                imageName = "amber"
            } else if imageName == "amber" {
                imageName = "flowers2"
            }
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    
    @State static var showingSubscription = false
    static var previews: some View {
        SubscriptionView(showingSubscription: $showingSubscription)
            .preferredColorScheme(.light)
    }
}
