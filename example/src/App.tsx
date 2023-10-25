/* eslint-disable react-hooks/exhaustive-deps */
import React, { useEffect, useState } from 'react';
import { StyleSheet, Text, SafeAreaView, View } from 'react-native';
import {
  Camera,
  useCameraDevice,
  useCameraPermission,
  useFrameProcessor,
} from 'react-native-vision-camera';
import { Worklets } from 'react-native-worklets-core';

import {
  FaceDetectorResponse,
  detectFace,
} from 'vision-camera-face-detector-plugin';

const CAMERA_SIZE = 250;

export default function App() {
  const [errorCode, setErrorCode] = useState<number>(-1);

  const device = useCameraDevice('front');
  const { hasPermission, requestPermission } = useCameraPermission();

  const onGetFaceDetectorResponse = Worklets.createRunInJsFn(
    (res: FaceDetectorResponse) => {
      setErrorCode(res.errorCode ?? -1);
      if (res.status === 1 && res.frameData) {
      }
    }
  );

  const frameProcessor = useFrameProcessor((frame) => {
    'worklet';
    const response = detectFace(frame);
    onGetFaceDetectorResponse(response);
  }, []);

  useEffect(() => {
    if (!hasPermission) {
      requestPermission();
    }
  }, []);

  if (device == null || !hasPermission) {
    return <Text>No camera device</Text>;
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.cameraContainer}>
        <Camera
          device={device}
          isActive
          style={styles.camera}
          frameProcessor={frameProcessor}
          //ML Kit use YUV format
          pixelFormat="yuv"
        />
      </View>
      <Text>{`Error code: ${errorCode}`}</Text>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },

  cameraContainer: {
    width: CAMERA_SIZE,
    height: CAMERA_SIZE,
    borderRadius: CAMERA_SIZE / 2,
    marginVertical: 24,
  },

  camera: {
    flex: 1,
  },
});
