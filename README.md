# vision-camera-face-detector-plugin

A Face detector plugin used for react-native-vision-camera

## Requirement

Android Minsdk: 26
IOS target platform: 13

## Installation

```sh
npm install vision-camera-face-detector-plugin
```
or

```sh
yarn add vision-camera-face-detector-plugin
```



## Usage

```js
import { detectFace } from 'vision-camera-face-detector-plugin';

// ...

const frameProcessor = useFrameProcessor((frame) => {
'worklet';
const response = detectFace(frame);
}, []);

// ...
```
## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
