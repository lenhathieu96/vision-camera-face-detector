package com.visioncamerafacedetectorplugin.models;

import java.util.HashMap;
import java.util.Map;

public class FaceDetectorException extends Exception {
  private int errorCode;
  private String errorMessage;

  public  FaceDetectorException(int errorCode, String errorMessage){
    this.errorCode = errorCode;
    this.errorMessage = errorMessage;
  }

  public int getErrorCode() {
    return errorCode;
  }
  public String getMessage() {
    return errorMessage;
  }

  public Map<String, Object> toHashMap() {
    Map<String, Object> hashMap = new HashMap<>();
    hashMap.put("code", this.errorCode);
    hashMap.put("message", this.errorMessage);
    return hashMap;
  }
}
