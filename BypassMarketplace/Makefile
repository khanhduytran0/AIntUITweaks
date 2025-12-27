TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = managedappdistributiond

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BypassMarketplace

BypassMarketplace_FILES = Tweak.x
BypassMarketplace_CFLAGS = -fobjc-arc
BypassMarketplace_CODESIGN_FLAGS = -Cadhoc -S

include $(THEOS_MAKE_PATH)/tweak.mk
