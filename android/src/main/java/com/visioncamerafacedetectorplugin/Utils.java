package com.visioncamerafacedetectorplugin;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.media.Image;

import com.google.mlkit.vision.common.InputImage;
import com.visioncamerafacedetectorplugin.models.FaceDirection;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;

public class Utils {
  public static FaceDirection getFaceDirection(float angleX, float angleY ){
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
    public static Bitmap convertImageToBitmap(InputImage image) {
        Image.Plane[] planes = image.getPlanes();
        ByteBuffer yBuffer = planes[0].getBuffer();
        ByteBuffer uBuffer = planes[1].getBuffer();
        ByteBuffer vBuffer = planes[2].getBuffer();

        int ySize = yBuffer.remaining();
        int uSize = uBuffer.remaining();
        int vSize = vBuffer.remaining();

        byte[] nv21 = new byte[ySize + uSize + vSize];
        //U and V are swapped
        yBuffer.get(nv21, 0, ySize);
        vBuffer.get(nv21, ySize, vSize);
        uBuffer.get(nv21, ySize + vSize, uSize);

        YuvImage yuvImage = new YuvImage(nv21, ImageFormat.NV21, image.getWidth(), image.getHeight(), null);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        yuvImage.compressToJpeg(new Rect(0, 0, yuvImage.getWidth(), yuvImage.getHeight()), 90, out);

        byte[] imageBytes = out.toByteArray();
        Bitmap bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
        Matrix matrix = new Matrix();
        matrix.postRotate(-90);
        Bitmap rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);

        return rotatedBitmap;
    }

    public static boolean isFaceOutFrame(Rect faceBoundingBox, int frameWidth, int frameHeight){
      int frameCenterY = frameHeight/2;
      final int tolerance = 50;

      return faceBoundingBox.left < 0 ||
        faceBoundingBox.top < 0 ||
        faceBoundingBox.right > frameWidth ||
        faceBoundingBox.bottom > frameHeight ||
        faceBoundingBox.centerY() < frameCenterY - tolerance ||
        faceBoundingBox.centerY() > frameCenterY + tolerance;
    }

    public static String convertKebabCase(FaceDirection faceDirection){
        return faceDirection.name().toLowerCase().replace("_", "-");
    }

    public static int convertRotationDegreeFromString(String orientation){
        switch (orientation){
            case "portrait-upside-down":
                return 180;
            case "landscape-left":
                return 90;
            case "landscape-right":
                return 270;
            default:
                return 0;
        }
    }
}

