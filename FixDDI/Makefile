TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = MobileStorageMounter

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FixDDI

FixDDI_FILES = Tweak.x
FixDDI_CFLAGS = -fobjc-arc
FixDDI_FRAMEWORKS = IOKit
FixDDI_LIBRARIES = image4
FixDDI_CODESIGN_FLAGS = -Cadhoc -S

include $(THEOS_MAKE_PATH)/tweak.mk
