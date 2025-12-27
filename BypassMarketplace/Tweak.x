// "Not bypassing eligibility for com.apple.mobilesafari:personal (isProfileValidated: false isUPPValidated:false isBeta:false"
// Used in managedappdistributiond. Pseudocode of a validate function in OSEligbility.framework:
#if 0
LSBundleRecord *bundleRecord = ...;
BOOL isProfileValidated = bundleRecord.isProfileValidated;
BOOL isUPPValidated = bundleRecord.isUPPValidated;
BOOL isBeta = bundleRecord.isBeta;
if ( (isProfileValidated == NO) || (isUPPValidated == YES) || (isBeta == YES) ) {
    log("Not bypassing eligibility for %s:%s (isProfileValidated: %{bool}d isUPPValidated:%{bool}d isBeta:%{bool}d", bundleRecord.bundleIdentifier.UTF8String, somethingThatSaysPersonal, isProfileValidated, isUPPValidated, isBeta);
}
#endif

// So we just force the three functions to return values that will bypass eligibility
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
