//
//  CalibrationView.swift
//  spinning
//
//  Created by Esther Li on 2/5/26.
//

import UIKit
import SwiftUI

struct CalibrationView: View {
    @StateObject private var viewModel = CalibrationViewModel()
    @State private var showIntro = true

    var body: some View {
        ZStack {
            // 1. video preview
            VideoPreview(session: viewModel.cameraManager.session)
                .ignoresSafeArea()

            // 2. recording-related UI
            VStack {
                Picker("Mode", selection: $viewModel.currentMode) {
                    Text("1. Calibrate").tag(AppMode.calibrate)
                    Text("2. Track").tag(AppMode.track)
                }
                .pickerStyle(.segmented)
                .disabled((!viewModel.canTrack))
                .background(Color.black.opacity(0.5).cornerRadius(8))
                .padding(.horizontal, 40)
                .padding(.top, 60)

                Group {
                    if viewModel.currentMode == .calibrate {
                        Text("**Calibration:** Fix phone on object\nand rotate smoothly")
                    } else {
                        Text("**Tracking:** Handheld recording\ndistance away from object")
                    }
                }
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(14)
                .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark).cornerRadius(12))
                .padding(.top, 20)

                Spacer()
                
                Button(action: {
                    viewModel.toggleAction()
                }) {
                    VStack(spacing: 12) {
                        Text(viewModel.currentMode == .calibrate ? "START CALIBRATION" : "START TRACKING")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.white)
                            .tracking(1)
                        
                        ZStack {
                            Circle()
                                .stroke(viewModel.currentMode == .calibrate ? Color.blue : Color.green, lineWidth: 4)
                                .frame(width: 75, height: 75)
                            
                            RoundedRectangle(cornerRadius: viewModel.isRecording ? 4 : 30)
                                .fill(viewModel.isRecording ? Color.red : (viewModel.currentMode == .calibrate ? Color.blue : Color.green))
                                .frame(width: viewModel.isRecording ? 25 : 60, height: viewModel.isRecording ? 25 : 60)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isRecording)
                        }
                    }
                }
                .padding(.bottom, 50)
                .disabled(viewModel.isAnalyzing)
            }

            // 3. Loading
            if viewModel.isAnalyzing {
                ZStack {
                    Color.black.opacity(0.75).ignoresSafeArea()
                    VStack(spacing: 25) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text(viewModel.currentMode == .calibrate ? "Building physical model..." : "Visual comparison in progress...")
                            .foregroundColor(.white)
                            .font(.system(.headline))
                    }
                }
                .transition(.opacity)
                .zIndex(10)
            }

            // 4. Intro View
            if showIntro {
                IntroView()
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .top)))
                    .onAppear {
                        viewModel.resetForDemo()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation(.easeInOut(duration: 1.2)) {
                                showIntro = false
                            }
                        }
                    }
                    .zIndex(20)
            }
        }
        .sheet(item: $viewModel.analysisResult) { result in
            AnalysisResultView(
                result: result,
                baseline: viewModel.currentMode == .track ? viewModel.baseline : nil
            ) {
                viewModel.analysisResult = nil
                if (viewModel.baseline?.score ?? 0) >= 70 && viewModel.currentMode == .calibrate {
                    withAnimation { viewModel.currentMode = .track }
                }
            }
        }
    }
}


struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
