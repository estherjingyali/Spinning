//
//  CalibrationViewModel.swift
//  spinning
//
//  Created by Esther Li on 2/5/26.
//

import UIKit
import Foundation
import Combine

enum AppMode: String, CaseIterable {
    case calibrate = "Calibrate"
    case track = "Track"
}

class CalibrationViewModel: ObservableObject {
    @Published var cameraManager = CameraManager()
    @Published var sensorManager = SensorManager()
    
    @Published var isRecording = false
    @Published var isAnalyzing = false
    @Published var analysisResult: SpinAnalysis? = nil
    @Published var currentMode: AppMode = .calibrate
    @Published var baseline: SpinAnalysis? = nil
    
    var canTrack: Bool {
        return (baseline?.score ?? 0) >= 70
    }
    
    init() {
        self.baseline = nil
        self.currentMode = .calibrate
    }
    
    // explicitly clean up persistent baseline data
    func resetForDemo() {
            self.baseline = nil
            self.currentMode = .calibrate
            UserDefaults.standard.removeObject(forKey: "saved_baseline")
        }
    
    func toggleAction() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        if isRecording {
            isRecording = false
            currentMode == .calibrate ? stopCalibration() : stopTracking()
        } else {
            isRecording = true
            currentMode == .calibrate ? startCalibration() : startTracking()
        }
    }
    
    
    private func startCalibration() {
        analysisResult = nil
        sensorManager.startCapture()
        cameraManager.startRecording()
    }
    
    private func stopCalibration() {
        cameraManager.stopRecording()
        sensorManager.stopUpdates()
        
        let sensorJSON = sensorManager.getEncodedData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self, let videoURL = self.cameraManager.videoURL else { return }
            self.analyzeVideo(videoURL: videoURL, sensorJSON: sensorJSON)
        }
    }
    
    private func startTracking() {
        analysisResult = nil
        cameraManager.startRecording()
    }
    
    private func stopTracking() {
        cameraManager.stopRecording()
        if self.baseline == nil {
                return
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self,
                  let videoURL = self.cameraManager.videoURL,
                  let baseline = self.baseline else {
                print("ERROR: Guard failed in stopTracking")
                return }
            
            self.isAnalyzing = true
            GeminiService.shared.trackSpinVisually(videoURL: videoURL, baseline: baseline) { jsonString in
                self.handleResult(jsonString, isTracking: true)
            }
        }
    }
    

    func analyzeVideo(videoURL: URL, sensorJSON: String) {
        self.isAnalyzing = true
        GeminiService.shared.analyzeSpin(videoURL: videoURL, sensorData: sensorJSON) { [weak self] jsonString in
            self?.handleResult(jsonString, isTracking: false)
        }
    }
    

    private func handleResult(_ jsonString: String?, isTracking: Bool) {
        DispatchQueue.main.async {
            self.isAnalyzing = false
            
            guard let jsonString = jsonString,
                  let data = jsonString.data(using: .utf8) else { return }
            
            let decoder = JSONDecoder()
            do {
                let result: SpinAnalysis
                if jsonString.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("[") {
                    let decodedArray = try decoder.decode([SpinAnalysis].self, from: data)
                    result = decodedArray.first!
                } else {
                    result = try decoder.decode(SpinAnalysis.self, from: data)
                }
                
                self.analysisResult = result
                

                if !isTracking && result.score >= 70 {
                    self.handleCalibrationSuccess(result)
                } else if !isTracking {
                    self.baseline = nil
                }
                
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
            } catch {
                print("Parsing Failed: \(error)")
            }
        }
    }
    
    private func handleCalibrationSuccess(_ result: SpinAnalysis) {
        self.baseline = result
        if let encoded = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(encoded, forKey: "saved_baseline")
        }
    }
}
