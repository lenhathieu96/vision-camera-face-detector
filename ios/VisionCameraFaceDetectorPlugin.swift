import VisionCamera
import MLKitVision
import MLKitFaceDetection
import CoreMedia
import CoreImage


@objc(VisionCameraFaceDetectorPlugin)
public class VisionCameraFaceDetectorPlugin: FrameProcessorPlugin {
    let MAX_STABLE = 3
    let faceDetectorOptions = FaceDetectorOptions()
    
    var result: [String: Any] = ["status": false, "faceDirection": FaceDirection.unknown.rawValue, "error": FaceDetectionError(code: 102, message:"Plugin not found").toDictionary()]
    var stableCount = 0
    var _prevFaceDirection = FaceDirection.unknown
        
    private func setErrorResult(errorCode: Int, errorMessage: String) {
        self.result = ["status": false, "faceDirection": FaceDirection.unknown.rawValue, "error": FaceDetectionError(code: errorCode, message: errorMessage).toDictionary()]
    }
    
    class func newInstance() -> VisionCameraFaceDetectorPlugin {
        return VisionCameraFaceDetectorPlugin()
    }
    
    public override init() {
        super.init()
        faceDetectorOptions.performanceMode = .accurate
        faceDetectorOptions.landmarkMode = .all
    }
    
    public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable : Any]?) -> Any {
     let faceDetector = FaceDetector.faceDetector(options: faceDetectorOptions)
     let buffer = frame.buffer
     let visionImage = VisionImage(buffer: buffer)
     
     guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
         self.setErrorResult(errorCode: 102, errorMessage: "Cannot get image from frame") // cannot get image from frame
        return result
      }
     let frameWidth = CVPixelBufferGetWidth(pixelBuffer)
     let frameHeight = CVPixelBufferGetHeight(pixelBuffer)
     
     weak var weakSelf = self
        faceDetector.process(visionImage) { faces, error in
            guard weakSelf != nil else {
                self.setErrorResult(errorCode: 101, errorMessage: "System error") // system error
                return
            }
          
            guard let faces = faces, !faces.isEmpty else {
                self.setErrorResult(errorCode: 104, errorMessage: "Face not found") // faces not found
              return
            }
            
            guard faces.count == 1 else {
              self.setErrorResult(errorCode: 105, errorMessage: "Too many faces in frame") // too many faces in frame
              return
            }
            let userFace = faces.first
            
            //detect does face is fully visible in frame
            if(Utils.isFaceOutOfFrame(faceBoundingBox: FaceBoundingBox(rect: userFace!.frame), frameWidth: frameWidth , frameHeight: frameHeight)){
                self.setErrorResult(errorCode: 106, errorMessage: "Face is out of frame") // face is out of frame
                return
            }
        
            //Get current face direction
            let _curFaceDirection = Utils.getFaceDirection(angleX: userFace!.headEulerAngleX, angleY: userFace!.headEulerAngleY)
            if(self._prevFaceDirection != _curFaceDirection){
              self._prevFaceDirection = _curFaceDirection
              self.setErrorResult(errorCode: 107,errorMessage: "Face is transitioning") // face is transitioning
              return
            }
            if(self.stableCount < self.MAX_STABLE){
              self.stableCount+=1
              //TODO: switch to standby mode
              self.setErrorResult(errorCode: 107, errorMessage: "Face is transitioning") // face is transitioning
              return
            }
        
            //convert frame to base64 image data
            guard let imageBuffer = buffer.imageBuffer else {
              self.setErrorResult(errorCode: 102, errorMessage: "Cannot get image from frame") //cannot get image from frame
              return
            }
            let image = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(image, from: image.extent) else {
              self.setErrorResult(errorCode: 102, errorMessage: "Cannot get image from frame") //cannot get image from frame
              return
            }
            let uiImage = UIImage(cgImage: cgImage)
            let imageData = uiImage.jpegData(compressionQuality: 100)
            let frameData = imageData?.base64EncodedString()
        
            //set base64 FrameData to result
            self.result = ["status": true, "faceDirection": _curFaceDirection.rawValue, "frameData": frameData ?? ""]
      }
      return result
  }

}
