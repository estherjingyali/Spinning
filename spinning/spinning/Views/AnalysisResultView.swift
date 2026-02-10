//
//  AnalysisResultView.swift
//  spinning
//
//  Created by Esther Li on 2/9/26.
//

import SwiftUI

struct AnalysisResultView: View {
    let result: SpinAnalysis
    var baseline: SpinAnalysis? = nil
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(baseline == nil ? "Calibration Result" : "Tracking Analysis")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 30) {
                VStack {
                    Text("\(result.score)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(scoreColor)
                    Text("Score")
                        .font(.caption)
                }
                
                VStack {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(Int(result.max_rpm))")
                            .font(.system(size: 40, weight: .bold))
                        
                        if let base = baseline {
                            let diff = ((result.max_rpm - base.max_rpm) / base.max_rpm) * 100
                            Text(String(format: "%+.1f%%", diff))
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(abs(diff) < 10 ? .green : .red)
                        }
                    }
                    Text(baseline == nil ? "Max RPM" : "Current RPM")
                        .font(.caption)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                Label("Stability: \(result.is_stable ? "Good" : "Poor")",
                      systemImage: result.is_stable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(result.is_stable ? .green : .orange)
                
                Label("Drift: \(result.axial_drift)", systemImage: "scope")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let base = baseline {
                    Label("Baseline RPM: \(Int(base.max_rpm))", systemImage: "clock.arrow.circlepath")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(result.feedback)
                .font(.callout)
                .italic()
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)

            Button(baseline == nil ? (result.score >= 70 ? "Set as Baseline" : "Retry Calibration") : "Got it") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(result.score >= 70 ? .blue : .orange)
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding()
    }

    var scoreColor: Color {
        result.score >= 70 ? .green : (result.score >= 40 ? .orange : .red)
    }
}
