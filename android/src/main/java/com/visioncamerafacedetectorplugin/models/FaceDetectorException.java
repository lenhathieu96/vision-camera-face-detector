package com.visioncamerafacedetectorplugin.models;
public class FaceDetectorException extends Exception {
  private int errorCode;

  public  FaceDetectorException(int errorCode, String errorMessage){
    super(errorMessage);
    this.errorCode = errorCode;
  }


  public int getErrorCode() {
    return errorCode;
  }
}
