@import Foundation;
@import QuartzCore;
@import UIKit;
#include <libgen.h>

@interface SBContinuitySessionSystemEventMonitor : NSObject
- (BOOL)isUILocked;
- (void)_setUILocked:(BOOL)locked;
@end

%group Hook_SpringBoard_iOS18
%hook _SBContinuitySessionStateMachine
- (void)_moveToInvalidStateForReasons:(NSArray *)reasons postToDelegate:(BOOL)post {
    for (NSString *reason in reasons) {
        if ([reason hasPrefix:@"block."]) {
            return;
        }
    }
    %orig(reasons, post);
}
%end

%hook SBContinuitySessionSystemEventMonitor
- (void)_setUILocked:(BOOL)locked {
    %orig(YES);
}

- (BOOL)isUILocked {
    if (!%orig()) {
        [self _setUILocked:YES];
    }
    return YES;
}
%end
%end

%group Hook_cameracaptured_FixBlackCamera
// also see -[FigCaptureCameraSourcePipeline setBlackenFramesForContinuityDisplayConnected:]
%hook FigCaptureDisplayLayoutMonitor
- (BOOL)isDisplayConnected {
    return NO;
}
%end
%end

%ctor {
    NSString *processName = @(basename(argv[0]));
    if (@available(iOS 18.0, *)) {
        if ([processName isEqualToString:@"SpringBoard"]) {
            %init(Hook_SpringBoard_iOS18);
        } else if ([processName isEqualToString:@"cameracaptured"]) {
            %init(Hook_cameracaptured_FixBlackCamera);
        }
    }
}
