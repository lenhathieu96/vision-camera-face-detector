import { type Frame, VisionCameraProxy } from 'react-native-vision-camera';

export type FaceDirection =
  | 'left-skewed'
  | 'right-skewed'
  | 'frontal'
  | 'transitioning'
  | 'unknown';

export interface FaceDetectorResponse {
  status: 0 | 1;
  faceDirection: FaceDirection;
  /**
   *
   * @ErrorCode :
   * - 101: system error
   * - 102: cannot get image from frame
   * - 103: faces not found
   * - 104: too many faces in frame
   * - 105: faces is transitioning
   * - 106: plugin not found
   */

  errorCode?: 101 | 102 | 103 | 104 | 105 | 106;
  frameData?: string;
}

const plugin = VisionCameraProxy.initFrameProcessorPlugin('detectFace');

export function detectFace(frame: Frame): FaceDetectorResponse {
  'worklet';
  if (!plugin) {
    return {
      status: 0,
      faceDirection: 'unknown',
      errorCode: 106,
    };
  }
  //@ts-ignore
  return plugin.call(frame);
}
