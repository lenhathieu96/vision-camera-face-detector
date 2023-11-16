package com.visioncamerafacedetectorplugin;

import android.graphics.Bitmap;
import android.media.Image;
import android.util.Base64;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;

import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.face.Face;
import com.google.mlkit.vision.face.FaceDetection;
import com.google.mlkit.vision.face.FaceDetector;
import com.google.mlkit.vision.face.FaceDetectorOptions;

import com.mrousavy.camera.frameprocessor.Frame;
import com.mrousavy.camera.frameprocessor.FrameProcessorPlugin;

import com.visioncamerafacedetectorplugin.models.FaceDetectionStatus;
import com.visioncamerafacedetectorplugin.models.FaceDetectorException;
import com.visioncamerafacedetectorplugin.models.FaceDirection;

import java.io.ByteArrayOutputStream;
import java.sql.Time;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class VisionCameraFaceDetectorPlugin extends FrameProcessorPlugin {

  private final int MAX_DIFFERENCE = 5;
  private Long firstDetectedTime = 0L;
  private FaceDirection _prevFaceDirection = FaceDirection.UNKNOWN;

  Map<String, Object> resultMap = new HashMap<>();
  FaceDetectorOptions faceDetectorOptions =
          new FaceDetectorOptions.Builder()
                  .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
                  .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
                  .build();
  FaceDetector faceDetector = FaceDetection.getClient(faceDetectorOptions);

  private void setErrorResult(FaceDetectorException error){
    resultMap.put("status", FaceDetectionStatus.ERROR.name().toLowerCase());
    resultMap.put("faceDirection", Utils.convertKebabCase(FaceDirection.UNKNOWN));
    resultMap.put("error", error.toHashMap());
    resultMap.put("frameData", null);
  }

  VisionCameraFaceDetectorPlugin(@Nullable Map<String, Object> options){
    super(options);
  }


  @Override
  public Object callback(@NonNull Frame frame, @Nullable Map<String, Object> params)  {
    try {
      Image mediaImage = frame.getImage();
      if (mediaImage == null) {
        throw new FaceDetectorException(103, "Cannot get image from frame");
      }

      InputImage image = InputImage.fromMediaImage(mediaImage, Utils.convertRotationDegreeFromString(frame.getOrientation()));
      Task<List<Face>> task = faceDetector.process(image);
      List<Face> faces = Tasks.await(task);

      if (faces.isEmpty()) {
        throw new FaceDetectorException( 104, "Faces not found");
      }

      if (faces.size() > 1) {
        throw new FaceDetectorException(105, "Too many faces in frame");
      }
      Face userFace = faces.get(0);

      //Detect does face is out of frame
      if(Utils.isFaceOutFrame(userFace.getBoundingBox(), frame.getWidth(), frame.getHeight())){
        throw new FaceDetectorException(106, "Face is out of frame");
      }

      //Get Face Direction
      FaceDirection _currentFaceDirection = Utils.getFaceDirection(userFace.getHeadEulerAngleX(), userFace.getHeadEulerAngleY());
      if (_prevFaceDirection != _currentFaceDirection) {
        _prevFaceDirection = _currentFaceDirection;
        throw new FaceDetectorException(107, "Face is transitioning");
      }

      //Enter standby mode on
      Long now = Instant.now().getEpochSecond();
      if(firstDetectedTime == 0L ){
        firstDetectedTime = now;
        resultMap.put("status", FaceDetectionStatus.STANDBY.name().toLowerCase());
        resultMap.put("faceDirection", Utils.convertKebabCase(_currentFaceDirection));
        return resultMap;
      }
      Long difference = now - firstDetectedTime;
      if (difference < MAX_DIFFERENCE) {
        resultMap.put("status", FaceDetectionStatus.STANDBY.name().toLowerCase());
        resultMap.put("faceDirection", Utils.convertKebabCase(_currentFaceDirection));
        return resultMap;
      }

      //Convert frame bitmap to base64
      Bitmap frameInBitmap = Utils.convertImageToBitmap(image);
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      frameInBitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);
      String frameInBase64 =  Base64.encodeToString(baos.toByteArray(), Base64.DEFAULT);
      firstDetectedTime = now;

      resultMap.put("status", FaceDetectionStatus.SUCCESS.name().toLowerCase());
      resultMap.put("faceDirection", Utils.convertKebabCase(_currentFaceDirection));
      resultMap.put("frameData", frameInBase64);
      return resultMap;

    } catch (FaceDetectorException e) {
      Log.e("FaceDetection", e.getMessage());
      setErrorResult(e);
      return resultMap;
    }
    catch (Exception e){
      Log.e("FaceDetection", e.toString());
      setErrorResult( new FaceDetectorException(101, "System Error"));
      return resultMap;
    }
  }
}
