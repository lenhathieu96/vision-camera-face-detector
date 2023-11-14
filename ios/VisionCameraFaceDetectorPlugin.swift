import VisionCamera
import MLKitVision
import MLKitFaceDetection
import CoreMedia
import CoreImage


@objc(VisionCameraFaceDetectorPlugin)
public class VisionCameraFaceDetectorPlugin: FrameProcessorPlugin {
    let MAX_STABLE = 3
    let faceDetectorOptions = FaceDetectorOptions()
    
    var result: [String: Any] = ["status": 0, "faceDirection": FaceDirection.unknown.rawValue, "errorCode":  -1, "frameData": ""]
    var stableCount = 0
    var _prevFaceDirection = FaceDirection.unknown
    
    class func newInstance() -> VisionCameraFaceDetectorPlugin {
        return VisionCameraFaceDetectorPlugin()
    }

    private func setErrorResult(errorCode: Int) {
        self.result = ["status": 0, "faceDirection": FaceDirection.unknown.rawValue, "errorCode":  errorCode, "frameData": ""]
    }
  
    @objc public override init() {
    super.init()
    faceDetectorOptions.performanceMode = .accurate
    faceDetectorOptions.landmarkMode = .all
  }
  
  @objc override public func callback(_ frame: Frame, withArguments arguments: [AnyHashable : Any]?) -> Any {
      let buffer = frame.buffer
      let visionImage = VisionImage(buffer: buffer)
      let faceDetector = FaceDetector.faceDetector(options: faceDetectorOptions)

      guard let formatDescription = CMSampleBufferGetFormatDescription(buffer) else {
        self.setErrorResult(errorCode: 102) // cannot get image from frame
        return result
      }
      let frameWidth = formatDescription.dimensions.width
      let frameHeight = formatDescription.dimensions.height

      weak var weakSelf = self
      
      faceDetector.process(visionImage) { faces, error in
        guard weakSelf != nil else {
          self.setErrorResult(errorCode: 101) // system error
          return
        }
          
        guard let faces = faces, !faces.isEmpty else {
          self.setErrorResult(errorCode: 104) // faces not found
          return
        }
        
        guard faces.count == 1 else {
          self.setErrorResult(errorCode: 105) // too many faces in frame
          return
        }
        let userFace = faces.first
          
        let faceBoundingBox = Utils.getBoundingBox(from: userFace!)
          if(!Utils.isFaceInFrame(
            faceBoundingBox: faceBoundingBox, frameWidth: frameWidth , frameHeight: frameHeight)){
              self.setErrorResult(errorCode: 106) // face is out of frame
              return
          }
        
        let _curFaceDirection = Utils.getFaceDirection(angleX: userFace!.headEulerAngleX, angleY: userFace!.headEulerAngleY)
        
        if(self._prevFaceDirection != _curFaceDirection){
          self._prevFaceDirection = _curFaceDirection
          self.setErrorResult(errorCode: 107) // face is transitioning
          return
        }
        
          if(self.stableCount < self.MAX_STABLE){
          self.stableCount+=1
          //TODO: switch to standby mode
          self.setErrorResult(errorCode: 107) // face is transitioning
          return
        }
        
        guard let imageBuffer = buffer.imageBuffer else {
          self.setErrorResult(errorCode: 101) //system error
          return
        }
        
        //convert frame to base64 image data
        let image = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
          self.setErrorResult(errorCode: 101) //system error
          return
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        let imageData = uiImage.jpegData(compressionQuality: 100)
        let frameData = imageData?.base64EncodedString()
        self.result = ["status": 1, "faceDirection": _curFaceDirection.rawValue, "errorCode":  -1, "frameData": frameData ?? ""]
      }
      return result
  }

}
