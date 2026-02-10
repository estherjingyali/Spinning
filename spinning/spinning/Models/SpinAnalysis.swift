//
//  SpinAnalysis.swift
//  spinning
//
//  Created by Esther Li on 2/9/26.
//
import Foundation

struct SpinAnalysis: Codable, Identifiable {
    let id = UUID()
    let is_stable: Bool
    let max_rpm: Double
    let axial_drift: String
    let score: Int
    let feedback: String
    
    enum CodingKeys: String, CodingKey {
        case is_stable, max_rpm, axial_drift, score, feedback
    }
    
}
