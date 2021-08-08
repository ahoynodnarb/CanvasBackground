export TARGET = iphone:clang:14.4
INSTALL_TARGET_PROCESSES = SpringBoard

PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CanvasBackgroundSpotify

CanvasBackgroundSpotify_FILES = Tweak.x
CanvasBackgroundSpotify_CFLAGS = -fobjc-arc
# CanvasBackgroundSpotify_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk