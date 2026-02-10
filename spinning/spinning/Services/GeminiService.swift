//
//  GeminiService.swift
//  spinning
//
//  Created by Esther Li on 2/5/26.
//

import Foundation
import GoogleGenerativeAI

class GeminiService {
    static let shared = GeminiService()
    
    private var apiKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String ?? ""
    }
    
    private lazy var model = GenerativeModel(
        name: "gemini-3-flash-preview",
        apiKey: self.apiKey,
        generationConfig: GenerationConfig(responseMIMEType: "application/json")
    )

    func analyzeSpin(videoURL: URL, sensorData: String, completion: @escaping (String?) -> Void) {
        Task {
            do {
                let videoData = try Data(contentsOf: videoURL)
                let videoPart = ModelContent.Part.data(mimetype: "video/quicktime", videoData)
                
                // prompt - Calibrate Spin
                let prompt = """
                Analyze this device calibration spinning motion. 
                Synchronized IMU data (accelerometer/gyroscope): \(sensorData)
                
                Must Return a JSON object with:
                1. "is_stable": boolean
                2. "max_rpm": number
                3. "axial_drift": string (short description)
                4. "score": number (0-100)
                5. "feedback": string (one short advice)
                
                Return ONLY the JSON.
                """
                
                let response = try await model.generateContent(prompt, videoPart)
                
                DispatchQueue.main.async {
                    let cleaned = response.text?
                        .replacingOccurrences(of: "```json", with: "")
                        .replacingOccurrences(of: "```", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    completion(cleaned)
                }
            } catch {
                print("Gemini Error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    
    func trackSpinVisually(videoURL: URL, baseline: SpinAnalysis, completion: @escaping (String?) -> Void) {
        Task {
            do {
                let videoData = try Data(contentsOf: videoURL)
                let videoPart = ModelContent.Part.data(mimetype: "video/quicktime", videoData)
                
                // prompt - Tracking Spin
                let prompt = """
                You are in 'Visual Tracking Mode'. 
                PREVIOUS CALIBRATED BASELINE:
                - Max RPM: \(baseline.max_rpm)
                - Stability Score: \(baseline.score)
                
                Now, analyze this NEW video (pure vision, no sensor data). 
                1. Estimate current RPM based on visual motion.
                2. Compare with the baseline.
                3. Detect anomalies (e.g., wobbling, slowed speed).
                
                Return ONLY a JSON: {"is_stable": bool, "max_rpm": number, "axial_drift": string, "score": number, "feedback": string}
                """
                
                let response = try await model.generateContent(prompt, videoPart)
                
                DispatchQueue.main.async {
                    let cleaned = response.text?
                        .replacingOccurrences(of: "```json", with: "")
                        .replacingOccurrences(of: "```", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    completion(cleaned)
                }
            } catch {
                print("Tracking Error: \(error)")
                completion(nil)
            }
        }
    }
}
