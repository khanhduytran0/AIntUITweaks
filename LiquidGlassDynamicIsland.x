@import Foundation;
@import QuartzCore;
@import UIKit;
#include <libgen.h>

%group Hook_SpringBoard_GlassDynamicIsland
@interface CALayer(Private)
@property(atomic, assign) unsigned int disableUpdateMask;
@end
@interface CAGainMapLayer : CALayer
@end
@interface UIView(Private)
- (void)sbh_applyClearGlass;
@end
@interface _SBGainMapView : UIView
@end
@interface SBSystemApertureContainerView : UIView
@end

%hook CAGainMapLayer
- (void)setDisableUpdateMask:(uint32_t)mode {
    if (mode == 0xffffffff) {
        %orig(0);
    } else {
        %orig(mode|0xffff);
    }
}
%end

@interface SBSystemApertureViewController : UIViewController
@end
%hook SBSystemApertureViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;

    static BOOL changed;
    if (changed) return;
    changed = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Make background transparent
        NSArray<UIView *> *bgParentSubviews = [[self valueForKey:@"_containerBackgroundParent"] subviews];
        if (bgParentSubviews.count < 2) return;
        UIView *bgParentView = bgParentSubviews[1];
        bgParentView.clipsToBounds = NO;
        UIView *bgView = bgParentView.subviews[0];
        bgView.backgroundColor = nil;
        changed = YES;
        
        // add invisible gain map layer
        _SBGainMapView *gainMapView = [[NSClassFromString(@"_SBGainMapView") alloc] initWithFrame:CGRectMake(0,0,1,1)];
        gainMapView.layer.disableUpdateMask = 0xffffffff;
        [self.view addSubview:gainMapView];
    });
}
%end

static UIView *lightBkgKeyLineView, *darkBkgKeyLineView;
%hook SBSystemApertureContainerView
- (void)_updateShadowStyleIfNeeded {
    %orig;
    
    static BOOL changed;
    if (changed) return;
    changed = YES;
    
    // Apply Clear Glass effect
    if (!lightBkgKeyLineView || !darkBkgKeyLineView) {
        Ivar lightIvar = class_getInstanceVariable(self.class, "_lightBkgKeyLineView");
        Ivar darkIvar = class_getInstanceVariable(self.class, "_darkBkgKeyLineView");
        lightBkgKeyLineView = object_getIvar(self, lightIvar);
        darkBkgKeyLineView = object_getIvar(self, darkIvar);
    }
    [lightBkgKeyLineView sbh_applyClearGlass];
    [darkBkgKeyLineView sbh_applyClearGlass];
}

- (void)setKeyLineMode:(int64_t)mode {
    // idk this doesnt work if I put it in constructor
    static BOOL changed;
    if (!changed) {
        changed = YES;
        MSImageRef image = MSGetImageByName("/System/Library/PrivateFrameworks/SpringBoard.framework/SpringBoard");
        CGFloat *opacity = MSFindSymbol(image, "_SBSystemApertureKeyLineDarkBkgEnabledOpacity");
        *opacity = 1;
    }
    %orig(mode);
    if (mode == 2) {
        darkBkgKeyLineView.backgroundColor = [darkBkgKeyLineView.backgroundColor colorWithAlphaComponent:0.345];
    }
}
%end
%end

extern CGFloat SBSystemApertureKeyLineDarkBkgEnabledOpacity;
%ctor {
    NSString *processName = @(basename(argv[0]));
    if (@available(iOS 26.0, *)) {
        if ([processName isEqualToString:@"SpringBoard"]) {
            %init(Hook_SpringBoard_GlassDynamicIsland);
        }
    }
}
