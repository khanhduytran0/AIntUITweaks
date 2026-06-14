#import <CydiaSubstrate/CydiaSubstrate.h>

%ctor {
    MSImageRef image = MSGetImageByName("/usr/lib/swift/libswiftCore.dylib");
    if (!image) return;
    uint32_t *symbol = MSFindSymbol(image, "__ZNSt3__110__function6__funcIZL27_checkWitnessTableIsolationPKN5swift14TargetMetadataINS2_9InProcessEEEPKNS2_18TargetWitnessTableIS4_EEN7__swift9__runtime4llvm8ArrayRefIPKvEERNS2_27ConformanceExecutionContextEE3$_0NS_9allocatorISL_EEFSH_jjEED1Ev");
    uint32_t xpacd_x0 = 0xdac147e0;
    uint32_t ret = 0xd65f03c0;
    if (symbol && symbol[-1] == ret && symbol[0] == ret) {
        MSHookMemory(symbol-1, &xpacd_x0, sizeof(uint32_t));
    }
}
