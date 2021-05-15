export TARGET = iphone:clang:13.5:13.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CanvasBackgroundSpringBoard

CanvasBackgroundSpringBoard_FILES = Tweak.x CBViewController.m
CanvasBackgroundSpringBoard_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
