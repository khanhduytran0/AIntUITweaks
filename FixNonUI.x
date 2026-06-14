@import Darwin;
@import Foundation;

%group Hook_NonUI
%hookf(kern_return_t, mach_port_construct, ipc_space_t task, mach_port_options_ptr_t options, mach_port_context_t context, mach_port_name_t *name) {
    options->flags &= ~0x10000; // fix EXC_GUARD crash
    return %orig;
}
%end

%group Hook_SwitchBoard
Boolean SMJobSubmit(CFStringRef domain, CFDictionaryRef job, id auth, CFErrorRef *outError);
%hookf(Boolean, SMJobSubmit, CFStringRef domain, CFDictionaryRef job, id auth, CFErrorRef *outError) {
    NSMutableDictionary *mutableJob = [(__bridge NSDictionary *)job mutableCopy];
    mutableJob[@"EnablePressuredExit"] = @(NO);
    mutableJob[@"EnableTransactions"] = @(NO);
    return %orig(domain, (__bridge CFDictionaryRef)mutableJob, auth, outError);
}
%end

%ctor {
    NSString *processName = @(basename(argv[0]));
    if ([processName isEqualToString:@"hidd.nonui"]) {
        %init(Hook_NonUI);
    } else if ([processName isEqualToString:@"SwitchBoard"]) {
        %init(Hook_SwitchBoard);
    }
}
