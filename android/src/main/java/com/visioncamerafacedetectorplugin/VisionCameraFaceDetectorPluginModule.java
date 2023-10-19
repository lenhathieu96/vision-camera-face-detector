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
import com.visioncamerafacedetectorplugin.models.FaceDetectorException;
import com.visioncamerafacedetectorplugin.models.FaceDirection;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class VisionCameraFaceDetectorPluginModule extends FrameProcessorPlugin {
  private final int MAX_STABLE = 3;
  private int stableCount = 0;
  private FaceDirection _prevFaceDirection = FaceDirection.UNKNOWN;
  final Map map = new HashMap<>();

  FaceDetectorOptions faceDetectorOptions =
          new FaceDetectorOptions.Builder()
                  .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
                  .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
                  .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
                  .build();
  FaceDetector faceDetector = FaceDetection.getClient(faceDetectorOptions);

  private FaceDirection getFaceDirection(float angleX, float angleY ){
    if(angleX < 10 && angleX > -10 && angleY > -5 && angleY < 5){
      return FaceDirection.FRONTAL;
    }

    if(angleY > 40 &&  angleX > 0 && angleX < 20){
      return FaceDirection.LEFT_SKEWED;
    }

    if(angleY < -40 && angleX > 0 && angleX < 20){
      return FaceDirection.RIGHT_SKEWED;
    }

    return FaceDirection.TRANSITIONING;
  }

  private void setErrorResult(int errorCode){
    map.put("status", 0);
    map.put("errorCode",errorCode);
    map.put("faceDirection", Utils.convertKebabCase(FaceDirection.UNKNOWN));
    map.put("frameData", "");
  }

  @Nullable
  @Override
  public Object callback(@NonNull Frame frame, @Nullable Map<String, Object> arguments)  {
    try {
      Image mediaImage = frame.getImage();

      if (mediaImage == null) {
        throw new FaceDetectorException(102, "null media image");
      }

      InputImage image = InputImage.fromMediaImage(mediaImage, Utils.convertRotationDegreeFromString(frame.getOrientation()));
      Task<List<Face>> task = faceDetector.process(image);
      List<Face> faces = Tasks.await(task);

      if (faces.isEmpty()) {
        throw new FaceDetectorException( 103, "faces not found");
      }

      if (faces.size() > 1) {
        throw new FaceDetectorException(104, "Too many faces in frame");
      }

      Face userFace = faces.get(0);
      FaceDirection _currentFaceDirection = getFaceDirection(userFace.getHeadEulerAngleX(), userFace.getHeadEulerAngleY());
      Log.d("FaceDirection", _currentFaceDirection.name());

      if (_prevFaceDirection != _currentFaceDirection) {
        _prevFaceDirection = _currentFaceDirection;
        throw new FaceDetectorException(105, "Face is transitioning");
      }

      if (stableCount < MAX_STABLE) {
        stableCount++;
        throw new FaceDetectorException(105, "Face is transitioning");
      }

      Bitmap frameInBitmap = Utils.convertImageToBitmap(image);
      //Convert frame bitmap to base64
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      frameInBitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);
      String frameInBase64 =  Base64.encodeToString(baos.toByteArray(), Base64.DEFAULT);

      stableCount = 0;
      map.put("status", 1);
      map.put("errorCode", -1);
      map.put("faceDirection", Utils.convertKebabCase(_currentFaceDirection));
      map.put("frameData", frameInBase64);
      return map;

    } catch (FaceDetectorException e) {
      Log.e("FaceDetection", e.getMessage());
      setErrorResult(e.getErrorCode());
      return map;
    }
    catch (Exception e){
      Log.e("FaceDetection", e.toString());
      setErrorResult(101);
      return map;
    }
  }
}
