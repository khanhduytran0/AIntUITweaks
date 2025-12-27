TARGET := iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME := rootless

include $(THEOS)/makefiles/common.mk

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += BypassMarketplace
SUBPROJECTS += FixDDI
include $(THEOS_MAKE_PATH)/aggregate.mk
