@import Darwin;
@import Foundation;
#import <IOKit/IOKitLib.h>
#import "SignedPDI.h"

struct _img4_nonce_domain {
    uint64_t cryptex1, index;
};
typedef struct _img4_nonce_domain img4_nonce_domain_t;
typedef uint16_t img4_struct_version_t;

extern const struct _img4_nonce_domain _img4_nonce_domain_ddi;
#define IMG4_NONCE_DOMAIN_DDI (&_img4_nonce_domain_ddi)

#define IMG4_NONCE_VERSION ((img4_struct_version_t)0)
#define IMG4_NONCE_MAX_LENGTH (48)
typedef struct _img4_nonce {
    img4_struct_version_t i4n_version;
    const uint8_t i4n_nonce[IMG4_NONCE_MAX_LENGTH];
    uint32_t i4n_length;
} img4_nonce_t;

const char *container_system_group_path_for_identifier(int, const char *group, void *error);
errno_t img4_nonce_domain_copy_nonce(const img4_nonce_domain_t *nd, img4_nonce_t *n);
int img4_firmware_execute(void* fw, const void *chip, const void *nonce);

%group Hook_MobileStorageMounter
%hookf(errno_t, img4_nonce_domain_copy_nonce, const img4_nonce_domain_t *nd, img4_nonce_t *n) {
    if (nd != IMG4_NONCE_DOMAIN_DDI) {
        return %orig(nd, n);
    }
    n->i4n_version = IMG4_NONCE_VERSION;
    const char *fakeNonce = "\xAA";
    memcpy((char *)n->i4n_nonce, fakeNonce, IMG4_NONCE_MAX_LENGTH);
    n->i4n_length = strlen(fakeNonce);
    
    // Provide our pre-signed im4m
    const char *groupPath = container_system_group_path_for_identifier(0, "systemgroup.com.apple.mobilestorageproxy", NULL);
    assert(groupPath != NULL);
    
    NSError *error = nil;
    NSString *im4mPath = [NSString stringWithFormat:@"%s/backingStore/DeveloperDiskImage/AA.im4m", groupPath];
    [NSFileManager.defaultManager createDirectoryAtPath:im4mPath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"Failed to create directory: %@", error.localizedDescription);
        return 1;
    }
    
    NSData *im4mData = [NSData dataWithBytes:SignedPDI_im4m length:SignedPDI_im4m_len];
    [im4mData writeToFile:im4mPath atomically:YES];
    return 0;
}

// Bypass im4m check
BOOL gCalledImg4Execute = NO;
%hookf(void, img4_firmware_execute, void* fw, const void *chip, const void *nonce) {
    gCalledImg4Execute = YES;
    // Do nothing
}

// Bypass another check
%hookf(kern_return_t, IOConnectCallMethod, io_connect_t client, uint32_t selector, const uint64_t *in, uint32_t inCnt, const void *inStruct, size_t inStructCnt, uint64_t *out, uint32_t *outCnt, void *outStruct, size_t *outStructCnt) {
    kern_return_t ret = %orig(client, selector, in, inCnt, inStruct, inStructCnt, out, outCnt, outStruct, outStructCnt);
    if (ret == kIOReturnNotPermitted && gCalledImg4Execute) {
        gCalledImg4Execute = NO;
        return kIOReturnSuccess;
    }
    return ret;
}
%end

%ctor {
    NSString *processName = NSProcessInfo.processInfo.processName;
    if ([processName isEqualToString:@"MobileStorageMounter"]) {
        %init(Hook_MobileStorageMounter);
    }
}
