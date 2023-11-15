//
//  FaceDetectionError.swift
//  VisionCameraFaceDetectorPlugin
//
//  Created by Lê Nhật Hiếu on 15/11/2023.
//

import Foundation
struct FaceDetectionError: Error {
    let code: Int
    let message: String
    
    func toDictionary() -> [String: Any] {
           return ["code": code, "message": message]
    }
}
