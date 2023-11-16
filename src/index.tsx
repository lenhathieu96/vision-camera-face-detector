import { type Frame, VisionCameraProxy } from 'react-native-vision-camera';

export type FaceDirection =
  | 'left-skewed'
  | 'right-skewed'
  | 'frontal'
  | 'transitioning'
  | 'unknown';

/**
 *
 * @ErrorCode :
 * - 101: system error`
 * - 102: plugin not found
 * - 103: cannot get image from frame
 * - 104: faces not found
 * - 105: too many faces in frame
 * - 106: face is out of frame
 * - 107: face is transitioning
 */

type FaceDetectionErrorCode = 101 | 102 | 103 | 104 | 105 | 106 | 107;
export type FaceDetectionStatus = 'success' | 'standby' | 'error';

export type FaceDetectorResponse = {
  status: FaceDetectionStatus;
  faceDirection: FaceDirection;
  frameData?: string;
  error?: {
    code: FaceDetectionErrorCode;
    message: string;
  };
};

const plugin = VisionCameraProxy.initFrameProcessorPlugin('detectFace', {});

export function detectFace(frame: Frame): FaceDetectorResponse {
  'worklet';
  if (!plugin) {
    return {
      status: 'error',
      faceDirection: 'unknown',
      error: {
        code: 102,
        message: 'Plugin not found',
      },
    };
  }
  //@ts-ignore
  return plugin.call(frame);
}
