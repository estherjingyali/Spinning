//
//  SensorManager.swift
//  spinning
//
//  Created by Esther Li on 2/5/26.
//

import Foundation
import CoreMotion

class SensorManager: NSObject, ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var isRecording = false
    @Published var motionDataLog: [[String: Any]] = []
    private var startTime: Date?

    func startCapture() {
        motionDataLog.removeAll()
        startTime = Date()
        isRecording = true
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02 // 50Hz
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
                guard let data = data, let self = self, let start = self.startTime else { return }
                let timestamp = Date().timeIntervalSince(start)
                let entry: [String: Any] = [
                    "t": timestamp,
                    "qx": data.attitude.quaternion.x,
                    "qy": data.attitude.quaternion.y,
                    "qz": data.attitude.quaternion.z,
                    "qw": data.attitude.quaternion.w,
                    "rotX": data.rotationRate.x,
                    "rotY": data.rotationRate.y,
                    "rotZ": data.rotationRate.z
                ]
                self.motionDataLog.append(entry)
            }
        }
    }
    func stopUpdates() {
        isRecording = false
        motionManager.stopDeviceMotionUpdates()
    }
    
    func stopCapture() -> URL? {
        stopUpdates()
        return saveMotionDataToJSON()
    }
    
    func getEncodedData() -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: motionDataLog, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "[]"
        }
        return jsonString
    }
    
    private func saveMotionDataToJSON() -> URL? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: motionDataLog, options: .prettyPrinted)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("calibration_sensor.json")
            try jsonData.write(to: url)
            return url
        } catch {
            print("Failed to save JSON: \(error)")
            return nil
        }
    }
}
