//
//  Utils.swift
//  VisionCameraFaceDetectorPlugin
//
//  Created by Lê Nhật Hiếu on 14/11/2023.
//
import MLKitFaceDetection

import Foundation

class Utils {
    static func getFaceDirection(angleX: CGFloat, angleY: CGFloat)-> FaceDirection{
      if(angleX < 10 && angleX > -10 && angleY > -5 && angleY < 5){
        return FaceDirection.frontal
      }
      
      if(angleY < -40 &&  angleX > 0 && angleX < 20){
        return FaceDirection.leftSkewed;
       }
      
      if(angleY > 40 && angleX > 0 && angleX < 20){
           return FaceDirection.rightSkewed;
      }
        return FaceDirection.transitioning
    }
    
    static func isFaceOutOfFrame(faceBoundingBox: FaceBoundingBox, frameWidth: Int, frameHeight: Int)-> Bool{
        let frameCenterY = Double(frameHeight)/2
        let tolerance = 100.0
        
        return  faceBoundingBox.left < 0 ||
                faceBoundingBox.top < 0 ||
                faceBoundingBox.right > CGFloat(frameWidth) ||
                faceBoundingBox.bottom > CGFloat( frameHeight) ||
                faceBoundingBox.centerY <  Double(frameCenterY - tolerance)   ||
                faceBoundingBox.centerY > Double(frameCenterY + tolerance)
    }
}
