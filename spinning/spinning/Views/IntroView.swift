//
//  IntroView.swift
//  spinning
//
//  Created by Esther Li on 2/8/26.
//

import SwiftUI

struct IntroView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 25) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(24)
                    
                    Text("Spinning")
                        .font(.system(size: 42, weight: .black, design: .default))
                        .tracking(5)
                        .foregroundColor(.black)
                }
                
                .padding(.bottom, 140)
                Text("Rotational dynamic analyzer\nbased on a multimodal large model\nwith Gemini 3")
                    .font(.system(size: 20, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.horizontal, 40)
                
                Spacer(minLength: 100)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.top, 40)
                
                Spacer()
                                
                VStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    
                    Text("initializing system")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black.opacity(0.4))
                        .tracking(2)
                }
                .padding(.bottom, 60)
            }
        }
    }
}
