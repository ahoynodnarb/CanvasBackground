export TARGET = iphone:clang:14.4
PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CanvasBackgroundSpotify

CanvasBackgroundSpotify_FILES = Tweak.x
CanvasBackgroundSpotify_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk