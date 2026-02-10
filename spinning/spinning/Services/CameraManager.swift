//
//  CameraManager.swift
//  spinning
//
//  Created by Esther Li on 2/5/26.
//

import AVFoundation

class CameraManager: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var session = AVCaptureSession()
    @Published var isRecording = false
    private let output = AVCaptureMovieFileOutput()
    var videoURL: URL?

    override init() {
        super.init()
        checkPermissionsAndSetup()
    }

    private func checkPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async { self.setupSession() }
                }
            }
        default: break
        }
    }

    private func setupSession() {
        session.beginConfiguration()
        
        session.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        
        session.commitConfiguration()
        
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }

    func startRecording() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("calibration_video.mov")
        try? FileManager.default.removeItem(at: tempURL)
        
        
        if let connection = output.connection(with: .video) {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        }
        
        output.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
    }

    func stopRecording() {
        output.stopRecording()
        isRecording = false
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        self.videoURL = outputFileURL
    }
}
