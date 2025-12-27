@import Foundation;

%group Hook_managedappdistributiond
// "Not bypassing eligibility for com.apple.mobilesafari:personal (isProfileValidated: false isUPPValidated:false isBeta:false"
// Used in managedappdistributiond. Pseudocode of a validate function in OSEligbility.framework:
#if 0
LSBundleRecord *bundleRecord = ...;
BOOL isProfileValidated = bundleRecord.isProfileValidated;
BOOL isUPPValidated = bundleRecord.isUPPValidated;
BOOL isBeta = bundleRecord.isBeta;
if ( (isProfileValidated == NO) || (isUPPValidated == YES) || (isBeta == YES) ) {
    log("Not bypassing eligibility for %s:%s (isProfileValidated: %{bool}d isUPPValidated:%{bool}d isBeta:%{bool}d", bundleRecord.bundleIdentifier.UTF8String, somethingThatSaysPersonal, isProfileValidated, isUPPValidated, isBeta);
    return 0;
}
#endif

// So we just hook these to return values that will bypass eligibility
// for managedappdistributiond
%hook LSBundleRecord
- (BOOL)isProfileValidated {
    return YES;
}
- (BOOL)isUPPValidated {
    return NO;
}
- (BOOL)isBeta {
    return NO;
}
%end
%end

// for appstorecomponentsd, we hook URL method to replace region code
%group Hook_appstorecomponentsd
%hook NSURLRequest
- (instancetype)initWithURL:(NSURL *)url {
    NSString *prefix = @"https://amp-api.apps-marketplace.apple.com/v1/catalog/";
    NSString *urlString = url.absoluteString;
    if ([url.absoluteString hasPrefix:prefix]) {
        // replace region code
        NSArray<NSString *> *components = [urlString componentsSeparatedByString:@"/"];
        if (components.count > 6) {
            NSMutableArray<NSString *> *newComponents = [components mutableCopy];
            newComponents[5] = @"fr"; // spoof to France region
            NSURL *newURL = [NSURL URLWithString:[newComponents componentsJoinedByString:@"/"]];
            return %orig(newURL);
        }
    }
    return %orig;
}
%end
%end

%ctor {
    NSString *processName = NSProcessInfo.processInfo.processName;
    if ([processName isEqualToString:@"managedappdistributiond"]) {
        %init(Hook_managedappdistributiond);
    } else if ([processName isEqualToString:@"appstorecomponentsd"]) {
        %init(Hook_appstorecomponentsd);
    }
}
