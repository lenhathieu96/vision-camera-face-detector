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

    static func getBoundingBox(from face: Face) -> BoundingBox {
        let frameRect = face.frame
        return BoundingBox(x: frameRect.origin.x, y: frameRect.origin.y, width: frameRect.size.width, height: frameRect.size.height)
    }
    
    static func isFaceInFrame(faceBoundingBox: BoundingBox, frameWidth: Int32, frameHeight: Int32)-> Bool{
        let frameCenterY = CGFloat(frameHeight)/2
        let tolerance: CGFloat = 20

        return  faceBoundingBox.left < 0 ||
                faceBoundingBox.top < 0 ||
                Int32(faceBoundingBox.right) > frameWidth ||
                Int32(faceBoundingBox.bottom) > frameHeight ||
                CGFloat(faceBoundingBox.centerY) < frameCenterY - tolerance ||
                CGFloat(faceBoundingBox.centerY) > frameCenterY + tolerance
    }
}
