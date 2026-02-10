//
//  README.md
//  spinning
//
//  Created by Esther Li on 2/9/26.
//

# 🌀 SPINNING 🌀
### A rotational dynamic analyzer Powered by Gemini 3 Flash

## 🚀 The Vision
**SPINNING** bridges the gap between **High-fidelity Sensors** and **Computer Vision**. By leveraging Gemini's multimodal understanding, we analyze object rotation stability and RPM with zero external hardware.

---

## 🛠️ Core Operating Modes

### 1️⃣ Phase I: Perception Calibration (Hardware-In)
In this initial stage, the iPhone is physically attached to the rotating object (e.g., strapped to a spinner or placed on a turntable).
* **Data Fusion:** Synchronous capture of high-frequency **CoreMotion** telemetry (Angular Velocity $\omega$, Quaternions) and raw video stream.
* **The Goal:** Gemini 3 creates a **"Physical-Visual Fingerprint"** of the object, mapping invisible inertia data to visible pixel displacements and surface features.

### 2️⃣ Phase II: AI Tracking (Visual-Only)
Once calibrated, the hardware constraint is removed. The iPhone tracks the object purely via the camera lens.
* **Inference:** Using the pre-calibrated model, the AI predicts rotation even during **"Visual Disappearance"** (e.g., when the object's features are temporarily occluded or the Logo rotates out of view).
* **Output:** Real-time angular velocity ($\omega$), axial drift analysis, and a comprehensive stability score ($0-100$).

---

## 🧬 Multimodal Fusion Logic
The system solves the **"Visual Disappearance"** problem: When the object's features are occluded, the AI uses its pre-calibrated physical model to predict rotation, maintaining sub-degree accuracy.

## Tech Stack
- **Gemini 3 Flash**: Multimodal analysis of video + sensor telemetry.
- **SwiftUI + Combine**: Reactive industrial-grade UI.
- **CoreMotion**: High-frequency (100Hz+) gyroscopic and accelerometer data capture.
- **AVFoundation**: Low-latency video frame processing for high-speed motion.
                                                            
---
                                                            
## App Preview
![LaunchPage](Screenshots/launchpage.png)
| ![calibration result](Screenshots/calib.png) | ![tracking result](Screenshots/track.png) |

---
