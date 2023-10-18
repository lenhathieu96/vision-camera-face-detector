import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'rn-vision-camera-face-detector-plugin' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;

const RnVisionCameraFaceDetectorPluginModule = isTurboModuleEnabled
  ? require('./NativeRnVisionCameraFaceDetectorPlugin').default
  : NativeModules.RnVisionCameraFaceDetectorPlugin;

const RnVisionCameraFaceDetectorPlugin = RnVisionCameraFaceDetectorPluginModule
  ? RnVisionCameraFaceDetectorPluginModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function multiply(a: number, b: number): Promise<number> {
  return RnVisionCameraFaceDetectorPlugin.multiply(a, b);
}
