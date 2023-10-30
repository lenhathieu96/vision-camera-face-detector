import { VisionCameraProxy } from 'react-native-vision-camera';
/**
 * initFrameProcessorPlugin has error on init frame so cannot use
 */ //@ts-ignore
const plugin = VisionCameraProxy.getFrameProcessorPlugin('detectFace');
export function detectFace(frame) {
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