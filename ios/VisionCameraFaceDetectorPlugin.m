#import <Foundation/Foundation.h>
#import "VisionCameraFaceDetectorPlugin.h"
#import "VisionCameraFaceDetectorPlugin-Swift.h"

@implementation RegisterPlugins
    + (void) load {
        [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"detectFace"
                                              withInitializer:^FrameProcessorPlugin*(NSDictionary* options) {
            return [[VisionCameraFaceDetectorPlugin alloc] init];
        }];
    }

@end
