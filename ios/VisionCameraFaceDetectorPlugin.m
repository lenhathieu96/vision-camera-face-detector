#import <Foundation/Foundation.h>
#import "VisionCameraFaceDetectorPlugin.h"
#if defined __has_include && __has_include("VisionCameraFaceDetectorPlugin-Swift.h")
#import "VisionCameraFaceDetectorPlugin-Swift.h"
#else
#import <VisionCameraFaceDetectorPlugin/VisionCameraFaceDetectorPlugin-Swift.h>
#endif

@implementation RegisterPlugins

    + (void) load {
        [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"detectFace"
                                              withInitializer:^FrameProcessorPlugin*(NSDictionary* options) {
            return [[VisionCameraFaceDetectorPlugin alloc] init];
        }];
    }

@end
