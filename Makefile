TARGET := iphone:clang:18.4:15.0
INSTALL_TARGET_PROCESSES = appstorecomponentsd installd managedappdistributiond SpringBoard MobileStorageMounter cameracaptured
THEOS_PACKAGE_SCHEME := rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = aintuitweaks

aintuitweaks_FILES = BypassMarketplace.x BypassMirroringUnlock.x FixDDI.x NineteenPatches.x FixNonUI.x LiquidGlassDynamicIsland.x
aintuitweaks_CFLAGS = -fobjc-arc
aintuitweaks_FRAMEWORKS = IOKit
aintuitweaks_PRIVATE_FRAMEWORKS = ServiceManagement
aintuitweaks_LIBRARIES = image4
aintuitweaks_CODESIGN_FLAGS = -Cadhoc -S

include $(THEOS_MAKE_PATH)/tweak.mk
