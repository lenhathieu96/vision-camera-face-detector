
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNRnVisionCameraFaceDetectorPluginSpec.h"

@interface RnVisionCameraFaceDetectorPlugin : NSObject <NativeRnVisionCameraFaceDetectorPluginSpec>
#else
#import <React/RCTBridgeModule.h>

@interface RnVisionCameraFaceDetectorPlugin : NSObject <RCTBridgeModule>
#endif

@end
