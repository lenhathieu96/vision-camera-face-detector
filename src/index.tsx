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
   * - 101: system error`
   * - 102: plugin not found
   * - 103: cannot get image from frame
   * - 104: faces not found
   * - 105: too many faces in frame
   * - 106: face is out of frame
   * - 107: faces is transitioning
   */

  errorCode?: 101 | 102 | 103 | 104 | 105 | 106;
  frameData?: string;
  boundaryBox?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}
// /**
//  * initFrameProcessorPlugin has error on init frame so cannot use
//  */
const plugin = VisionCameraProxy.initFrameProcessorPlugin('detectFace', {});

export function detectFace(frame: Frame): FaceDetectorResponse {
  'worklet';
  if (!plugin) {
    return {
      status: 0,
      faceDirection: 'unknown',
      errorCode: 102,
    };
  }
  //@ts-ignore
  return plugin.call(frame);
}
