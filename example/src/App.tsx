/* eslint-disable react-hooks/exhaustive-deps */
import React, { useCallback, useEffect, useState } from 'react';
import { StyleSheet, Text, SafeAreaView, View, Image } from 'react-native';
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
  const [errMessage, setErrMessage] = useState<string>('');
  const [base64Frame, setBase64Frame] = useState<string>('');
  const [submitting, setSubmitting] = useState<boolean>(false);

  const device = useCameraDevice('front');
  const { hasPermission, requestPermission } = useCameraPermission();

  const submitSever = (frameData: string) => {
    setSubmitting(true);
    setErrMessage('');
    setBase64Frame(frameData);
    return new Promise((res) => {
      setTimeout(() => {
        setSubmitting(false);
        setBase64Frame('');
        res('data ne');
      }, 4000);
    });
  };

  const onGetFaceDetectorResponse = Worklets.createRunInJsFn(
    async (res: FaceDetectorResponse) => {
      if (res.status && res.frameData) {
        await submitSever(res.frameData);
      } else if (res.error) {
        setErrMessage(res.error?.message);
      }
    }
  );

  const frameProcessor = useFrameProcessor(
    (frame) => {
      'worklet';
      if (submitting) {
        return;
      }
      const response = detectFace(frame);
      onGetFaceDetectorResponse(response);
    },
    [submitting]
  );

  useEffect(() => {
    if (!hasPermission) {
      requestPermission();
    }
  }, []);

  const renderCamera = useCallback(() => {
    if (device == null || !hasPermission) {
      return <Text>No camera device</Text>;
    }

    return (
      <Camera
        device={device}
        isActive
        style={styles.camera}
        frameProcessor={frameProcessor}
        //ML Kit use YUV format
        pixelFormat="yuv"
      />
    );
  }, [device, hasPermission, frameProcessor]);

  const renderFrame = useCallback(() => {
    return (
      <Image
        style={{ width: 100, height: 100 }}
        source={{ uri: `data:image/png;base64,${base64Frame}` }}
      />
    );
  }, [base64Frame]);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.cameraContainer}>{renderCamera()}</View>
      {renderFrame()}
      <Text>{`Error: ${errMessage}`}</Text>
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
