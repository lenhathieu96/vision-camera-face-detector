"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.detectFace = detectFace;
var _reactNativeVisionCamera = require("react-native-vision-camera");
/**
 * initFrameProcessorPlugin has error on init frame so cannot use
 */ //@ts-ignore
const plugin = _reactNativeVisionCamera.VisionCameraProxy.getFrameProcessorPlugin('detectFace');
function detectFace(frame) {
  'worklet';

  if (!plugin) {
    return {
      status: 0,
      faceDirection: 'unknown',
      errorCode: 106
    };
  }
  //@ts-ignore
  return plugin.call(frame);
}
//# sourceMappingURL=index.js.map