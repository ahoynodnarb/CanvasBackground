export TARGET = iphone:clang:14.4
INSTALL_TARGET_PROCESSES = SpringBoard

PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CanvasBackgroundSpringBoard

CanvasBackgroundSpringBoard_FILES = Tweak.x CBViewController.m
CanvasBackgroundSpringBoard_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk