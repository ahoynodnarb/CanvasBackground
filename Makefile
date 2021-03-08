THEOS_DEVICE_IP=localhost -p 2222

export ARCHS = arm64 arm64e
export TARGET = iphone:clang:13.5:13.0
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.4.sdk/
export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

INSTALL_TARGET_PROCESSES = SpringBoard
# SUBPROJECTS += Tweak/CanvasSpotify

#include $(THEOS_MAKE_PATH)/aggregate.mk

TWEAK_NAME = CanvasBackground
$(TWEAK_NAME)_FILES = $(wildcard *.xm) $(wildcard *.m)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = MediaRemote
# $(TWEAK_NAME)_LIBRARIES = mryipc
ADDITIONAL_CFLAGS += -DTHEOS_LEAN_AND_MEAN

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
